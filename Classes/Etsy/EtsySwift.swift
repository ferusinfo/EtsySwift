//
//  EtsySwift.swift
//  EtsyIntegration
//
//  Created by Maciej Kołek on 1/10/19.
//  Copyright © 2019 GetResponse. All rights reserved.
//

import Foundation
import RxSwift
import RxAlamofire
import Alamofire

public class EtsySwift {
    static let apiBaseUrl = "https://openapi.etsy.com/v2/"
    private let requestTokenUrl = apiBaseUrl + "oauth/request_token?scope=email_r&oauth_callback="
    private let accessTokenUrl = apiBaseUrl + "oauth/access_token?oauth_verifier="
    
    enum EtsyAuthResponseKeys : String {
        case loginUrl = "login_url"
        case oAuthTokenSecret = "oauth_token_secret"
        case oAuthToken = "oauth_token"
    }
    
    private let manager = SessionManager.default
    private let disposeBag: DisposeBag = DisposeBag()
    
    public var isLoggedIn: Bool {
        return oAuthToken != nil && oAuthTokenSecret != nil
    }
    
    private var consumerKey: String!
    private var consumerSecret: String!
    public var oAuthTokenSecret: String?
    public var oAuthToken: String?
    private var loginSubject = PublishSubject<Bool>()
    private var isLoggedInSubject = BehaviorSubject<Bool>(value: false)
    
    public var isLoggedInObservable: Observable<Bool> {
        return isLoggedInSubject.asObservable()
    }
    
    public init(consumerKey: String, consumerSecret: String) {
        set(consumerKey: consumerKey, consumerSecret: consumerSecret)
    }
    
    public func set(consumerKey: String, consumerSecret: String) {
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
    }
    
    public func setCredentials(token: String, secret: String) {
        self.oAuthToken = token
        self.oAuthTokenSecret = secret
    }
    
    //MARK: - Login
    public func login(_ scope: [String], callback: String) -> Completable {
        loginSubject.dispose()
        loginSubject = PublishSubject<Bool>()
        return loginSubject
        .asObservable()
        .take(1)
        .asSingle()
        .asCompletable()
        .do(onCompleted: {
            print("Stream completed")
        })
        .do(onSubscribe: { [unowned self] in
            
            print("OnSubscribe")
            
            self.logout()
            self.openLoginPage(scope, callback: callback)
        })
    }
    
    private func openLoginPage(_ scope: [String], callback: String) {
        manager.rx.string(.get,
                          buildLoginURL(scope, callback),
                          parameters: nil,
                          encoding: URLEncoding.default,
                          headers: createOAuthHeader())
            .asSingle()
            .map({ [unowned self] response -> URL in
                let result = self.parseText(response)
                self.setAuthData(result)
                return URL(string: result[.loginUrl]!)!
            })
            .subscribe(onSuccess: { (url) in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }, onError: { [unowned self] (error) in
                self.login(error: error)
            }).disposed(by: disposeBag)
    }
    
    private func buildLoginURL(_ scope: [String], _ callback: String) -> URL {
        let params: [String: String]  = [
            "scope": scope.joined(separator: "%20"),
            "oauth_callback": callback
        ]
        
        var components = URLComponents(string: requestTokenUrl)!
        components.queryItems = params.map { element in URLQueryItem(name: element.key, value: element.value) }
        
        return components.url!
    }
    
    public func callbackCalled(url: URL) {
        if let queryParameters = url.queryParameters, let verifier = queryParameters["oauth_verifier"] {
            verifyAccessToken(verifier: verifier)
        }
    }
    
    private func verifyAccessToken(verifier: String) {
        return manager.rx.string(.get,
                                 accessTokenUrl + verifier,
                                 parameters: nil,
                                 encoding: URLEncoding.default,
                                 headers: createOAuthHeader(tokenSecret: oAuthTokenSecret!, accessToken: oAuthToken!))
            .asSingle()
            .subscribe(onSuccess: { [unowned self] response in
                self.setAuthData(self.parseText(response))
                self.loginSucceeded()
            }, onError: { [unowned self] (error) in
                self.login(error: error)
            }).disposed(by: disposeBag)
    }
    
    func login(error: Error) {
        self.isLoggedInSubject.onError(error)
        self.loginSubject.onError(error)
    }
    
    func loginSucceeded() {
        self.loginSubject.onNext(true)
        self.isLoggedInSubject.onNext(true)
    }
    
    // MARK: - Make authorized requests
    public func request(_ resource: EtsyResource, parameters: [String: Any]? = nil) -> Observable<[String: Any]> {
        
        var params : [String: Any] = [:]
        if let resourceParams = resource.parameters {
            params.merge(other: resourceParams)
        }
        if let requestParams = parameters {
            params.merge(other: requestParams)
        }
        
        return request(method: resource.method,
                       url: EtsySwift.apiBaseUrl + resource.url,
                       parameters: parameters)
                .map({ data -> [String: Any] in
                    return data as! [String: Any]
                })
    }
    
    public func request(method: HTTPMethod, url: URLConvertible, parameters: [String: Any]? = nil) -> Observable<Any> {
        return manager.rx.json(method,
                               url,
                               parameters: parameters,
                               encoding: JSONEncoding.default,
                               headers: createOAuthHeader(tokenSecret: oAuthTokenSecret!, accessToken: oAuthToken!))
    }
    
    public func logout() {
        self.oAuthTokenSecret = nil
        self.oAuthToken = nil
        self.isLoggedInSubject.onNext(false)
    }
    
    // MARK: - Header
    private func createOAuthHeader(tokenSecret: String = "", accessToken: String? = nil) -> [String: String] {
        var params: [String: String] = [
            "oauth_version": "1.0",
            "oauth_consumer_key": consumerKey,
            "oauth_nonce": String(Int.random(in: 0 ..< 10000)),
            "oauth_signature_method": "PLAINTEXT",
            "oauth_timestamp":  String(NSDate().timeIntervalSince1970/1000),
            "oauth_signature": consumerSecret + "&" + tokenSecret
        ]
        
        if let accessToken = accessToken {
            params["oauth_token"] = accessToken
        }
        return ["Authorization" : "OAuth \(params.map{ "\($0)=\"\($1)\"" }.joined(separator: ","))"]
    }
    
    // MARK: - Helpers
    private func parseText(_ response: String) -> [EtsyAuthResponseKeys: String] {
        return response.split(separator: "&").reduce([:], { (result, substring) -> [EtsyAuthResponseKeys: String] in
            var res = result
            var splited = String(substring).split(separator: "=")
            if let keyStr = splited.first,  let key = EtsyAuthResponseKeys(rawValue: String(keyStr).removingPercentEncoding!) {
                res[key] = String(splited[1].removingPercentEncoding!)
            }
            return res
        })
    }
    
    private func setAuthData(_ data: [EtsyAuthResponseKeys: String]) {
        self.oAuthToken = data[.oAuthToken]
        self.oAuthTokenSecret = data[.oAuthTokenSecret]
    }
}

extension Dictionary {
    mutating func merge(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}
