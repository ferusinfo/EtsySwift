//
//  ViewController.swift
//  EtsyIntegration
//
//  Created by Maciej Kołek on 1/8/19.
//  Copyright © 2019 GetResponse. All rights reserved.
//

import UIKit
import RxAlamofire
import Alamofire
import RxSwift

class API {
    static let shared = API()
    let etsy: EtsySwift
    init() {
        etsy = EtsySwift(consumerKey: "-----", consumerSecret: "------")
    }
}

class ViewController: UIViewController {
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var loginBtn: UIButton!
    @IBOutlet private weak var requestShopBtn: UIButton!
    @IBOutlet private weak var shopNameLabel: UILabel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        API.shared.etsy.isLoggedInObservable
        .do(onSubscribe: { [unowned self] in
            self.updateLayout(false)
        })
        .subscribe(onNext: { [unowned self] isLoggedIn in
            self.updateLayout(isLoggedIn)
        }).disposed(by: disposeBag)
    }
    
    private func updateLayout(_ isLoggedIn: Bool) {
        self.statusLabel.text = isLoggedIn ? "Logged in sucessfully" : "Logged out"
        self.requestShopBtn.isEnabled = isLoggedIn
        self.shopNameLabel.isHidden = !isLoggedIn
    }
    
    private func performLogin() {
        API.shared.etsy.login(["email_r"], callback: "etsyintegration://oauth-callback")
            .andThen(getShops())
            .subscribe(onSuccess: { [unowned self] response in
                self.shopNameLabel.isHidden = false
                self.shopNameLabel.text = response.results.first?.name
                }, onError: { [unowned self] error in
                    self.onError(error)
            }).disposed(by: disposeBag)
    }
    
    func getShops() -> Single<EtsyResponse<EtsyShop>> {
        return
            Single.deferred({ () -> Single<EtsyResponse<EtsyShop>> in
                API.shared.etsy
                    .request(.shops("__SELF__"))
                    .decodedAs(EtsyResponse<EtsyShop>.self)
                    .asSingle()
            })
    }

    @IBAction func onLoginTapped(_ sender: Any) {
        performLogin()
    }
    
    @IBAction func requestShopBtnTapped(_ sender: Any) {
            getShops()
            .subscribe(onSuccess: { [unowned self] response in
                self.shopNameLabel.isHidden = false
                self.shopNameLabel.text = response.results.first?.name
            }, onError: { [unowned self] error in
                self.onError(error)
            }).disposed(by: disposeBag)
    }
    
    private func onError(_ error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
