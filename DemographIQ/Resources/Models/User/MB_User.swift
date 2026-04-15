//
//  MB_User.swift
//
//  Created by BLIN Michael on 01/01/2026.
//

import Foundation

public class MB_User : Codable, Equatable {
	
	public var id:UUID = UUID()
	public var name:String?
	
	public static func == (lhs: MB_User, rhs: MB_User) -> Bool {
		
		return lhs.id == rhs.id
	}
}
