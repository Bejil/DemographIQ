//
//  MB_ImageView.swift
//  Template
//
//  Created by Michaël Blin on 25/03/2026.
//

import UIKit
import Alamofire
import AlamofireImage

public class MB_ImageView : UIImageView {
    
    public var url:String? {
        
        didSet {
            
            image = nil
            
            if let url = url, !url.isEmpty {
                
                showLoadingIndicatorView(blurBackground: false)
                
                AF.request(url).validate().responseImage { [weak self] (response) in
                    
                    self?.dismissLoadingIndicatorView()
                    
                    if case .success(let image) = response.result {
                        
                        self?.image = image
                    }
                }
            }
        }
    }
    
    convenience init() {
        
        self.init(frame: .zero)
    }
    
    public override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        setUp()
    }
    
    public override init(image: UIImage?) {
        
        super.init(image: image)
        
        setUp()
    }
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUp() {
        
        contentMode = .scaleAspectFit
    }
}
