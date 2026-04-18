//
//  MB_User_ImageView.swift
//
//  Created by BLIN Michael on 12/08/2025.
//

import UIKit
import SnapKit

public class MB_User_ImageView : UIImageView {
	
	init() {
		
		super.init(frame: .zero)
		
		contentMode = .scaleAspectFill
		clipsToBounds = true
		layer.masksToBounds = true
		layer.borderWidth = 3
		layer.borderColor = UIColor.white.cgColor
		
		let height = 4*UI.Margins
		snp.makeConstraints { make in
			make.size.equalTo(height)
		}
		layer.cornerRadius = height/2
		
		loadAvatar()
        
        NotificationCenter.add(.updateUserName) { [weak self] _ in
            
            self?.loadAvatar()
        }
	}
	
	public func loadAvatar() {
		
        MB_BoringAvatar.get(for: MB_User.current.name) { [weak self] image in
            
            DispatchQueue.main.async {
                
                if let image = image {
                    
                    self?.image = image
                }
            }
        }
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func layoutSubviews() {
		
		super.layoutSubviews()
		
		loadAvatar()
	}
}
