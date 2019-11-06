//
//  ConnectionService.swift
//  AdHashSDK
//
//  Created by Dima Senchik on 9/18/19.
//  Copyright © 2019 Dima Senchik. All rights reserved.
//

import Foundation
import CoreTelephony

final class ConnectionService {
	
	static func getConnectionType() -> String {
		do {
			try Network.reachability = Reachability(hostname: "www.bidder.adhash.org/protocol.php")
		}
		catch {
			switch error as? Network.Error {
			case let .failedToCreateWith(hostname)?:
				print("Network error:\nFailed to create reachability object With host named:", hostname)
			case let .failedToInitializeWith(address)?:
				print("Network error:\nFailed to initialize reachability object With address:", address)
			case .failedToSetCallout?:
				print("Network error:\nFailed to set callout")
			case .failedToSetDispatchQueue?:
				print("Network error:\nFailed to set DispatchQueue")
			case .none:
				print(error)
			}
		}
		
		let networkInfo = CTTelephonyNetworkInfo()
		let carrierType = networkInfo.currentRadioAccessTechnology
		switch Network.reachability.status {
		case .unreachable:
			return "unreachable"
		case .wwan:
			if carrierType == "CTRadioAccessTechnologyLTE" {
				return "4G"
			}
			else if carrierType == "CTRadioAccessTechnologyGPRS" || carrierType == "CTRadioAccessTechnologyEdge" || carrierType == "CTRadioAccessTechnologyCDMA1x" {
				return "2G"
			}
			else if carrierType == "CTRadioAccessTechnologyWCDMA" || carrierType == "CTRadioAccessTechnologyHSDPA" || carrierType == "CTRadioAccessTechnologyHSUPA" || carrierType == "CTRadioAccessTechnologyCDMAEVDORev0" || carrierType == "CTRadioAccessTechnologyCDMAEVDORevA" || carrierType == "CTRadioAccessTechnologyCDMAEVDORevB" || carrierType == "CTRadioAccessTechnologyeHRPD" {
				return "3G"
			}
		case .wifi:
			return "WiFi"
		}
		
		return ""
	}
    
    static func getCarrierName() -> String? {
        let networkInfo = CTTelephonyNetworkInfo()
        if let carrier = networkInfo.subscriberCellularProvider {
            return carrier.carrierName
        } else {
            return nil
        }
    }
    
}
