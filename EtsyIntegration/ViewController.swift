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
        etsy = EtsySwift(consumerKey: "----", consumerSecret: "----")
    }
}

class ViewController: UIViewController {
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var loginBtn: UIButton!
    @IBOutlet private weak var requestShopBtn: UIButton!
    @IBOutlet private weak var shopNameLabel: UILabel!
    @IBOutlet private weak var prevPageButton: UIButton!
    @IBOutlet private weak var nextPageButton: UIButton!
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var effectivePageLabel: UILabel!
    @IBOutlet private weak var nextPageLabel: UILabel!
    @IBOutlet private weak var effectiveOffsetLabel: UILabel!
    @IBOutlet private weak var nextOffsetLabel: UILabel!
    
    private let disposeBag = DisposeBag()
    private let listingLimit = 25
    private var pagination: EtsyPagination?
    
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
        self.prevPageButton.isEnabled = false
        self.nextPageButton.isEnabled = false
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
                    .request(.shops("NorthwindSupply"))
                    .decodedAs(EtsyResponse<EtsyShop>.self)
                    .take(1)
                    .asSingle()
            })
    }

    @IBAction func onLoginTapped(_ sender: Any) {
        performLogin()
    }
    
    @IBAction func requestShopImagesBtnTapped(_ sender: Any) {
        getEtsyImages(offset: 0)
    }
    
    private func getEtsyImages(offset: Int) {
        API.shared.etsy.request(.shopListings(shopName: "NorthwindSupply", listingLimit: listingLimit, offset: offset, keywords: nil, includeImages: true))
            .decodedAs(EtsyResponse<EtsyListing>.self)
            .map({ (response) -> (images: [EtsyImage], responseCount: Int, pagination: EtsyPagination) in
                return (response.results.compactMap({$0.images}).reduce([], +), response.count, response.pagination)
            })
            .subscribe(onNext: { [unowned self] (images, count, pagination) in
                self.shopNameLabel.text = "Images count: " + String(images.count)
                self.countLabel.text = String(count)
                self.updatePagination(pagination)
                }, onError: { (error) in
                    print(error)
            }).disposed(by: disposeBag)
    }
    
    private func onError(_ error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func updatePagination(_ pagination: EtsyPagination) {
        prevPageButton.isEnabled = pagination.hasPrevPage
        nextPageButton.isEnabled = pagination.hasNextPage
        effectivePageLabel.text = String(pagination.effectivePage ?? 0)
        nextPageLabel.text = String(pagination.nextPage ?? 0)
        effectiveOffsetLabel.text = String(pagination.effectiveOffset ?? 0)
        nextOffsetLabel.text = String(pagination.nextOffset ?? 0)
        self.pagination = pagination
    }
    
    @IBAction func prevPageButtonTapped(_ sender: Any) {
        if let currentOffset = pagination?.effectiveOffset {
            getEtsyImages(offset: currentOffset - listingLimit)
        }
    }
    
    @IBAction func nextPageButtonTapped(_ sender: Any) {
        getEtsyImages(offset: pagination?.nextOffset ?? 0)
    }
}
