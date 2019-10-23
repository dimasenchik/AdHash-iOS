//
//  AdHashManager.swift
//  AdHashSDK
//
//  Created by Dima Senchik on 9/18/19.
//  Copyright © 2019 Dima Senchik. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

open class AdHashManager {
    
    //MARK: - Properties
    public static var timeZone: Int = TimeZone.current.secondsFromGMT()/3600
	public static var location: String {
		if let id = Bundle.main.bundleIdentifier {
			return id
		} else {
			return ""
		}
	}
    public static var publisherID: String = ""
    public static var screenWidth: CGFloat = UIScreen.main.bounds.width
    public static var screenHeight: CGFloat = UIScreen.main.bounds.height
    public static var platform: String {
        return UIDevice.current.model
    }
    public static var language: String {
        return Locale.current.identifier
    }
    private static var device: String {
        return "Apple"
    }
    public static var model: String {
        return UIDevice.current.type.rawValue
    }
    public static var type: String {
        if UIDevice.current.model == "iPhone" {
            return "mobile"
        } else {
            return "tablet"
        }
    }
    public static var connection: String = ConnectionService.getConnectionType()
    public static var isp: String {
        if let carrierName = ConnectionService.getCarrierName() {
            return carrierName
        } else {
            return ""
        }
    }
    public static var orientation: String {
        if UIDevice.current.orientation.isPortrait {
            return "portrait"
        } else {
            return "landscape"
        }
    }
    public static var gps: String {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                return ""
            case .authorizedAlways, .authorizedWhenInUse:
                if let location = CLLocationManager().location {
                    return "\(location.coordinate.longitude), \(location.coordinate.latitude)"
                } else {
                    return ""
                }
            }
        } else {
            return ""
        }
    }
    public static var bannerWidth: CGFloat = 0.0
    public static var bannerHeight: CGFloat = 0.0
    private static var isMobile: Bool = true
    public static var blockedAdvertisers: [String] = []
    public static var currentTimestamp: String = "\(Int(Date().timeIntervalSince1970))"
	public static var recentAds: [[Any]] {
		return CoreDataService.getRecentAds()
	}
	public static var apiVersion: Float = 1.0
	
	//Configuration links
	public static var analyticsURL: String = ""
	public static var analyticsScreenShotURL: String = ""
	public static var bidderURL: String = ""
	public static var publisherURL: String = ""
	public static var reportURL: String = ""
	
	static let shared = AdHashManager()
	private var didGetAdInfo: () -> () = {}
	var adInfoModel = AdRequestModel()
    
    //MARK: - Public methods
	static func configurateManager(didGetData: @escaping ((AdRequestModel) -> Void)) {
		if !UIAccessibility.isVoiceOverRunning {
			let body: [String: Any] =
				[
					"timezone": timeZone,
					"location": AdHashManager.location,
					"publisherId": publisherID,
					"size": ["screenWidth": screenWidth, "screenHeight": screenHeight],
					"navigator": ["platform": AdHashManager.platform, "language": AdHashManager.language, "device": AdHashManager.device, "model": AdHashManager.model, "type": AdHashManager.type],
					"connection": connection,
					"isp": AdHashManager.isp,
					"orientation": AdHashManager.orientation,
					"gps": AdHashManager.gps,
					"creatives": [["size": "\(Int(bannerWidth))x\(Int(bannerHeight))"]],
					"mobile": isMobile,
					"blockedAdvertisers": blockedAdvertisers,
					"currentTimestamp": currentTimestamp,
					"recentAds": recentAds
			]
			
			guard let request = RequestBuilder.build(.post, headersType: .typical, body: body, requestType: .firstStep) else { return }
			
			NetworkManager.shared.perform(request, onSuccess: { (data) in
				do {
					let responseModel = try JSONDecoder().decode(FirstStepResponseModel.self, from: data)
					
					shared.adInfoModel.period = responseModel.period
					shared.adInfoModel.cost = responseModel.creatives[0].maxPrice
					shared.adInfoModel.commission = responseModel.creatives[0].commission
					shared.adInfoModel.nonce = responseModel.nonce
					shared.adInfoModel.budgetId = responseModel.creatives[0].budgetId
					shared.adInfoModel.advertiserId = responseModel.creatives[0].advertiserId
					shared.adInfoModel.bidId = responseModel.creatives[0].bidId
					
					shared.getAd(advertiserURL: responseModel.creatives[0].advertiserURL, expectedHashes: responseModel.creatives[0].expectedHashes, budgetId: responseModel.creatives[0].budgetId, period: responseModel.period, nonce: responseModel.nonce)
				} catch {
					return
				}
			}) { (error) in
				print(error.message)
			}
			
			shared.didGetAdInfo = {
				CoreDataService.addNewAd(adInfo: shared.adInfoModel)
				didGetData(shared.adInfoModel)
			}
			
		}
		
	}
    
    private func getAd(advertiserURL: String, expectedHashes: [String], budgetId: Int, period: Int, nonce: Int) {
        let body: [String: Any] =
            [
                "expectedHashes": expectedHashes,
                "budgetId": budgetId,
                "timezone": AdHashManager.timeZone,
                "location": AdHashManager.location,
                "publisherId": AdHashManager.publisherID,
				"size": ["screenWidth": AdHashManager.screenWidth, "screenHeight": AdHashManager.screenHeight],
                "navigator": ["platform": AdHashManager.platform, "language": AdHashManager.language, "device": AdHashManager.device, "model": AdHashManager.model, "type": AdHashManager.type],
                "connection": AdHashManager.connection,
                "isp": AdHashManager.isp,
                "orientation": AdHashManager.orientation,
                "gps": AdHashManager.gps,
                "creatives": [["size": "\(Int(AdHashManager.bannerWidth))x\(Int(AdHashManager.bannerHeight))"]],
                "mobile": AdHashManager.isMobile,
                "blockedAdvertisers": AdHashManager.blockedAdvertisers,
                "currentTimestamp": AdHashManager.currentTimestamp,
                "recentAds": AdHashManager.recentAds,
                "period": period,
                "nonce": nonce
        ]
        
		guard let request = RequestBuilder.build(.post, baseUrl: advertiserURL, headersType: .typical, body: body, requestType: .none) else { return }
        
        NetworkManager.shared.perform(request, onSuccess: { (data) in
            do {
                let responseModel = try JSONDecoder().decode(GetAdResponseModel.self, from: data)
                let sha1Data = responseModel.data.sha1()
				
				let decodedData = Data(base64Encoded: responseModel.data.components(separatedBy: "base64,")[1], options: [])
				if let data = decodedData {
					if let decodedImage = UIImage(data: data) {
						AdHashManager.shared.adInfoModel.bannerImage = decodedImage
					}
				} else {
					print("error with decodedData")
				}
				
                if expectedHashes.contains(sha1Data) {
					AdHashManager.shared.adInfoModel.creativeHash = sha1Data
					self.decryptAdvertiserURL(encodedUrl: responseModel.url, period: period, nonce: nonce, adID: sha1Data)
                }
            } catch {
                return
            }
        }) { (error) in
            print(error.message)
        }
        
    }
    
	private func decryptAdvertiserURL(encodedUrl: String, period: Int, nonce: Int, adID: String) {
        let body: [String: Any] =
            [
                "timezone": AdHashManager.timeZone,
                "location": AdHashManager.location,
                "publisherId": AdHashManager.publisherID,
                "size": ["screenWidth": AdHashManager.screenWidth, "screenHeight": AdHashManager.screenHeight],
                "navigator": ["platform": AdHashManager.platform, "language": AdHashManager.language, "device": AdHashManager.device, "model": AdHashManager.model, "type": AdHashManager.type],
                "connection": AdHashManager.connection,
                "isp": AdHashManager.isp,
                "orientation": AdHashManager.orientation,
                "gps": AdHashManager.gps,
                "creatives": [["size": "\(Int(AdHashManager.bannerWidth))x\(Int(AdHashManager.bannerHeight))"]],
                "mobile": AdHashManager.isMobile,
                "blockedAdvertisers": AdHashManager.blockedAdvertisers,
                "currentTimestamp": AdHashManager.currentTimestamp,
                "recentAds": AdHashManager.recentAds,
                "period": period,
                "nonce": nonce
        ]
	
		let jsonString = body.dict2json().replacingOccurrences(of: "{}", with: "[]").sha1()
        
        DispatchQueue.main.async {
            let decryptionVC = DecryptionViewController()
			decryptionVC.encryptedURL = encodedUrl
			decryptionVC.decryptKey = jsonString
			decryptionVC.modalPresentationStyle = .overFullScreen
			decryptionVC.view.isHidden = true
			decryptionVC.delegate = self
            UIApplication.topViewController()?.present(decryptionVC, animated: false, completion: nil)
        }
        
    }
	
	private func callAnalyticsModule() {
		EventManager.sendAnalyticsRequest(type: .configuratedAd, adInfo: AdHashManager.shared.adInfoModel) {
			AdHashManager.shared.didGetAdInfo()
		}
	}
    
}

//MARK: - DecryptionDelegate
extension AdHashManager: DecryptionDelegate {
	func didGetDecrypted(content: String) {
		AdHashManager.shared.adInfoModel.bannerURL = content
		callAnalyticsModule()
	}
}
