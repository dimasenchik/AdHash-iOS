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

public struct AdHashConfig {
	var publisherID = ""
	var analyticsURL = ""
	var bidderURL = ""
	var publisherURL = ""
	var reportURL = ""
	var apiVersion = Float(0)
	
	public init(publisherID: String, analyticsURL: String, bidderURL: String, publisherURL: String, reportURL: String, apiVersion: Float) {
		self.publisherID = publisherID
		self.analyticsURL = analyticsURL
		self.bidderURL = bidderURL
		self.publisherURL = publisherURL
		self.reportURL = reportURL
		self.apiVersion = apiVersion
	}
}

open class AdHashManager {
    
    //MARK: - Properties
    public static var timeZone = TimeZone.current.secondsFromGMT()/3600
	public static var location = Bundle.main.bundleIdentifier ?? ""
    public static var publisherID = ""
    public static var screenWidth = UIScreen.main.bounds.width
    public static var screenHeight = UIScreen.main.bounds.height
    public static var platform = UIDevice.current.model
    public static var language = Locale.current.identifier
    private static var device = "Apple"
    public static var model: String {
		var systemInfo = utsname()
        uname(&systemInfo)
		let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }
		let stringCode = String.init(validatingUTF8: modelCode!)!
        return stringCode
    }
    public static var type: String {
        if UIDevice.current.model == "iPhone" {
            return "mobile"
        } else {
            return "tablet"
        }
    }
    public static var connection = ConnectionService.getConnectionType()
    public static var isp = ConnectionService.getCarrierName() ?? ""
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
            @unknown default:
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
    public static var bannerWidth = 0.0
    public static var bannerHeight = 0.0
    private static var isMobile: Bool = true
    public static var blockedAdvertisers: [String] = []
    public static var currentTimestamp = "\(Int(Date().timeIntervalSince1970))"
	public static var recentAds = CoreDataService.getRecentAds()
	public static var apiVersion: Float = 1.0
	
	//Configuration links
	public static var analyticsURL = ""
	public static var analyticsScreenShotURL = ""
	public static var bidderURL = ""
	public static var publisherURL = ""
	public static var reportURL = ""
	
	static let shared = AdHashManager()
	private var didGetAdInfo: () -> () = {}
	var adInfoModel = AdRequestModel()
    
    //MARK: - Public methods
	public static func setConfig(_ config: AdHashConfig) {
		AdHashManager.publisherID = config.publisherID
		AdHashManager.analyticsURL = config.analyticsURL
		AdHashManager.bidderURL = config.bidderURL
		AdHashManager.publisherURL = config.publisherURL
		AdHashManager.reportURL = config.reportURL
		AdHashManager.apiVersion = config.apiVersion
	}
	
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
            
            NetworkManager.shared.perform(request) { data, error in
                if let data = data {
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
                    
                    shared.didGetAdInfo = {
                        CoreDataService.addNewAd(adInfo: shared.adInfoModel)
                        didGetData(shared.adInfoModel)
                    }
                }
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
        
        NetworkManager.shared.perform(request) { [weak self] data, error in
            if let data = data {
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
                        self?.decryptAdvertiserURL(encodedUrl: responseModel.url, period: period, nonce: nonce, adID: sha1Data)
                    }
                } catch {
                    return
                }
            }
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
