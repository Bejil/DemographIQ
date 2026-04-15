//
//  MB_Audio.swift
//
//  Created by BLIN Michael on 09/10/2025.
//

import AVFoundation

public class MB_Audio : NSObject {
	
	public enum Sounds : String, CaseIterable {
		
		case Success = "Success"
		case Error = "Error"
		case Button = "Button"
		case Tap = "Tap"
	}
	
	public static var shared:MB_Audio = .init()
	private var soundCache:[Sounds: AVAudioPlayer] = [:]
	private var activeSoundPlayers:[AVAudioPlayer] = []
	private var musicPlayer:AVAudioPlayer?
    private let audioQueue = DispatchQueue(label: UUID().uuidString, qos: .userInteractive)
	public var isSoundsEnabled:Bool {
		
		return (UserDefaults.get(.soundsEnabled) as? Bool) ?? true
	}
	public var isMusicEnabled:Bool {
		
		return (UserDefaults.get(.musicEnabled) as? Bool) ?? true
	}
	
	public override init() {
		
		super.init()
        
		configureAudioSession()
		preloadSounds()
	}
    
	private func configureAudioSession() {
		
		do {
            
			try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
			try AVAudioSession.sharedInstance().setActive(true, options: [.notifyOthersOnDeactivation])
		}
		catch {
            
			print("Erreur configuration AVAudioSession: \(error)")
		}
	}
    
	private func preloadSounds() {
		
		audioQueue.async { [weak self] in
			
			for sound in Sounds.allCases {
				
				if let path = Bundle.main.path(forResource: sound.rawValue, ofType: "mp3") {
					
					let url = URL(fileURLWithPath: path)
					
					if let player = try? AVAudioPlayer(contentsOf: url) {
						
						player.prepareToPlay()
						self?.soundCache[sound] = player
					}
				}
			}
		}
	}
	
	public func playSound(_ sound:Sounds) {
		
		guard isSoundsEnabled else { return }
		
		audioQueue.async { [weak self] in
			
			guard let self = self else { return }
			
			guard let cachedPlayer = self.soundCache[sound],
				  let url = cachedPlayer.url,
				  let player = try? AVAudioPlayer(contentsOf: url) else { return }
			
			player.prepareToPlay()
			
			DispatchQueue.main.async {
				player.delegate = self
				self.activeSoundPlayers.append(player)
				player.play()
			}
		}
	}
	
	public func playMusic() {
		
		stopMusic()
		
		guard isMusicEnabled else { return }
		
		if let index = (0...2).randomElement(), let path = Bundle.main.path(forResource: "music_\(index)", ofType: "mp3") {
			
			let url = URL(fileURLWithPath: path)
			
			if let player = try? AVAudioPlayer(contentsOf: url) {
				
				musicPlayer = player
				musicPlayer?.delegate = self
				musicPlayer?.prepareToPlay()
				musicPlayer?.play()
			}
		}
	}
	
	public func stopMusic() {
		
		musicPlayer?.stop()
		musicPlayer = nil
	}
}

extension MB_Audio : AVAudioPlayerDelegate {
	
	public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		
		if player == musicPlayer {
            
			playMusic()
		}
		else {
            
			DispatchQueue.main.async { [weak self] in
                
				self?.activeSoundPlayers.removeAll { $0 == player }
			}
		}
	}
}
