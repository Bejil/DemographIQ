//
//  MB_Leaderboard_TableViewCell.swift
//
//  Created by BLIN Michael on 09/08/2025.
//

import UIKit
import SnapKit

public class MB_Leaderboard_TableViewCell : MB_TableViewCell {
	
	public override class var identifier: String {
		
		return "leaderboardTableViewCellIdentifier"
	}
    public var isUser:Bool = false {
        
        didSet {
        
            rankButton.type = isUser ? .tertiary : .primary
        }
    }
	public lazy var rankButton: MB_Button = {
		
		$0.isUserInteractionEnabled = false
		$0.setContentHuggingPriority(.init(1000), for: .horizontal)
        $0.type = isUser ? .tertiary : .primary
		return $0
		
	}(MB_Button())
    public lazy var nameLabel: MB_Label = {
		
		$0.font = Fonts.Content.Title.H4
		$0.numberOfLines = 1
		$0.adjustsFontSizeToFitWidth = true
		$0.minimumScaleFactor = 0.5
		return $0
		
	}(MB_Label())
	public lazy var scoreLabel: MB_Label = {
		
		$0.font = Fonts.Content.Text.Regular.withSize(Fonts.Size-2)
		return $0
		
	}(MB_Label())
	
	public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		let textStackView:UIStackView = .init(arrangedSubviews: [nameLabel,scoreLabel])
		textStackView.axis = .vertical
		textStackView.spacing = UI.Margins/2
		
		let stackView:UIStackView = .init(arrangedSubviews: [rankButton,textStackView])
		stackView.axis = .horizontal
		stackView.alignment = .center
		stackView.spacing = UI.Margins
		contentView.addSubview(stackView)
		stackView.snp.makeConstraints { make in
			make.left.right.equalToSuperview().inset(UI.Margins)
			make.top.bottom.equalToSuperview().inset(UI.Margins)
		}
	}
	
	@MainActor required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
