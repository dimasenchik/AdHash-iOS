//
//  FirstStepResponseModel.swift
//  OnlyTestADHASH
//
//  Created by Dima Senchik on 9/19/19.
//  Copyright © 2019 Dima Senchik. All rights reserved.
//

import Foundation
import UIKit

struct FirstStepResponseModel: Codable {
    let status: String
    let period: Int
    let nonce: Int
    let creatives: [CreativesResponseModel]
}

struct CreativesResponseModel: Codable {
    let advertiserId: String
    let advertiserURL: String
    let expectedHashes: [String]
    let maxPrice: CGFloat
    let commission: CGFloat
    let budgetId: Int
    let bidId: Int
}
