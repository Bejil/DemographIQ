//
//  MB_Country_MapView.swift
//  DemographIQ
//
//  Created by Michaël Blin on 08/04/2026.
//

import Foundation
import UIKit
import MapKit
import SnapKit

public class MB_Country_MapView : MKMapView {
    
    public var country:MB_Country? {
        
        didSet {
            
            if let latlng = country?.latlng, latlng.count >= 2, let area = country?.area, area > 0 {
                
                let minMeters: CLLocationDistance = 250_000
                let maxMeters: CLLocationDistance = 8_000_000
                
                let radiusKm = sqrt(Double(area) / Double.pi)
                let diameterMeters = (radiusKm * 2.0) * 1_000.0
                let paddedMeters = diameterMeters * 1.9
                let meters = min(max(paddedMeters, minMeters), maxMeters)
                
                // Evite les régions invalides proches des pôles.
                let latitude = min(max(latlng[0], -85.0), 85.0)
                let longitude = min(max(latlng[1], -180.0), 180.0)
                let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                
                let latDelta = min(max(meters / 111_000.0, 0.5), 120.0)
                let cosLatitude = max(cos(latitude * .pi / 180.0), 0.01)
                let lonDelta = min(max(meters / (111_000.0 * cosLatitude), 0.5), 120.0)
                let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
                let region = MKCoordinateRegion(center: center, span: span)
                setRegion(region, animated: true)
            }
        }
    }
    
    public override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        let backgroundBlurView = UIVisualEffectView(effect: UIGlassEffect(style: .regular))
        backgroundBlurView.alpha = 1.75
        addSubview(backgroundBlurView)
        backgroundBlurView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
}
