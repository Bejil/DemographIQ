//
//  MB_ViewController.swift
//  RentUp
//
//  Created by BLIN Michael on 28/11/2025.
//

import UIKit
import SnapKit
import SpriteKit

public class MB_ViewController: UIViewController {

    public var isModal:Bool = false {
        
        didSet {
            
            navigationItem.leftBarButtonItem = nil
            
            if isModal && navigationController?.viewControllers.count ?? 0 < 2 {
                
                navigationItem.leftBarButtonItem = .init(image: UIImage(systemName: "xmark"), primaryAction: .init(handler: { [weak self] _ in
                    
                    MB_Feedback.shared.make(.Off)
                    MB_Audio.shared.playSound(.Button)
                    
                    self?.close()
                }))
            }
        }
    }
    public var isBackgroundAnimated:Bool = true {
        
        didSet {
            
            gradientBackgroundLayer.isHidden = !isBackgroundAnimated
            particulesView.isHidden = !isBackgroundAnimated
        }
    }
    private lazy var gradientBackgroundLayer:CAGradientLayer = {
        
        let initialColorTop = Colors.Background.View.Secondary.cgColor
        let initialColorBottom = Colors.Background.View.Primary.cgColor
        $0.colors = [initialColorTop, initialColorBottom]
        
        let midColorTop = Colors.Background.View.Primary.cgColor
        let midColorBottom = Colors.Background.View.Primary.cgColor
        let finalColorTop = Colors.Background.View.Primary.cgColor
        let finalColorBottom = Colors.Background.View.Secondary.cgColor
        
        let animation = CAKeyframeAnimation(keyPath: "colors")
        animation.values = [
            [initialColorTop, initialColorBottom],
            [midColorTop, midColorBottom],
            [finalColorTop, finalColorBottom]
        ]
        animation.keyTimes = [0.0, 0.5, 1.0]
        animation.duration = 15.0
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        $0.add(animation, forKey: "animateGradient")
        
        $0.startPoint = CGPoint(x: 0.0, y: 0.0)
        $0.endPoint = CGPoint(x: 1.0, y: 1.0)
        return $0
        
    }(CAGradientLayer())
    private lazy var particulesView:MB_Particules_View = {
        
        $0.isFade = false
        $0.scale = 0.75
        return $0
        
    }(MB_Particules_View())
    public lazy var contentStackView:MB_StackView = {
        
        $0.axis = .vertical
        $0.spacing = UI.Margins
        $0.isLayoutMarginsRelativeArrangement = true
        $0.layoutMargins = .init(2*UI.Margins)
        return $0
        
    }(MB_StackView())
    public lazy var contentScrollView:MB_ScrollView = {
        
        $0.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
        }
        return $0
        
    }(MB_ScrollView())
    
    public override func loadView() {
        
        super.loadView()
        
        view.backgroundColor = Colors.Background.View.Default
        view.layer.addSublayer(gradientBackgroundLayer)
        isBackgroundAnimated = true
        view.layer.addSublayer(particulesView.layer)
        
        let tapGestureRecognizer:UITapGestureRecognizer = .init { [weak self] sender in
            
            if let weakSelf = self {
                
                let touchLocation = sender.location(in: weakSelf.view)
                
                let view:UIView = .init()
                view.isUserInteractionEnabled = false
                weakSelf.view.addSubview(view)
                view.snp.makeConstraints { make in
                    make.centerX.equalTo(touchLocation.x)
                    make.centerY.equalTo(touchLocation.y)
                    make.size.equalTo(2*UI.Margins)
                }
                view.pulse() {
                    
                    view.removeFromSuperview()
                }
            }
        }
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
        
        let width = view.bounds.width
        let height = view.bounds.height
        let comets = [Comet(startPoint: CGPoint(x: 100, y: 0),
                            endPoint: CGPoint(x: 0, y: 100),
                            lineColor: Colors.Comets.Line,
                            cometColor: Colors.Comets.Tint),
                      Comet(startPoint: CGPoint(x: 0.4 * width, y: 0),
                            endPoint: CGPoint(x: width, y: 0.8 * width),
                            lineColor: Colors.Comets.Line,
                            cometColor: Colors.Comets.Tint),
                      Comet(startPoint: CGPoint(x: 0.8 * width, y: 0),
                            endPoint: CGPoint(x: width, y: 0.2 * width),
                            lineColor: Colors.Comets.Line,
                            cometColor: Colors.Comets.Tint),
                      Comet(startPoint: CGPoint(x: width, y: 0.2 * height),
                            endPoint: CGPoint(x: 0, y: 0.25 * height),
                            lineColor: Colors.Comets.Line,
                            cometColor: Colors.Comets.Tint),
                      Comet(startPoint: CGPoint(x: 0, y: height - 0.8 * width),
                            endPoint: CGPoint(x: 0.6 * width, y: height),
                            lineColor: Colors.Comets.Line,
                            cometColor: Colors.Comets.Tint),
                      Comet(startPoint: CGPoint(x: width - 100, y: height),
                            endPoint: CGPoint(x: width, y: height - 100),
                            lineColor: Colors.Comets.Line,
                            cometColor: Colors.Comets.Tint),
                      Comet(startPoint: CGPoint(x: 0, y: 0.8 * height),
                            endPoint: CGPoint(x: width, y: 0.75 * height),
                            lineColor: Colors.Comets.Line,
                            cometColor: Colors.Comets.Tint)]
        
        for comet in comets {
            view.layer.addSublayer(comet.drawLine())
            view.layer.addSublayer(comet.animate())
        }
        
        view.addSubview(contentScrollView)
        contentScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        UI.MainController.resignFirstResponder()
    }
    
    public override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        gradientBackgroundLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        particulesView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
    }
    
    public func close() {
        
        dismiss()
    }
    
    public func dismiss(_ completion:(()->Void)? = nil) {
        
        if navigationController?.viewControllers.count ?? 0 > 1 && !isModal {
            
            navigationController?.popViewController(animated: true)
            completion?()
        }
        else {
            
            dismiss(animated: true, completion: completion)
        }
    }
}
