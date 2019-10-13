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
            try Network.reachability = Reachability(hostname: "www.google.com")
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
        
        switch Network.reachability.status {
        case .unreachable:
            return "unreachable"
        case .wwan:
            let networkInfo = CTTelephonyNetworkInfo()
            let carrierType = networkInfo.serviceCurrentRadioAccessTechnology
            if carrierType!.first(where: { (_, value) in value.contains("CTRadioAccessTechnologyLTE") }) != nil {
                return "4G"
            }
            else if carrierType!.first(where: { (_, value) in value.contains("CTRadioAccessTechnologyGPRS") }) != nil || carrierType!.first(where: { (_, value) in value.contains("CTRadioAccessTechnologyEdge") }) != nil  || carrierType!.first(where: { (_, value) in value.contains("CTRadioAccessTechnologyCDMA1x") }) != nil {
                return "2G"
            }
            else if carrierType!.first(where: { (_, value) in value.contains("CTRadioAccessTechnologyWCDMA") }) != nil || carrierType!.first(where: { (_, value) in value.contains("CTRadioAccessTechnologyHSDPA") }) != nil  || carrierType!.first(where: { (_, value) in value.contains("CTRadioAccessTechnologyHSUPA") }) != nil || carrierType!.first(where: { (_, value) in value.contains("CTRadioAccessTechnologyCDMAEVDORev0") }) != nil  || carrierType!.first(where: { (_, value) in value.contains("CTRadioAccessTechnologyCDMAEVDORevA") }) != nil || carrierType!.first(where: { (_, value) in value.contains("CTRadioAccessTechnologyCDMAEVDORevB") }) != nil || carrierType!.first(where: { (_, value) in value.contains("CTRadioAccessTechnologyeHRPD") }) != nil  {
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
