//
//  MB_StackView.swift
//
//  Created by BLIN Michael on 20/01/2026.
//

import UIKit

public class MB_StackView : UIStackView {
	
	public var didUpdate:(()->Void)?
	
	public override func layoutSubviews() {
		
		super.layoutSubviews()
		
		didUpdate?()
	}
}
