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
	var adTagId: String = ""
	var creativeHash: String = ""
	var period: Int = 0
	var advertiserId: String = ""
	var cost: CGFloat = 0
	var commission: CGFloat = 0
	var nonce: Int = 0
	var budgetId: Int = 0
	var bidId: Int = 0
	var bannerImage: UIImage = UIImage()
	var bannerURL: String = ""
}
