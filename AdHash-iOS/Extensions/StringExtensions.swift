//
//  StringExtensions.swift
//  LiqPaySwift
//
//  Created by Dima Senchik on 9/12/19.
//  Copyright © 2019 Dima Senchik. All rights reserved.
//

import Foundation
import CommonCrypto

extension String {
	
    func base64Encoded() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
    
    func base64Decoded() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    func sha1() -> String {
        let data = Data(self.utf8)
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
	
	var URLEncoded: String {
		let unreservedChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"
		let unreservedCharset = CharacterSet(charactersIn: unreservedChars)
		let encodedString = self.addingPercentEncoding(withAllowedCharacters: unreservedCharset)
		return encodedString ?? self
	}

}

