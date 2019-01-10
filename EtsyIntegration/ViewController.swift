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

class ViewController: UIViewController {
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var loginBtn: UIButton!
    @IBOutlet private weak var requestShopBtn: UIButton!
    @IBOutlet private weak var shopNameLabel: UILabel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLayout(false)
    }
    
    private func updateLayout(_ isLoggedIn: Bool) {
        self.statusLabel.text = isLoggedIn ? "Logged in sucessfully" : "Logged out"
        self.requestShopBtn.isEnabled = isLoggedIn
        self.shopNameLabel.isHidden = !isLoggedIn
    }
    
    private func performLogin() {
        EtsySwift.shared.set(consumerKey: "----------------------------------------",
                             consumerSecret: "--------")
        EtsySwift.shared.login(["email_r"], callback: "etsyintegration://oauth-callback")
            .subscribe(onNext: { [unowned self] isLoggedIn in
                self.updateLayout(isLoggedIn)
            }, onError: { (error) in
                self.onError(error)
            }).disposed(by: disposeBag)
    }

    @IBAction func onLoginTapped(_ sender: Any) {
        performLogin()
    }
    
    @IBAction func requestShopBtnTapped(_ sender: Any) {
        EtsySwift.shared
            .request(.shops("__SELF__"))
            .decodedAs(EtsyResponse<EtsyShop>.self)
            .subscribe(onNext: { [unowned self] response in
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
