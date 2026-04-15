//
//  MB_Game_PlusMinus_ViewController.swift
//  DemographIQ
//
//  Created by Michaël Blin on 03/04/2026.
//

import UIKit
import SnapKit
import MapKit

public class MB_Game_PlusMinus_ViewController : MB_ViewController {
    
    private var totalScore: Int = 0 {
        
        didSet {
            
            if let bestScore = UserDefaults.get(.plusMinusGameBestScore) as? Int, totalScore > bestScore {
                
                UserDefaults.set(totalScore, .plusMinusGameBestScore)
                NotificationCenter.post(.plusMinusGameBestScore)
            }
            
            refreshScore()
        }
    }
    private var countries:[MB_Country] = .init()
    private let angleDelta = 1.5*UI.Margins
    private lazy var topMaskLayer = CAShapeLayer()
    private lazy var topView:UIView = {
        
        $0.backgroundColor = Colors.Primary
        $0.layer.mask = topMaskLayer
        
        $0.addSubview(topBackgroundMapView)
        topBackgroundMapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        $0.addSubview(topDimVisualEffectView)
        topDimVisualEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let stackView:MB_StackView = .init(arrangedSubviews: [topCountryStackView])
        stackView.axis = .horizontal
        stackView.alignment = .center
        $0.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(UI.Margins)
            make.left.right.equalToSuperview().inset(2*UI.Margins)
        }
        
        return $0
        
    }(UIView())
    private lazy var topDimVisualEffectView:UIVisualEffectView = .init(effect: UIBlurEffect(style: .dark))
    private lazy var topBackgroundMapView:MB_Country_MapView = .init()
    private lazy var topCountryStackView:MB_Country_StackView = {
        
        $0.isLayoutMarginsRelativeArrangement = true
        $0.populationTextField.isEnabled = false
        return $0
        
    }(MB_Country_StackView())
    private var topCountry:MB_Country? {
        
        didSet {
            
            if let topCountry {
                
                bottomCountry = countries.getNew(withSimilarPopulationTo: topCountry)
            }
            
            topCountryStackView.layoutMargins.top = navigationController?.navigationBar.frame.size.height ?? 0
            topCountryStackView.country = topCountry
            topCountryStackView.populationIsHidden = true
            topCountryStackView.nameLabel.textColor = Colors.Content.Text
            topDimVisualEffectView.alpha = 0.0
            topBackgroundMapView.country = topCountry
            
            bottomCountryStackView.nameLabel.textColor = Colors.Content.Text
            bottomDimVisualEffectView.alpha = 0.0
        }
    }
    private lazy var bottomMaskLayer = CAShapeLayer()
    private lazy var bottomView:UIView = {
        
        $0.backgroundColor = Colors.Primary
        $0.layer.mask = bottomMaskLayer
        
        $0.addSubview(bottomBackgroundMapView)
        bottomBackgroundMapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        $0.addSubview(bottomDimVisualEffectView)
        bottomDimVisualEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let stackView:MB_StackView = .init(arrangedSubviews: [bottomCountryStackView])
        stackView.axis = .horizontal
        stackView.alignment = .center
        $0.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(UI.Margins)
            make.left.right.equalToSuperview().inset(2*UI.Margins)
        }
        
        return $0
        
    }(UIView())
    private lazy var bottomDimVisualEffectView:UIVisualEffectView = .init(effect: UIBlurEffect(style: .dark))
    private lazy var bottomBackgroundMapView:MB_Country_MapView = .init()
    private lazy var bottomCountryStackView:MB_Country_StackView = {
        
        $0.isLayoutMarginsRelativeArrangement = true
        $0.populationTextField.isEnabled = false
        return $0
        
    }(MB_Country_StackView())
    private var bottomCountry:MB_Country? {
        
        didSet {
            
            topCountryStackView.nameLabel.textColor = Colors.Content.Text
            topDimVisualEffectView.alpha = 0.0
            
            bottomCountryStackView.layoutMargins.bottom = view.safeAreaInsets.bottom
            bottomCountryStackView.country = bottomCountry
            bottomCountryStackView.populationIsHidden = true
            bottomCountryStackView.nameLabel.textColor = Colors.Content.Text
            bottomDimVisualEffectView.alpha = 0.0
            bottomBackgroundMapView.country = bottomCountry
        }
    }
    private lazy var questionLabel:MB_Label = {
        
        $0.textColor = .white
        $0.font = Fonts.Content.Title.H1
        $0.textAlignment = .center
        $0.numberOfLines = 1
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.25
        $0.contentInsets = .init(horizontal: 2.5*UI.Margins, vertical: UI.Margins/2)
        $0.transform = CGAffineTransform(scaleX: 0, y: 0).concatenating(CGAffineTransform(rotationAngle: -3 * .pi / 180))
        return $0
        
    }(MB_Label(String(key: "game.plusMinus.label")))
    private lazy var nextStackView:MB_StackView = {
        
        $0.alpha = 0.0
        $0.axis = .vertical
        $0.spacing = UI.Margins/5
        $0.setCustomSpacing(-UI.Margins, after: nextTitleLabel)
        $0.isLayoutMarginsRelativeArrangement = true
        $0.layoutMargins = .init(horizontal: 2*UI.Margins, vertical: UI.Margins)
        $0.addGestureRecognizer(UITapGestureRecognizer(block: { [weak self] _ in
            
            MB_Feedback.shared.make(.On)
            MB_Audio.shared.playSound(.Button)
            
            self?.topCountry = self?.countries.getNew()
            self?.dismissResult()
        }))
        $0.snp.makeConstraints { make in
            make.size.equalTo(10*UI.Margins)
        }
        
        return $0
        
    }(MB_StackView(arrangedSubviews: [nextEmojiLabel,nextTitleLabel,nextSubtitleLabel]))
    private lazy var nextEmojiLabel:MB_Label = {
        
        $0.textAlignment = .center
        $0.font = Fonts.Content.Title.H1.withSize(Fonts.Size+50)
        return $0
        
    }(MB_Label())
    private lazy var nextTitleLabel:MB_Label = {
        
        $0.textAlignment = .center
        $0.font = Fonts.Content.Title.H1
        $0.textColor = .white
        $0.numberOfLines = 1
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.25
        return $0
        
    }(MB_Label())
    private lazy var nextSubtitleLabel:MB_Label = {
        
        $0.font = Fonts.Content.Text.Regular.withSize(Fonts.Size-2)
        $0.textColor = .white
        $0.textAlignment = .center
        return $0
        
    }(MB_Label(String(key: "game.plusMinus.next.subtitle.success")))
    
    public override func loadView() {
        
        super.loadView()
        
        isBackgroundAnimated = false
        view.backgroundColor = Colors.Primary
        isModal = true
        refreshScore()
        
        view.addSubview(topView)
        topView.snp.makeConstraints { make in
            make.height.equalToSuperview().dividedBy(2)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.snp.top)
        }
        
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.height.equalToSuperview().dividedBy(2)
            make.left.right.equalToSuperview()
            make.top.equalTo(view.snp.bottom)
        }
        
        view.addSubview(questionLabel)
        questionLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().inset(2*UI.Margins)
        }
        
        view.addSubview(nextStackView)
        nextStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        topCountry = countries.getNew()
        bottomCountry = countries.getNew()
        
        topView.addGestureRecognizer(UITapGestureRecognizer(block: { [weak self] _ in
           
            if let topPopulation = self?.topCountry?.population, let bottomPopulation = self?.bottomCountry?.population, topPopulation > bottomPopulation {
                
                self?.showResult(true)
            }
            else {
                
                self?.showResult(false)
            }
        }))
        
        bottomView.addGestureRecognizer(UITapGestureRecognizer(block: { [weak self] _ in
            
            if let topPopulation = self?.topCountry?.population, let bottomPopulation = self?.bottomCountry?.population, bottomPopulation > topPopulation {
                
                self?.showResult(true)
            }
            else {
                
                self?.showResult(false)
            }
        }))
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.68, initialSpringVelocity: 0.35, options: [.allowUserInteraction], animations: {
            
            self.questionLabel.transform = CGAffineTransform(rotationAngle: -3 * .pi / 180)
            
            self.topView.snp.remakeConstraints { make in
                make.height.equalToSuperview().dividedBy(2)
                make.left.right.equalToSuperview()
                make.bottom.equalTo(self.view.snp.centerY).offset(-self.angleDelta)
            }
            
            self.bottomView.snp.remakeConstraints { make in
                make.height.equalToSuperview().dividedBy(2)
                make.left.right.equalToSuperview()
                make.top.equalTo(self.view.snp.centerY).offset(self.angleDelta)
            }
            
            self.view.layoutIfNeeded()
        })
    }
    
    public override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        let topPath = UIBezierPath()
        topPath.move(to: CGPoint(x: 0, y: topView.frame.size.height))
        topPath.addLine(to: CGPoint(x: topView.frame.size.width, y: topView.frame.size.height - angleDelta))
        topPath.addLine(to: CGPoint(x: topView.frame.size.width, y: 0))
        topPath.addLine(to: CGPoint(x: 0, y: 0))
        topPath.close()
        topMaskLayer.path = topPath.cgPath
        
        let bottomPath = UIBezierPath()
        bottomPath.move(to: CGPoint(x: 0, y: angleDelta))
        bottomPath.addLine(to: CGPoint(x: bottomView.frame.size.width, y: 0))
        bottomPath.addLine(to: CGPoint(x: bottomView.frame.size.width, y: bottomView.frame.size.height))
        bottomPath.addLine(to: CGPoint(x: 0, y: bottomView.frame.size.height))
        bottomPath.close()
        bottomMaskLayer.path = bottomPath.cgPath
    }
    
    private func showResult(_ isSuccess:Bool) {
        
        UIView.animation {
            
            if self.topCountry?.population ?? 0 > self.bottomCountry?.population ?? 0 {
                
                self.bottomCountryStackView.nameLabel.textColor = .white
                self.bottomDimVisualEffectView.alpha = 1.0
            }
            else {
                
                self.topCountryStackView.nameLabel.textColor = .white
                self.topDimVisualEffectView.alpha = 1.0
            }
        }
        
        if isSuccess {
            
            totalScore += 1
            
            MB_Confetti.start()
            MB_Audio.shared.playSound(.Success)
            MB_Feedback.shared.make(.Success)
            
            UIApplication.wait(1.0) {
                
                MB_Confetti.stop()
            }
        }
        else {
            
            MB_Audio.shared.playSound(.Error)
            MB_Feedback.shared.make(.Error)
            
            topView.isUserInteractionEnabled = false
            bottomView.isUserInteractionEnabled = false
            nextStackView.isUserInteractionEnabled = true
            nextSubtitleLabel.isHidden = true
            
            UIApplication.wait(2.5) { [weak self] in
                
                let alertController = MB_Alert_ViewController()
                alertController.backgroundView.isUserInteractionEnabled = false
                alertController.title = String(key: "game.plusMinus.failure.alert.title")
                alertController.add(self?.totalScore ?? 0 > 0 ? String(format: String(key: "game.plusMinus.failure.alert.score"), self?.totalScore ?? 0) : String(key: "game.plusMinus.failure.alert.no_round_points"))
                alertController.addButton(title: String(key: "game.classic.back_menu.button")) { [weak self] _ in
                    
                    alertController.close { [weak self] in
                        
                        self?.dismiss()
                    }
                }
                alertController.present()
            }
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.68, initialSpringVelocity: 0.35, options: [.allowUserInteraction], animations: {
            
            self.view.backgroundColor = isSuccess ? Colors.Tertiary : Colors.Primary
            
            self.topView.snp.remakeConstraints { make in
                make.height.equalToSuperview().dividedBy(2)
                make.left.right.equalToSuperview()
                make.bottom.equalTo(self.view.snp.centerY).offset(-UI.Margins/10)
            }
            
            self.bottomView.snp.remakeConstraints { make in
                make.height.equalToSuperview().dividedBy(2)
                make.left.right.equalToSuperview()
                make.top.equalTo(self.view.snp.centerY).offset(UI.Margins/10)
            }
            
            self.view.layoutIfNeeded()
            
            self.questionLabel.alpha = 0.0
            self.questionLabel.transform = CGAffineTransform(scaleX: 0, y: 0).concatenating(CGAffineTransform(rotationAngle: -3 * .pi / 180))
            
            self.nextStackView.backgroundColor = isSuccess ? Colors.Tertiary : Colors.Primary
            self.nextEmojiLabel.text = String(key: "game.plusMinus.next.emoji.\(isSuccess ? "success" : "failure")")
            self.nextTitleLabel.text = String(key: "game.plusMinus.next.title.\(isSuccess ? "success" : "failure")")
            self.nextStackView.alpha = 1.0
            self.nextStackView.transform = CGAffineTransform(rotationAngle: -3 * .pi / 180)
            self.nextStackView.layer.cornerRadius = (10*UI.Margins)/2.0
        })
        
        topCountryStackView.layoutMargins.top = (navigationController?.navigationBar.frame.size.height ?? 0)/2
        topCountryStackView.showPopulation()
        
        bottomCountryStackView.layoutMargins.bottom = 0
        bottomCountryStackView.showPopulation()
    }
    
    public override func close() {
        
        let alert = MB_Alert_ViewController()
        alert.backgroundView.isUserInteractionEnabled = false
        alert.title = String(key: "game.plusMinus.quit.title")
        if totalScore > 0 {
            
            alert.add(String(format: String(key: "game.plusMinus.quit.message.scored"), totalScore))
        }
        else {
            
            alert.add(String(key: "game.plusMinus.quit.message.empty"))
        }
        
        let quitButton = alert.addButton(title: String(key: "game.plusMinus.quit.confirm")) { [weak self] _ in
            
            alert.close {
                
                self?.dismiss()
            }
        }
        quitButton.type = .delete
        
        alert.addCancelButton()
        
        alert.present()
    }
    
    private func dismissResult() {
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.68, initialSpringVelocity: 0.35, options: [.allowUserInteraction], animations: {
            
            self.view.backgroundColor = Colors.Primary
            
            self.topView.snp.remakeConstraints { make in
                make.height.equalToSuperview().dividedBy(2)
                make.left.right.equalToSuperview()
                make.bottom.equalTo(self.view.snp.centerY).offset(-self.angleDelta)
            }
            
            self.bottomView.snp.remakeConstraints { make in
                make.height.equalToSuperview().dividedBy(2)
                make.left.right.equalToSuperview()
                make.top.equalTo(self.view.snp.centerY).offset(self.angleDelta)
            }
            
            self.view.layoutIfNeeded()
            
            self.questionLabel.alpha = 1.0
            self.questionLabel.transform = CGAffineTransform(rotationAngle: -3 * .pi / 180)
            
            self.nextStackView.alpha = 0.0
            self.nextStackView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        })
    }
    
    private func refreshScore() {
        
        navigationItem.title = String(format: String(key: "game.plusMinus.score"), totalScore)
    }
}
