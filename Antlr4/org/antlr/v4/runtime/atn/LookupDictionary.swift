//
//  LookupDictionary.swift
//   antlr.swift
//
//  Created by janyou on 15/9/23.
//  Copyright © 2015 jlabs. All rights reserved.
//

import Foundation

public enum LookupDictionaryType: Int {
    case Lookup = 0
    case Ordered
}

public struct LookupDictionary {
    private var type: LookupDictionaryType
//    private var cache: HashMap<Int, [ATNConfig]> = HashMap<Int, [ATNConfig]>()
//   
    private var cache: HashMap<Int, ATNConfig> = HashMap<Int, ATNConfig>()
    public init(type: LookupDictionaryType = LookupDictionaryType.Lookup) {
        self.type = type
    }

    private func hash(config: ATNConfig) -> Int {
        if type == LookupDictionaryType.Lookup {

            var hashCode: Int = 7
            hashCode = 31 * hashCode + config.state.stateNumber
            hashCode = 31 * hashCode + config.alt
            hashCode = 31 * hashCode + config.semanticContext.hashValue
            return hashCode

        } else {
            //Ordered
            return config.hashValue
        }
    }

    private func equal(lhs: ATNConfig, _ rhs: ATNConfig) -> Bool {
        if type == LookupDictionaryType.Lookup {
            if lhs === rhs {
                return true
            }


            let same: Bool =
            lhs.state.stateNumber == rhs.state.stateNumber &&
                    lhs.alt == rhs.alt &&
                    lhs.semanticContext == rhs.semanticContext

            return same

        } else {
            //Ordered
            return lhs == rhs
        }
    }

//    public mutating func getOrAdd(config: ATNConfig) -> ATNConfig {
//
//        let h = hash(config)
//        
//        if let configList = cache[h] {
//            let length = configList.count
//            for i in 0..<length {
//                if equal(configList[i], config) {
//                    return configList[i]
//                }
//            }
//            cache[h]!.append(config)
//        } else {
//            cache[h] = [config]
//        }
//
//        return config
//
//    }
        public mutating func getOrAdd(config: ATNConfig) -> ATNConfig {
    
            let h = hash(config)
    
            if let configList = cache[h] {
                return configList
            } else {
                cache[h] = config
            }
    
            return config
    
        }
    public var isEmpty: Bool {
        return cache.isEmpty
    }

//    public func contains(config: ATNConfig) -> Bool {
//
//        let h = hash(config)
//        if let configList = cache[h] {
//            for c in configList {
//                if equal(c, config) {
//                    return true
//                }
//            }
//        }
//
//        return false
//
//    }
    public func contains(config: ATNConfig) -> Bool {
        
        let h = hash(config)
        if let _ = cache[h] {
            return true
        }
        
        return false
        
    }
    public mutating func removeAll() {
        cache.clear() 
    }

}



 