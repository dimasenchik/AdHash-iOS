//
//  AdHashViewDelegate.swift
//  OnlyTestADHASH
//
//  Created by Dima Senchik on 9/22/19.
//  Copyright © 2019 Dima Senchik. All rights reserved.
//

import Foundation
import UIKit

public protocol AdHashViewDelegate: UIViewController {
    func didClickOnAd(adId: String)
	func didClickOnReport(adId: String)
}
