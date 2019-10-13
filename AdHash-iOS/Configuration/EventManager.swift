//
//  EventManager.swift
//  OnlyTestADHASH
//
//  Created by Dima Senchik on 10/11/19.
//  Copyright © 2019 Dima Senchik. All rights reserved.
//

import Foundation
import UIKit

final class EventManager {
	
	enum TypeOfEvent {
		case configuratedAd
		case screenShot
		
		var analyticsURL: String {
			switch self {
			case .configuratedAd:
				return AdHashManager.analyticsURL
			case.screenShot:
				return AdHashManager.analyticsScreenShotURL
			}
		}
	}
	
	static func sendAnalyticsRequest(type: TypeOfEvent, adInfo: AdRequestModel, onSuccess: @escaping emptySuccess) {
		let parameters: [String: Any] = [
			"version": AdHashManager.apiVersion,
			"adTagId": adInfo.adTagId,
			"creativeHash": adInfo.creativeHash,
			"advertiserId": adInfo.advertiserId,
			"pageURL": AdHashManager.location,
			"platform": AdHashManager.platform,
			"connection": AdHashManager.connection,
			"isp": AdHashManager.isp,
			"orientation": AdHashManager.orientation,
			"gps": AdHashManager.gps,
			"language": AdHashManager.language,
			"device": "Apple",
			"model": AdHashManager.model,
			"type": AdHashManager.type,
			"screenWidth": AdHashManager.screenWidth,
			"screenHeight": AdHashManager.screenHeight,
			"timeZone": AdHashManager.timeZone,
			"width": AdHashManager.bannerWidth,
			"height": AdHashManager.bannerHeight,
			"period": adInfo.period,
			"cost": adInfo.cost,
			"commission": adInfo.commission,
			"nonce": adInfo.nonce,
			"pageview": true,
			"mobile": true
		]
		
		guard let request = RequestBuilder.build(.get, baseUrl: type.analyticsURL, headersType: .typical, queryItems: parameters.queryString, requestType: .none) else { return }
		
		NetworkManager.shared.perform(request, onSuccess: { (data) in
			onSuccess()
		}) { (error) in
			//error handling
		}
	}
	
	static func getClickableURL(adInfo: AdRequestModel, tapCoordinates: CGPoint, onSuccess: @escaping onSuccess<URL>) {
		//Decoded URL
		let parameters: [String: Any] = [
			"adTagId": adInfo.adTagId,
			"creativeHash": adInfo.creativeHash,
			"publisherId": AdHashManager.publisherID,
			"location": AdHashManager.location,
			"timeZone": AdHashManager.timeZone,
			"advertiserId": adInfo.advertiserId,
			"platform": AdHashManager.platform,
			"connection": AdHashManager.connection,
			"isp": AdHashManager.isp,
			"orientation": AdHashManager.orientation,
			"gps": AdHashManager.gps,
			"language": AdHashManager.language,
			"device": "Apple",
			"model": AdHashManager.model,
			"type": AdHashManager.type,
			"screenWidth": AdHashManager.screenWidth,
			"screenHeight": AdHashManager.screenHeight,
			"width": AdHashManager.bannerWidth,
			"height": AdHashManager.bannerHeight,
			"period": adInfo.period,
			"cost": adInfo.cost,
			"commission": adInfo.commission,
			"nonce": adInfo.nonce,
			"budgetId": adInfo.budgetId,
			"timeStamp": AdHashManager.currentTimestamp,
			"offsetX": Int(tapCoordinates.x),
			"offsetY": Int(tapCoordinates.y)
		]
		
		let encodedDecryptedString = "\(adInfo.bannerURL)&\(parameters.queryString)".URLEncoded
		
		//Bidder URL
		let bidderParameters: [String: Any] = [
			"version": AdHashManager.apiVersion,
			"url": encodedDecryptedString,
			"bidId": adInfo.bidId,
			"budgetId": adInfo.budgetId
		]
		
		let encodedBidderURL = "\(AdHashManager.bidderURL)&\(bidderParameters.queryString)".URLEncoded
		
		//Publisher URL
		let publisherParameters: [String: Any] = [
			"version": AdHashManager.apiVersion,
			"url": "\(encodedBidderURL)"
		]
		
		guard let finalPublisherURL = URL(string: "\(AdHashManager.publisherURL)&\(publisherParameters.queryString)") else { return }
		
		onSuccess(finalPublisherURL)
		
	}
	
}
