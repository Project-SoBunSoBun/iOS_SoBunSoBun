//
//  KeyChain.swift
//  SoBunSoBun
//
//  Created by 허성필 on 9/5/25.
//

import Foundation
import OSLog

final class KeyChain {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "KeyChain"
    )
    
    static let shared = KeyChain()
    
    private init() {}
    
    // keyChain 저장 - C
    func set(key: String, value: String) {
        guard let valueData = value.data(using: .utf8) else {
            logger.critical("[KeyChain]\n\nvalue를 data형태로 변환 실패\n\nKEY: \(key)\nVALUE: \(value)")
            return
        }
        
        let saveData: CFDictionary = [kSecClass: kSecClassGenericPassword,
                                kSecAttrService: key,
                                 kSecReturnData: true,
                                  kSecValueData: valueData] as CFDictionary
        
        remove(key: key)
        
        let status = SecItemAdd(saveData, nil)
        
        // 성공 했을 때
        if status == errSecSuccess {
            logger.debug("[KeyChain]\n\n저장 성공\n\nKEY: \(key)\nVALUE: \(value)")
        } else { // 실패 했을 때
            logger.fault("[KeyChain]\n\n저장 실패\n\nKEY: \(key)\nVALUE: \(value)")
        }
    }
    
    // keyChain 값 출력 - R
    func get(key: String) -> String? {
        let savedData: CFDictionary = [kSecClass: kSecClassGenericPassword,
                                 kSecAttrService: key,
                                  kSecReturnData: true] as CFDictionary
        var searchWord: CFTypeRef? = nil
        let searchResult = SecItemCopyMatching(savedData, &searchWord)
        
        // 없으면 미출력
        if searchResult != errSecSuccess {
            return nil
        }
        
        let searchData: Data = searchWord as! Data
        
        return String(data: searchData, encoding: .utf8)
    }
    
    // keyChain 값 삭제 - D
    func remove(key: String) {
        let savedData: CFDictionary = [kSecClass: kSecClassGenericPassword,
                                 kSecAttrService: key,
                                  kSecReturnData: true] as CFDictionary
        
        let status = SecItemDelete(savedData)
        
        // 성공 했을 때
        if status == errSecSuccess {
            logger.debug("[KeyChain]\n\n삭제 성공\n\nKEY: \(key)")
        } else { // 실패 했을 때
            logger.fault("[KeyChain]\n\n삭제 실패\n\nKEY: \(key)")
        }
    }
}
