//
//  MB_TabBarController.swift
//  RentUp
//
//  Created by BLIN Michael on 20/01/2026.
//

import UIKit
import SnapKit

public class MB_TabBarController : UITabBarController {
	
	public override func loadView() {
		
		super.loadView()
        
		let appearance = UITabBarAppearance()
		appearance.configureWithOpaqueBackground()
        
        let normalAttributes:[NSAttributedString.Key: Any] = [.font: Fonts.TabBar.Default]
        let selectedAttributes:[NSAttributedString.Key: Any] = [.foregroundColor : Colors.TabBar.Selected, .font: Fonts.TabBar.Selected]
        let selectedColor: UIColor = Colors.TabBar.Selected
        let badgeColor: UIColor = Colors.TabBar.Badge
		
		appearance.compactInlineLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.compactInlineLayoutAppearance.normal.badgeBackgroundColor = badgeColor
        appearance.compactInlineLayoutAppearance.selected.titleTextAttributes = selectedAttributes
		appearance.compactInlineLayoutAppearance.selected.iconColor = selectedColor
        appearance.compactInlineLayoutAppearance.selected.badgeBackgroundColor = badgeColor
        
        appearance.inlineLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.inlineLayoutAppearance.normal.badgeBackgroundColor = badgeColor
        appearance.inlineLayoutAppearance.selected.titleTextAttributes = selectedAttributes
        appearance.inlineLayoutAppearance.selected.iconColor = selectedColor
        appearance.inlineLayoutAppearance.selected.badgeBackgroundColor = badgeColor
        
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.stackedLayoutAppearance.normal.badgeBackgroundColor = badgeColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes
        appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        appearance.stackedLayoutAppearance.selected.badgeBackgroundColor = badgeColor

		tabBar.standardAppearance = appearance
		tabBar.scrollEdgeAppearance = appearance
		delegate = self
	}
	
	override public var childForStatusBarStyle: UIViewController? {
		
		return self.selectedViewController
	}
}

extension MB_TabBarController : UITabBarControllerDelegate {
	
	public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
		
        MB_Feedback.shared.make(.On)
		
		return true
	}
}

