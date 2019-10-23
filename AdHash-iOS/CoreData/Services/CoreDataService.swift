//
//  CoreDataService.swift
//  AdHash-iOS
//
//  Created by Dima Senchik on 10/13/19.
//  Copyright © 2019 Dima Senchik. All rights reserved.
//

import Foundation
import CoreData

final class CoreDataService {
	
	//MARK: - Public methods
	static func addNewAd(adInfo: AdRequestModel) {
		let data = RecentAdModel(context: PersistenceService.context)
		data.viewedTimestamp = Int64(Date().timeIntervalSince1970)
		data.advertiserID = adInfo.advertiserId
		data.budgetID = Int64(adInfo.budgetId)
		data.adID = adInfo.creativeHash
		PersistenceService.saveContext()
	}
	
	static func getRecentAds() -> [[Any]] {
		let fetchRequest: NSFetchRequest<RecentAdModel> = RecentAdModel.fetchRequest()
		do {
			var availableAds: [[Any]] = []
			var adsToRemove: [RecentAdModel] = []
			let adsData = try PersistenceService.context.fetch(fetchRequest)
			adsData.forEach { (ad) in
				if ad.viewedTimestamp - Int64(Date().timeIntervalSince1970) > 86400 {
					adsToRemove.append(ad)
				} else {
					if let advertiserID = ad.advertiserID, let adID = ad.adID {
						availableAds.append([ad.viewedTimestamp, advertiserID, ad.budgetID, adID])
					}
				}
			}
			
			adsToRemove.forEach { (adToRemove) in
				PersistenceService.context.delete(adToRemove)
			}
			PersistenceService.saveContext()
			
			return availableAds
			
		} catch {
			return [[]]
		}
	}
	
}
