//
//  MB_Settings_Button.swift
//  LettroLine
//
//  Created by BLIN Michael on 22/08/2025.
//

import UIKit

public class MB_Settings_Button : MB_Button {
	
	private var settingsMenu:UIMenu {
		
		return .init(children: [
			UIMenu(options: .displayInline, children: [
                
                UIAction(title: String(key: "settings.button.sounds"), subtitle: String(key: "settings.button.sounds." + (MB_Audio.shared.isSoundsEnabled ? "on" : "off")), image: UIImage(systemName: MB_Audio.shared.isSoundsEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill"), handler: { [weak self] _ in
                    
                    UserDefaults.set(!MB_Audio.shared.isSoundsEnabled, .soundsEnabled)
                    
                    MB_Audio.shared.playSound(.Button)
                    
                    self?.menu = self?.settingsMenu
                }),
                UIAction(title: String(key: "settings.button.music"), subtitle: String(key: "settings.button.music." + (MB_Audio.shared.isMusicEnabled ? "on" : "off")), image: UIImage(systemName: MB_Audio.shared.isMusicEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill"), handler: { [weak self] _ in
                    
                    UserDefaults.set(!MB_Audio.shared.isMusicEnabled, .musicEnabled)
                    
                    MB_Audio.shared.playSound(.Button)
                    
                    MB_Audio.shared.isMusicEnabled ? MB_Audio.shared.playMusic() : MB_Audio.shared.stopMusic()
                    
                    self?.menu = self?.settingsMenu
                }),
                UIAction(title: String(key: "settings.button.vibrations"), subtitle: String(key: "settings.button.vibrations." + (MB_Feedback.shared.isVibrationsEnabled ? "on" : "off")), image: UIImage(systemName: MB_Feedback.shared.isVibrationsEnabled ? "water.waves" : "water.waves.slash"), handler: { [weak self] _ in
                    
                    UserDefaults.set(!MB_Feedback.shared.isVibrationsEnabled, .vibrationsEnabled)
                    
                    if MB_Feedback.shared.isVibrationsEnabled {
                        
                        MB_Feedback.shared.make(.On)
                    }
                    
                    self?.menu = self?.settingsMenu
                })
			])
		])
	}
	
	public override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		title = String(key: "settings.button")
		image = UIImage(systemName: "slider.vertical.3")?.applyingSymbolConfiguration(.init(scale: .medium))
		menu = settingsMenu
		showsMenuAsPrimaryAction = true
        type = .navigation
	}
	
	required init?(coder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	}
}
