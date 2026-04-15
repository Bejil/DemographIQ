//
//  MB_Game_Classic_ViewController.swift
//  DemographIQ
//
//  Created by Michaël Blin on 25/03/2026.
//

import UIKit
import SnapKit
import MapKit

public class MB_Game_Classic_ViewController : MB_ViewController {
    
    private lazy var backgroundMapView:MB_Country_MapView = .init()
    private var digitLabels:[MB_Label] = []
    private var guessAttemptNumber: Int = 1
    private var totalScore: Int = 0 {
        
        didSet {
            
            let bestScore = MB_User.current.scores.classic
            
            if totalScore > bestScore {
                
                let user = MB_User.current
                user.scores.classic = totalScore
                user.save()
                user.saveLeaderboard()
                
                NotificationCenter.post(.updateUserScore)
            }
            
            refreshScore()
        }
    }
    private var country:MB_Country? {
        
        didSet {
            
            guessAttemptNumber = 1
            guessCountryStackView.country = country
            guessCountryStackView.populationTextField.becomeFirstResponder()
            backgroundMapView.country = country
        }
    }
    private var countries:[MB_Country] = .init()
    private lazy var guessCountryStackView:MB_Country_StackView = .init()
    private lazy var guessValidationButton:MB_Button = .init(String(key: "game.classic.validate.button")) { [weak self] _ in
      
        self?.checkResult()
    }
    private lazy var guessStackView:MB_StackView = {
        
        $0.axis = .vertical
        $0.spacing = 2*UI.Margins
        return $0
        
    }(MB_StackView(arrangedSubviews: [guessCountryStackView,guessValidationButton]))
    
    public override func loadView() {
        
        super.loadView()
        
        isBackgroundAnimated = false
        isModal = true
        
        view.insertSubview(backgroundMapView, at: 0)
        backgroundMapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentScrollView.isCentered = true
        contentStackView.addArrangedSubview(guessStackView)
        refreshScore()
        
        NotificationCenter.add(UIResponder.keyboardWillShowNotification) { [weak self] notification in
            
            if let self, let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                
                let keyboardInView = view.convert(keyboardFrame, from: nil)
                let bottomInset = max(0, keyboardInView.height - view.safeAreaInsets.bottom) + UI.Margins
                
                UIView.animation {
                    
                    self.contentScrollView.snp.updateConstraints({ make in
                        
                        make.bottom.equalToSuperview().inset(bottomInset)
                    })
                }
            }
        }
        
        NotificationCenter.add(UIResponder.keyboardWillHideNotification) { [weak self] _ in
            
            UIView.animation {
                
                self?.contentScrollView.snp.updateConstraints({ make in
                    
                    make.bottom.equalToSuperview()
                })
            }
        }
        
        country = countries.getNew()
    }
    
    public override func close() {
        
        guessCountryStackView.populationTextField.resignFirstResponder()
        
        let alert = MB_Alert_ViewController()
        alert.backgroundView.isUserInteractionEnabled = false
        alert.title = String(key: "game.classic.quit.title")
        if totalScore > 0 {
            
            alert.add(String(format: String(key: "game.classic.quit.message.scored"), totalScore))
        }
        else {
            
            alert.add(String(key: "game.classic.quit.message.empty"))
        }
        
        let quitButton = alert.addButton(title: String(key: "game.classic.quit.confirm")) { [weak self] _ in
            
            alert.close {
                
                self?.dismiss()
            }
        }
        quitButton.type = .delete
        
        alert.addCancelButton()
        
        alert.present()
    }
    
    private func checkResult() {
        
        guessCountryStackView.populationTextField.resignFirstResponder()
        
        guard let country else { return }
        
        let playerAnswer = guessCountryStackView.fillMissingPopulationDigitsWithZero()
        let result = country.getResult(for: playerAnswer)
        
        switch result {
        case .great, .good:
            presentWinAlert(country: country, result: result, playerAnswer: playerAnswer)
        case .far:
            if guessAttemptNumber == 1 {
                presentFarFirstAttemptHint(country: country, playerAnswer: playerAnswer)
            }
            else {
                presentLoseAndReturnToMenu(country: country)
            }
        }
    }
    
    private func presentWinAlert(country: MB_Country, result: MB_Country.GuessResult, playerAnswer: Int) {
        
        let earnedPoints = Self.pointsEarnedForWin(result: result, attemptNumber: guessAttemptNumber)
        totalScore += earnedPoints
        
        let alertController = MB_Alert_ViewController()
        alertController.backgroundView.isUserInteractionEnabled = false
        alertController.title = String(key: "game.classic.alert.title.\(result.rawValue)")
        
        alertController.add(String(key: "game.classic.alert.body.\(result.rawValue)"))
        
        let earnedLine = String(format: String(key: "game.classic.score.earned"), earnedPoints)
        let earnedLabel = alertController.add(earnedLine)
        earnedLabel.set(font: Fonts.Content.Text.Bold, string: "\(earnedPoints)")
        
        let populationLabel = alertController.add(String(format: String(key: "game.classic.alert.body.population.total"), country.localizedName, country.formattedPopulation))
        populationLabel.set(font: Fonts.Content.Text.Bold, string: country.localizedName)
        populationLabel.set(font: Fonts.Content.Text.Bold, string: country.formattedPopulation)
        
        let referencePopulation = max(1, country.population ?? 0)
        let relativeErrorPercent = abs(Double(playerAnswer - (country.population ?? 0))) / Double(referencePopulation) * 100
        let diffPercentageLabel = alertController.add(String(format: String(key: "game.classic.alert.body.diff.percentage"), "\(Int(relativeErrorPercent))"))
        diffPercentageLabel.set(font: Fonts.Content.Text.Bold, string: "\(Int(relativeErrorPercent))")
        
        let liquidView:MB_Liquid_View = .init(color: Colors.Primary)
        alertController.backgroundView.addSubview(liquidView)
        liquidView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        liquidView.startFill(duration: 1.0)
        
        alertController.addButton(title: String(key: "game.classic.next_country")) { [weak self] _ in
            
            alertController.close()
            MB_Confetti.stop()
            self?.advanceToNextCountry()
        }
        alertController.present {
            
            if result == .great {
                
                MB_Confetti.start()
            }
        }
        alertController.dismissHandler = {
            
            liquidView.startDrain(duration: 1.0)
        }
    }
    
    private func presentFarFirstAttemptHint(country: MB_Country, playerAnswer: Int) {
        
        MB_Feedback.shared.make(.Error)
        
        let population = country.population ?? 0
        
        let alertController = MB_Alert_ViewController()
        alertController.backgroundView.isUserInteractionEnabled = false
        alertController.title = String(key: "game.classic.hint.title")
        if population <= 0 {
            
            alertController.add(String(key: "game.classic.hint.body.unknown"))
        }
        else {
            
            let needsHigher = playerAnswer < population
            let bodyKey = needsHigher ? "game.classic.hint.body.higher" : "game.classic.hint.body.lower"
            alertController.add(String(key: bodyKey))
        }
        
        alertController.addButton(title: String(key: "game.classic.retry.button")) { [weak self] _ in
            
            alertController.close()
            self?.guessAttemptNumber = 2
            self?.guessCountryStackView.country = self?.country
            self?.guessCountryStackView.populationTextField.becomeFirstResponder()
        }
        alertController.present()
    }
    
    private func presentLoseAndReturnToMenu(country: MB_Country) {
        
        MB_Feedback.shared.make(.Error)
        MB_Confetti.stop()
        
        let alertController = MB_Alert_ViewController()
        alertController.backgroundView.isUserInteractionEnabled = false
        alertController.title = String(key: "game.classic.lose.title")
        
        let loseBody = String(format: String(key: "game.classic.lose.body"), country.localizedName, country.formattedPopulation)
        let loseLabel = alertController.add(loseBody)
        loseLabel.set(font: Fonts.Content.Text.Bold, string: country.localizedName)
        loseLabel.set(font: Fonts.Content.Text.Bold, string: country.formattedPopulation)
        
        alertController.addButton(title: String(key: "game.classic.back_menu.button")) { [weak self] _ in
            
            alertController.close()
            self?.dismiss()
        }
        alertController.present()
    }
    
    private func refreshScore() {
        
        navigationItem.title = String(format: String(key: "game.classic.score"), totalScore)
    }
    
    /// Règle de points (uniquement si la manche est gagnée : `.great` ou `.good`, comme `getResult`) :
    /// - Excellence (écart relatif inférieur à 10 %) : 100 pts au 1er essai, 60 pts au 2ᵉ après indice.
    /// - Bon (écart relatif entre 10 % et 50 %) : 45 pts au 1er essai, 25 pts au 2ᵉ.
    private static func pointsEarnedForWin(result: MB_Country.GuessResult, attemptNumber: Int) -> Int {
        
        let firstTry = (attemptNumber == 1)
        switch result {
        case .great:
            return firstTry ? 100 : 60
        case .good:
            return firstTry ? 45 : 25
        case .far:
            return 0
        }
    }
    
    private func advanceToNextCountry() {
        
        if let next = countries.getNew() {
            
            country = next
        }
        else {
            
            countries.removeAll()
            country = countries.getNew()
        }
    }
}
