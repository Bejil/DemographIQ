//
//  MB_Error.swift
//
//  Created by BLIN Michael on 06/08/2023.
//

import Foundation

public class MB_Error : NSError, @unchecked Sendable {
	
	public convenience init(_ string:String?) {
		
		self.init(domain: Bundle.main.bundleIdentifier ?? "", code: 000, userInfo: [NSLocalizedDescriptionKey: string ?? ""])
	}
}
