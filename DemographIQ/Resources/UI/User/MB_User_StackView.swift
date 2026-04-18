//
//  MB_User_StackView.swift
//
//  Created by BLIN Michael on 12/08/2025.
//

import UIKit
import SnapKit

public class MB_User_StackView : UIStackView {
	
	private lazy var backgroundShapeLayer:CAShapeLayer = {
		
		$0.fillColor = Colors.Primary.cgColor
		return $0
		
	}(CAShapeLayer())
    private var lastKnownLevel:Int?
    private lazy var imageView:MB_User_ImageView = .init()
    private lazy var userNameLabel:MB_Label = {
        
        $0.font = Fonts.Content.Title.H4
        $0.textColor = .white
        $0.numberOfLines = 1
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        return $0
        
    }(MB_Label(MB_User.current.name))
    private lazy var userBonusLabel:MB_Label = {
        
        $0.font = Fonts.Content.Text.Regular.withSize(Fonts.Size-2)
        $0.textColor = .white
        $0.textAlignment = .right
        return $0
        
    }(MB_Label(String(format: String(key: "user.bonus"), MB_User.current.bonus)))
    private lazy var userLevelLabel:MB_Label = {
        
        $0.font = Fonts.Content.Text.Regular.withSize(Fonts.Size-2)
        $0.textColor = .white
        $0.textAlignment = .right
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        return $0
        
    }(MB_Label(String(format: String(key: "user.level"), MB_User.current.level)))
    private lazy var progressView:MB_User_ProgressView = {
        
        $0.steps = 1
        return $0
        
    }(MB_User_ProgressView())
	
	public override init(frame: CGRect) {
	
		super.init(frame: frame)
		
		axis = .horizontal
        alignment = .center
		spacing = UI.Margins
		layer.addSublayer(backgroundShapeLayer)
		isLayoutMarginsRelativeArrangement = true
		layoutMargins = .init(horizontal: 2*UI.Margins)
		layoutMargins.bottom = safeAreaInsets.bottom + UI.Margins
		layoutMargins.top = 2*UI.Margins
        
        addArrangedSubview(imageView)
        
        let button:UIButton = .init()
        button.setImage(UIImage(systemName: "info.circle"), for: .normal)
        button.tintColor = .white
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.imageView?.contentMode = .scaleAspectFit
        button.addAction(.init(handler: { _ in
            
            MB_Feedback.shared.make(.On)
            MB_Audio.shared.playSound(.Button)
            
            MB_User_Name_Alert_ViewController().present()
            
        }), for: .touchUpInside)
        button.snp.makeConstraints { make in
            make.size.equalTo(1.25*UI.Margins)
        }
        
        let topStackView:MB_StackView = .init(arrangedSubviews: [userNameLabel,button,userLevelLabel,userBonusLabel])
        topStackView.axis = .horizontal
        topStackView.spacing = UI.Margins/2
        topStackView.alignment = .fill
        topStackView.distribution = .fill
        
        let contentStackView:MB_StackView = .init(arrangedSubviews: [topStackView,progressView])
        contentStackView.axis = .vertical
        contentStackView.spacing = UI.Margins
        addArrangedSubview(contentStackView)
        
        NotificationCenter.add(.updateUserName) { [weak self] _ in
            
            self?.userNameLabel.text = MB_User.current.name
        }
        
        NotificationCenter.add(.updateUserScore) { [weak self] _ in
            
            let currentLevel = MB_User.current.level
            let previousLevel = self?.lastKnownLevel
            self?.lastKnownLevel = currentLevel
            
            self?.userLevelLabel.text = String(format: String(key: "user.level"), currentLevel)
            self?.progressView.animateProgress(to: MB_User.current.levelProgress, duration: 1.0)
            
            if let previousLevel, currentLevel > previousLevel {
                
                self?.presentLevelUpAlert()
            }
        }
        
        NotificationCenter.post(.updateUserScore)
        
        NotificationCenter.add(.updateUserBonus) { [weak self] _ in
            
            self?.userBonusLabel.text = String(format: String(key: "user.bonus"), MB_User.current.bonus)
        }
        
        NotificationCenter.post(.updateUserBonus)
	}
	
	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func layoutSubviews() {
		
		super.layoutSubviews()
		
		let bezierPath = UIBezierPath()
		bezierPath.move(to: .init(x: 0, y: UI.Margins/2))
		bezierPath.addLine(to: .init(x: frame.size.width, y: 0))
		bezierPath.addLine(to: .init(x: frame.size.width, y: frame.size.height))
		bezierPath.addLine(to: .init(x: 0, y: frame.size.height))
		bezierPath.close()
		backgroundShapeLayer.path = bezierPath.cgPath
	}
    
    private func presentLevelUpAlert() {

        let user = MB_User.current
        user.bonus += 1
        user.save()
        user.saveLeaderboard { error in
            
            if let error {
                
                MB_Alert_ViewController.present(error)
            }
            else {
                
                NotificationCenter.post(.updateUserBonus)
                
                MB_Feedback.shared.make(.Success)
                MB_Audio.shared.playSound(.Success)
                
                let alertController = MB_Alert_ViewController()
                alertController.title = String(key: "user.levelUp.title")
                
                let levelText = String(format: String(key: "user.levelUp.body"), MB_User.current.level)
                let levelLabel = alertController.add(levelText)
                levelLabel.set(font: Fonts.Content.Text.Bold, string: "\(MB_User.current.level)")
                
                let bonusText = String(format: String(key: "user.levelUp.bonus.content"), String(key: "user.levelUp.bonus"), user.bonus)
                let bonusLabel = alertController.add(bonusText)
                bonusLabel.set(font: Fonts.Content.Text.Bold, string: String(key: "user.levelUp.bonus"))
                bonusLabel.set(font: Fonts.Content.Text.Bold, string: "\(user.bonus)")

                alertController.addDismissButton()
                alertController.present {
                    
                    MB_Confetti.start()
                }
                alertController.dismissHandler = {
                    
                    MB_Confetti.stop()
                }
            }
        }
    }
}
