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
			configureAdManger()
			AdHashManager.configurateManager(didGetData: { [weak self] adModel in
				DispatchQueue.main.async {
					self?.adInfo = adModel
					self?.setBannerImage()
					self?.setLogo()
				}
			})
        }
    }
	
	private var logoImage = UIImageView()
	private var bannerImage = UIImageView()
    
    //MARK: - Life cycle
	override open func awakeFromNib() {
		bannerImage.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
		bannerImage.isUserInteractionEnabled = true
		self.addSubview(bannerImage)
		bannerImage.translatesAutoresizingMaskIntoConstraints = false
		let trailingConstraint = bannerImage.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0)
		let leadingConstraint = bannerImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0)
		let topConstraint = bannerImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 0)
		let bottomConstraint = bannerImage.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
		NSLayoutConstraint.activate([trailingConstraint, leadingConstraint, topConstraint, bottomConstraint])
		self.layoutSubviews()
		NotificationCenter.default.addObserver(self, selector: #selector(screenshotTaken), name: UIApplication.userDidTakeScreenshotNotification, object: nil)
		setLogo()
		configureGestures()
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
		let reportTapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnReport))
		logoImage.addGestureRecognizer(reportTapGesture)
		bannerImage.addGestureRecognizer(swipeRightGesture)
		bannerImage.addGestureRecognizer(swipeLeftGesture)
		bannerImage.addGestureRecognizer(swipeUpGesture)
		bannerImage.addGestureRecognizer(swipeDownGesture)
        bannerImage.addGestureRecognizer(tapGesture)
    }
	
	private func setLogo() {
		self.addSubview(logoImage)
		logoImage.translatesAutoresizingMaskIntoConstraints = false
		logoImage.heightAnchor.constraint(equalToConstant: 20).isActive = true
		logoImage.widthAnchor.constraint(equalToConstant: 20).isActive = true
		logoImage.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
		logoImage.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
		logoImage.isUserInteractionEnabled = true
		if let filePath = Bundle(for: DecryptionViewController.self).path(forResource: "adhashLogo", ofType: "png"), let image = UIImage(contentsOfFile: filePath) {
			logoImage.image = image
		}
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
	
	@objc private func tapOnReport() {
		if AdHashManager.reportURL != "", let url = URL(string: AdHashManager.reportURL) {
			delegate?.didClickOnReport(adId: adInfo.adTagId)
			let safariController = SFSafariViewController(url: url)
			delegate?.present(safariController, animated: true, completion: nil)
		}
	}
	
	@objc private func screenshotTaken() {
		EventManager.sendAnalyticsRequest(type: .screenShot, adInfo: adInfo) {}
	}
    
}
