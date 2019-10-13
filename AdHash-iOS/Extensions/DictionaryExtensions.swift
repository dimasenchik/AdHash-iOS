//
//  DictionaryExtensions.swift
//  LiqPaySwift
//
//  Created by Dima Senchik on 9/12/19.
//  Copyright © 2019 Dima Senchik. All rights reserved.
//

import Foundation

extension Dictionary {
    var json: String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .sortedKeys)
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? "Not a valid JSON"
        } catch {
            return "Not a valid JSON"
        }
    }
    
    func dict2json() -> String {
        return json
    }
    
    var queryString: String {
        var output: String = ""
        for (key,value) in self {
            output +=  "\(key)=\(value)&"
        }
        output = String(output.dropLast())
        return output
    }
}
