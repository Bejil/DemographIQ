//
//  MB_Splashscreen_ViewController.swift
//
//  Created by Michaël Blin on 25/03/2026.
//

import UIKit

public class MB_Splashscreen_ViewController : MB_ViewController {
    
    public var completion:(()->Void)?
    
    public override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        fetchCountries()
    }
    
    private func fetchCountries() {
        
        MB_Alert_ViewController.presentLoading { [weak self] controller in
            
            MB_Country.getAll { [weak self] error in
                
                controller?.close { [weak self] in
                    
                    if let error {
                        
                        MB_Alert_ViewController.present(error, canDismiss: false) { [weak self] in
                            
                            self?.fetchCountries()
                        }
                    }
                    else {
                        
                        self?.completion?()
                    }
                }
            }
        }
    }
}
