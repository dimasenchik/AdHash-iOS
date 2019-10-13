//
//  AdHashView.swift
//  OnlyTestADHASH
//
//  Created by Dima Senchik on 9/22/19.
//  Copyright © 2019 Dima Senchik. All rights reserved.
//

import UIKit
import SafariServices

public class AdHashView: UIView {

    //MARK: - Properties
    public var adTagId: String = ""
	private var adInfo = AdRequestModel()
	
    weak public var delegate: AdHashViewDelegate? {
        didSet {
			AdHashManager.configurateManager(didGetData: { [weak self] adModel in
				DispatchQueue.main.async {
					self?.adInfo = adModel
					self?.configureGestures()
					self?.setBannerImage()
				}
			})
        }
    }
	
	private var bannerImage = UIImageView()
    
    //MARK: - Life cycle
	override open func awakeFromNib() {
		bannerImage.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
		bannerImage.clipsToBounds = true
		bannerImage.contentMode = .scaleToFill
		self.addSubview(bannerImage)
		configureAdManger()
		NotificationCenter.default.addObserver(self, selector: #selector(screenshotTaken), name: UIApplication.userDidTakeScreenshotNotification, object: nil)
	}
    
    //MARK: - Private methods
    private func configureAdManger() {
		adInfo.adTagId = adTagId
		AdHashManager.shared.adInfoModel = adInfo
    }
	
	private func setBannerImage() {
		bannerImage.image = adInfo.bannerImage
	}
    
    private func configureGestures() {
		let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(tapOnBanner))
		swipeRightGesture.direction = .right
		let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(tapOnBanner))
		swipeLeftGesture.direction = .left
		let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(tapOnBanner))
		swipeUpGesture.direction = .up
		let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(tapOnBanner))
		swipeRightGesture.direction = .down
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnBanner))
		self.addGestureRecognizer(swipeRightGesture)
		self.addGestureRecognizer(swipeLeftGesture)
		self.addGestureRecognizer(swipeUpGesture)
		self.addGestureRecognizer(swipeDownGesture)
        self.addGestureRecognizer(tapGesture)
    }
    
	@objc private func tapOnBanner(touch: UITapGestureRecognizer) {
		if adInfo.bannerURL != "" {
			EventManager.getClickableURL(adInfo: adInfo, tapCoordinates: touch.location(in: self)) { [weak self] (clickableURL) in
				if let adId = self?.adInfo.adTagId {
					self?.delegate?.didClickOnAd(adId: adId)
				}
				let safariController = SFSafariViewController(url: clickableURL)
				self?.delegate?.present(safariController, animated: true, completion: nil)
			}
		}
	}
	
	@objc private func screenshotTaken() {
		EventManager.sendAnalyticsRequest(type: .screenShot, adInfo: adInfo) {}
	}
    
}
