//
//  CharacterEextension.swift
//  Antlr.swift
//
//  Created by janyou on 15/9/4.
//  Copyright © 2015 jlabs. All rights reserved.
//

import Foundation

//extend Character so it can created from an int literal
/*extension Character: IntegerLiteralConvertible {
    public static func convertFromIntegerLiteral(value: IntegerLiteralType) -> Character {
        return Character(UnicodeScalar(value))
    }
}

//append a character to string with += operator
func += (inout left: String, right: Character) {
    left.append(right)
}*/

extension Character: IntegerLiteralConvertible {
    
    //"1" -> 1 "2"  -> 2
    var integerValue: Int {
        return Int(String(self)) ?? 0
    }
    public init(integerLiteral value: IntegerLiteralType) {
        self = Character(UnicodeScalar(value))
    }
    var utf8Value: UInt8 {
        for s in String(self).utf8 {
            return s
        }
        return 0
    }
    
    var utf16Value: UInt16 {
        for s in String(self).utf16 {
            return s
        }
        return 0
    }
    
    //char ->  int
    var unicodeValue: Int {
        for s in String(self).unicodeScalars {
            return Int(s.value)
        }
        return 0
    }
    
   public static var MAX_VALUE: Int{
        let c: Character = "\u{FFFF}"
        return c.unicodeValue
    }
   public static var MIN_VALUE: Int{
        let c: Character = "\u{0000}"
        return c.unicodeValue
    }
    
    public static func isJavaIdentifierStart(char: Int) -> Bool {
        let ch = Character(integerLiteral: char)
        return ch == "_" || ch == "$" || ("a" <= ch && ch <= "z")
                     || ("A" <= ch && ch <= "Z")
    
    }
    
    public static func isJavaIdentifierPart(char: Int) -> Bool {
      let ch = Character(integerLiteral: char)
      return isJavaIdentifierStart(char) || ("0" <= ch && ch <= "9")
    }
    public static func toCodePoint(high: Int,_ low: Int) -> Int {
        let MIN_SUPPLEMENTARY_CODE_POINT = 65536 // 0x010000
        let MIN_HIGH_SURROGATE = 0xd800 //"\u{dbff}"  //"\u{DBFF}"  //"\u{DBFF}"
        let MIN_LOW_SURROGATE =  0xdc00 //"\u{dc00}" //"\u{DC00}"
          return ((high << 10) + low) + (MIN_SUPPLEMENTARY_CODE_POINT
            - (MIN_HIGH_SURROGATE << 10)
            - MIN_LOW_SURROGATE)
    }

 


}
