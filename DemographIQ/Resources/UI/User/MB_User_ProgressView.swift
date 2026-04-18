//
//  MB_User_ProgressView.swift
//  LettroLine
//
//  Created by BLIN Michael on 18/08/2025.
//

import UIKit
import SnapKit

public class MB_User_ProgressView : UIProgressView {
	
	public var steps:Int = 0 {
		
		didSet {
			
			stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
			stackView.addArrangedSubview(.init())
			
			let dotHeight = 1.25*UI.Margins
			
			for _ in 0..<steps {
				
				let imageView:UIImageView = .init()
				imageView.backgroundColor = .white
				imageView.layer.cornerRadius = dotHeight/2
				imageView.snp.makeConstraints { make in
					make.size.equalTo(dotHeight)
				}
				stackView.addArrangedSubview(imageView)
                
                let contentImageView:UIImageView = .init()
                contentImageView.image = UIImage(systemName: "star.fill")
                contentImageView.tintColor = Colors.Tertiary
                contentImageView.contentMode = .scaleAspectFit
                imageView.addSubview(contentImageView)
                contentImageView.snp.makeConstraints { make in
                    make.edges.equalToSuperview().inset(3)
                }
			}
		}
	}
	private var stackView:UIStackView = {
		
		$0.axis = .horizontal
		$0.distribution = .equalCentering
		$0.alignment = .center
		return $0
		
	}(UIStackView())
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		progressTintColor = Colors.Tertiary
		trackTintColor = Colors.Tertiary.withAlphaComponent(0.2)
		progressViewStyle = .bar
		snp.makeConstraints { make in
			make.height.equalTo(UI.Margins/2)
		}
		
		addSubview(stackView)
		stackView.snp.makeConstraints { make in
            make.centerY.left.right.equalToSuperview()
		}
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
	
	private func updateDots(for progress: Float) {
		
		let imageViews = stackView.arrangedSubviews.compactMap({ $0 as? UIImageView })
		
		for i in 0..<imageViews.count {
			
			let threshold = Float(i + 1) / Float(imageViews.count)
			let justCompleted = progress >= threshold && progress < threshold + 0.01
			
			if justCompleted {
				
                imageViews[i].pulse(.white)
                MB_Feedback.shared.make(.On)
			}
		}
	}
	
	public func animateProgress(to target: Float, duration: TimeInterval) {
		
		let steps: Int = 60
		let stepDuration = duration / Double(steps)
		let start = progress
		let delta = target - start
		
		var currentStep = 0
		
		Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { [weak self] timer in
			
			currentStep += 1
			
			let newProgress = start + delta * Float(currentStep) / Float(steps)
			self?.progress = newProgress
			self?.setProgress(newProgress, animated: false)
			self?.updateDots(for: newProgress)
			
			if currentStep >= steps {
				
				timer.invalidate()
			}
		}
	}
}
