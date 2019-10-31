//
//  AdRequestModel.swift
//  OnlyTestADHASH
//
//  Created by Dima Senchik on 10/12/19.
//  Copyright © 2019 Dima Senchik. All rights reserved.
//

import Foundation
import UIKit

final class AdRequestModel {
	var adTagId: String
	var creativeHash: String
	var period: Int
	var advertiserId: String
	var cost: CGFloat
	var commission: CGFloat
	var nonce: Int
	var budgetId: Int
	var bidId: Int
	var bannerImage: UIImage
	var bannerURL: String
	
	init(adTagId: String = "", creativeHash: String = "",
		 period: Int = 0,
		 advertiserId: String = "",
		 cost: CGFloat = 0,
		 commission: CGFloat = 0,
		 nonce: Int = 0,
		 budgetId: Int = 0,
		 bidId: Int = 0,
		 bannerImage: UIImage = UIImage(),
		 bannerURL: String = "") {
		self.adTagId = adTagId
		self.creativeHash = creativeHash
		self.period = period
		self.advertiserId = advertiserId
		self.cost = cost
		self.commission = commission
		self.nonce = nonce
		self.budgetId = budgetId
		self.bidId = bidId
		self.bannerImage = bannerImage
		self.bannerURL = bannerURL
	}
	
}
