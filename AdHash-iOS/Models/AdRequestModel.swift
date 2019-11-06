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
	var adTagId = ""
	var creativeHash = ""
	var period = 0
	var advertiserId = ""
	var cost = CGFloat(0)
	var commission = CGFloat(0)
	var nonce = 0
	var budgetId = 0
	var bidId = 0
	var bannerImage = UIImage()
	var bannerURL = ""
}
