//
//  MB_Country_StackView.swift
//  DemographIQ
//
//  Created by Michaël Blin on 06/04/2026.
//

import UIKit
import SnapKit

public class MB_Country_StackView : MB_StackView {
    
    public var populationIsHidden:Bool = false {
        
        didSet {
            
            populationContainerView.isHidden = populationIsHidden
        }
    }
    public var country: MB_Country? {
        
        didSet {
            
            imageView.url = country?.flags?.png
            nameLabel.text = country?.localizedName
            setupPopulationBoxes()
        }
    }
    private lazy var imageView:MB_ImageView = {
        
        $0.snp.makeConstraints { make in
            make.height.equalTo(3*UI.Margins)
            make.height.equalTo(6*UI.Margins)
        }
        return $0
        
    }(MB_ImageView())
    public lazy var nameLabel:MB_Label = {
        
        $0.font = Fonts.Content.Title.H1
        $0.textAlignment = .center
        $0.numberOfLines = 1
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.25
        return $0
        
    }(MB_Label())
    private var populationDigitLabels:[MB_Label] = []
    public lazy var populationTextField:UITextField = {
        
        $0.keyboardType = .numberPad
        $0.textContentType = .oneTimeCode
        $0.textColor = .clear
        $0.tintColor = .clear
        $0.addAction(.init(handler: { [weak self] _ in
            
            if let self {
                
                let populationCount = String(self.country?.population ?? 0).count
                let rawText = self.populationTextField.text ?? ""
                let digitsOnly = rawText.filter(\.isNumber)
                let limited = String(digitsOnly.prefix(populationCount))
                
                if limited != rawText {
                    
                    self.populationTextField.text = limited
                }
                self.updatePopulationBoxes(with: limited)
            }
            
        }), for: .editingChanged)
        return $0
        
    }(UITextField())
    private lazy var populationContainerView:UIView = {
        
        $0.addSubview(populationStackView)
        populationStackView.snp.makeConstraints { make in
            
            make.edges.equalToSuperview()
        }
        
        $0.addSubview(populationTextField)
        populationTextField.snp.makeConstraints { make in
            
            make.edges.equalToSuperview()
        }
        
        return $0
        
    }(UIView())
    private lazy var populationStackView:MB_StackView = {
        
        $0.axis = .horizontal
        $0.spacing = UI.Margins/3
        $0.distribution = .fillEqually
        return $0
        
    }(MB_StackView())
    
    public override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        axis = .vertical
        spacing = 1.5*UI.Margins
        addArrangedSubview(imageView)
        addArrangedSubview(nameLabel)
        addArrangedSubview(populationContainerView)
    }
    
    @MainActor required init(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    public func fillMissingPopulationDigitsWithZero() -> Int {
        
        let digitCount = max(1, String(country?.population ?? 0).count)
        let digitsOnly = (populationTextField.text ?? "").filter(\.isNumber)
        let limited = String(digitsOnly.prefix(digitCount))
        let padded = limited.padding(toLength: digitCount, withPad: "0", startingAt: 0)
        
        populationTextField.text = padded
        updatePopulationBoxes(with: padded)
        return Int(padded) ?? 0
    }
    
    private func setupPopulationBoxes() {
        
        populationTextField.text = ""
        populationDigitLabels.removeAll()
        let baseSpacing = UI.Margins/3
        let doubleSpacing = 2.5*baseSpacing
        let digitCount = String(country?.population ?? 0).count
        
        populationStackView.arrangedSubviews.forEach { view in
            
            populationStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        for index in 0..<digitCount {
            
            let label:MB_Label = .init()
            label.textAlignment = .center
            label.font = Fonts.Content.Title.H3
            label.layer.cornerRadius = UI.CornerRadius/2
            label.textColor = .white
            label.backgroundColor = Colors.Primary.withAlphaComponent(0.2)
            label.snp.makeConstraints { make in
                make.height.equalTo(Fonts.Content.Title.H4.pointSize + 1.5*UI.Margins)
            }
            populationDigitLabels.append(label)
            populationStackView.addArrangedSubview(label)
            
            let rightDigitsCount = digitCount - (index + 1)
            if rightDigitsCount > 0 && rightDigitsCount % 3 == 0 {
                populationStackView.setCustomSpacing(doubleSpacing, after: label)
            } else {
                populationStackView.setCustomSpacing(baseSpacing, after: label)
            }
        }
        
        updatePopulationBoxes(with: "")
    }
    
    private func updatePopulationBoxes(with text: String) {
        
        for (index, label) in populationDigitLabels.enumerated() {
            
            if index < text.count {
                
                let char = text[text.index(text.startIndex, offsetBy: index)]
                label.text = String(char)
                label.backgroundColor = Colors.Secondary
            }
            else {
                
                label.text = ""
                label.backgroundColor = Colors.Primary.withAlphaComponent(0.2)
            }
        }
    }
    
    public func showPopulation() {
        
        populationIsHidden = false
        
        let populationString = String(country?.population ?? 0)
        populationTextField.text = populationString
        updatePopulationBoxes(with: populationString)
    }
}
