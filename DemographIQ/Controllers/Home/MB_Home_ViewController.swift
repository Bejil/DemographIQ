//
//  MB_Home_ViewController.swift
//  Template
//
//  Created by Michaël Blin on 25/03/2026.
//

import UIKit
import SnapKit

public class MB_Home_ViewController : MB_ViewController {
    
    public override func loadView() {
        
        super.loadView()
        
        contentScrollView.isCentered = true
        contentScrollView.clipsToBounds = false
        
        let titleLabel:MB_Label = .init(String(key: "home.title.welcome"))
        titleLabel.font = Fonts.Content.Title.H1.withSize(Fonts.Size+50)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        contentStackView.addArrangedSubview(titleLabel)
        
        let totalPopulation = MB_Country.all?.compactMap({ $0.population }).reduce(0, +) ?? 0
        
        let subtitleLabel:MB_Label = MB_Label(String(key: "home.subtitle.welcome"))
        subtitleLabel.textAlignment = .center
        contentStackView.addArrangedSubview(subtitleLabel)
        
        if totalPopulation > 0 {
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.locale = Locale.current
            let formattedPopulation = formatter.string(from: NSNumber(value: totalPopulation)) ?? "\(totalPopulation)"
            
            let populationLabel = MB_Label(String(format: String(key: "home.subtitle.population.info"), formattedPopulation))
            populationLabel.textAlignment = .center
            populationLabel.numberOfLines = 0
            populationLabel.set(font: Fonts.Content.Text.Bold, string: "\(formattedPopulation) habitants")
            contentStackView.addArrangedSubview(populationLabel)
            
            contentStackView.setCustomSpacing(3*UI.Margins, after: populationLabel)
        }
        else {
            
            contentStackView.setCustomSpacing(3*UI.Margins, after: subtitleLabel)
        }
        
        let classicGameButton:MB_Button = .init(String(key: "home.game.classic.title")) { _ in
            
            let navigationController:MB_NavigationController = MB_NavigationController(rootViewController: MB_Game_Classic_ViewController())
            navigationController.navigationBar.prefersLargeTitles = false
            UI.MainController.present(navigationController, animated: true)
        }
        classicGameButton.image = UIImage(systemName: "gamecontroller")
        classicGameButton.subtitle = String(key: "home.game.classic.subtitle")
        contentStackView.addArrangedSubview(classicGameButton)
        
        let plusMinusGameButton:MB_Button = .init(String(key: "home.game.plusMinus.title")) { _ in
            
            let navigationController:MB_NavigationController = MB_NavigationController(rootViewController: MB_Game_PlusMinus_ViewController())
            navigationController.navigationBar.prefersLargeTitles = false
            UI.MainController.present(navigationController, animated: true)
        }
        plusMinusGameButton.type = .secondary
        plusMinusGameButton.image = UIImage(systemName: "plus.minus.capsule")
        plusMinusGameButton.subtitle = String(key: "home.game.plusMinus.subtitle")
        contentStackView.addArrangedSubview(plusMinusGameButton)
        
        let leaderboardButton:MB_Button = .init(String(key: "home.game.leaderboard.title")) { _ in
            
            UI.MainController.present(MB_NavigationController(rootViewController: MB_Leaderboard_ViewController()), animated: true)
        }
        leaderboardButton.type = .tertiary
        leaderboardButton.image = UIImage(systemName: "trophy")
        leaderboardButton.subtitle = String(key: "home.game.leaderboard.subtitle")
        contentStackView.addArrangedSubview(leaderboardButton)
        
        contentStackView.setCustomSpacing(2*UI.Margins, after: leaderboardButton)
        
        contentStackView.addArrangedSubview(MB_Settings_Button())
        
        let stackView:UIStackView = .init(arrangedSubviews: [contentScrollView,MB_User_StackView()])
        stackView.spacing = 2*UI.Margins
        stackView.axis = .vertical
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.right.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(UI.Margins)
            make.bottom.equalToSuperview()
        }
        
        NotificationCenter.add(.updateUserScore) { _ in
            
            classicGameButton.badge = nil
            
            let classicBestScore = MB_User.current.scores.classic
            
            if classicBestScore > 0 {
              
                classicGameButton.badge = String(format: String(key: "home.game.classic.record"), classicBestScore)
            }
            
            plusMinusGameButton.badge = nil
            
            let plusMinusBestScore = MB_User.current.scores.plusMinus
            
            if plusMinusBestScore > 0 {
              
                plusMinusGameButton.badge = String(format: String(key: "home.game.plusMinus.record"), plusMinusBestScore)
            }
        }
        
        NotificationCenter.post(.updateUserScore)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        contentStackView.animate()
    }
}
