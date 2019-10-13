//
//  GetAdResponseModel.swift
//  OnlyTestADHASH
//
//  Created by Dima Senchik on 9/19/19.
//  Copyright © 2019 Dima Senchik. All rights reserved.
//

import Foundation

struct GetAdResponseModel: Codable {
    let status: String
    let url: String
    let data: String
    let width: Int
    let height: Int
}
