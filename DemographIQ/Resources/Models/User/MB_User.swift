//
//  MB_User.swift
//
//  Created by BLIN Michael on 01/01/2026.
//

import Foundation

public class MB_User : Codable, Equatable {
    
    public class Scores : Codable {
     
        public var classic:Int = 0
        public var plusMinus:Int = 0
    }
	
	public var id:UUID = UUID()
	public var name:String?
    public var scores:Scores = .init()
    public var bonus:Int = 5
    public var points:Int = 0
	
	public static func == (lhs: MB_User, rhs: MB_User) -> Bool {
		
		return lhs.id == rhs.id
	}
}
