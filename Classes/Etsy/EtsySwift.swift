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

class EtsySwift {
    static let shared = EtsySwift()
    static let apiBaseUrl = "https://openapi.etsy.com/v2/"
    private let requestTokenUrl = apiBaseUrl + "oauth/request_token?scope=email_r&oauth_callback="
    private let accessTokenUrl = apiBaseUrl + "oauth/access_token?oauth_verifier="
    
    enum EtsyAuthResponseKeys : String {
        case loginUrl = "login_url"
        case oAuthTokenSecret = "oauth_token_secret"
        case oAuthToken = "oauth_token"
    }
    
    let manager = SessionManager.default
    let disposeBag: DisposeBag = DisposeBag()
    
    private var consumerKey: String!
    private var consumerSecret: String!
    private var oAuthTokenSecret: String?
    private var oAuthToken: String?
    private var isLoggedIn = BehaviorSubject<Bool>(value: false)
    
    func set(consumerKey: String, consumerSecret: String) {
        self.consumerKey = consumerKey
        self.consumerSecret = consumerSecret
    }
    
    //MARK: - Login
    func login(_ scope: [String], callback: String) -> Observable<Bool> {
        isLoggedIn.dispose()
        isLoggedIn = BehaviorSubject<Bool>(value: false)
        return isLoggedIn.asObservable().do(onSubscribe: { [unowned self] in
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
            .flatMap({ [unowned self] response -> Single<URL> in
                let result = self.parseText(response)
                self.setAuthData(result)
                return Single.just(URL(string: result[.loginUrl]!)!)
            })
            .subscribe(onSuccess: { (url) in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }, onError: { [unowned self] (error) in
                self.isLoggedIn.onError(error)
            }).disposed(by: disposeBag)
    }
    
    func buildLoginURL(_ scope: [String], _ callback: String) -> URL {
        let params: [String: String]  = [
            "scope": scope.joined(separator: "%20"),
            "oauth_callback": callback
        ]
        
        var components = URLComponents(string: requestTokenUrl)!
        components.queryItems = params.map { element in URLQueryItem(name: element.key, value: element.value) }
        
        return components.url!
    }
    
    func callbackCalled(url: URL) {
        if let queryParameters = url.queryParameters, let verifier = queryParameters["oauth_verifier"] {
            verifyAccessToken(verifier: verifier)
        }
    }
    
    func verifyAccessToken(verifier: String) {
        return manager.rx.string(.get,
                                 accessTokenUrl + verifier,
                                 parameters: nil,
                                 encoding: URLEncoding.default,
                                 headers: createOAuthHeader(tokenSecret: oAuthTokenSecret!, accessToken: oAuthToken!))
            .asSingle()
            .subscribe(onSuccess: { [unowned self] response in
                self.setAuthData(self.parseText(response))
                self.isLoggedIn.onNext(true)
                }, onError: { (error) in
                    self.isLoggedIn.onError(error)
            }).disposed(by: disposeBag)
    }
    
    // MARK: - Make authorized requests
    func request(_ resource: EtsyResource, parameters: [String: Any]? = nil) -> Observable<[String: Any]> {
        return request(method: resource.method,
                       url: EtsySwift.apiBaseUrl + resource.url,
                       parameters: parameters)
            .map({ data -> [String: Any] in
                return data as! [String: Any]
            })
    }
    
    func request(method: HTTPMethod, url: URLConvertible, parameters: [String: Any]? = nil) -> Observable<Any> {
        return manager.rx.json(method,
                               url,
                               parameters: parameters,
                               encoding: JSONEncoding.default,
                               headers: createOAuthHeader(tokenSecret: oAuthTokenSecret!, accessToken: oAuthToken!))
    }
    
    private func logout() {
        self.oAuthTokenSecret = nil
        self.oAuthToken = nil
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
