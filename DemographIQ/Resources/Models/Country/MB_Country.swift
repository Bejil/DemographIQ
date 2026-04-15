//
//  MB_Country.swift
//  DemographIQ
//
//  Created by Michaël Blin on 25/03/2026.
//

import Foundation

nonisolated
public class MB_Country : Codable, Equatable {
    
    public static func == (lhs: MB_Country, rhs: MB_Country) -> Bool {
        
        return lhs.cca3 == rhs.cca3
    }
    
    public class Name : Codable {
        
        public var common:String?
    }
    
    public class Flags : Codable {
        
        public var png:String?
    }
    
    public var cca3:String?
    public var flags:Flags?
    public var name:Name?
    public var translations:[String:Name]?
    public var latlng:[Double]?
    public var capital:[String]?
    public var population:Int?
    public var area:Double?
}
