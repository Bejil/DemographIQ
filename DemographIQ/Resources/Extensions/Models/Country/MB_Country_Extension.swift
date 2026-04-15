//
//  MB_Country.swift
//  DemographIQ
//
//  Created by Michaël Blin on 25/03/2026.
//

import Foundation
import Alamofire

extension MB_Country {
    
    public static var all:[MB_Country]?
    public var localizedName:String {
        
        let languageCode = Locale.current.language.languageCode?.identifier.lowercased()
        
        if languageCode == "fr" {
            
            return translations?["fra"]?.common ?? name?.common ?? ""
        }
        
        return name?.common ?? ""
    }
    public var formattedPopulation:String {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: population ?? 0)) ?? "\(population ?? 0)"
    }
    
    public static func getAll(_ completion:((Error?)->Void)?) {
        
        if let countriesLastFecthDate = UserDefaults.get(.countriesLastFecthDate) as? Date, Calendar.current.isDateInToday(countriesLastFecthDate),
           let countriesLastFecthData = UserDefaults.get(.countriesLastFecthData) as? Data, let countriesLastFecth = try? JSONDecoder().decode([MB_Country].self, from: countriesLastFecthData) {
            
            MB_Country.all = countriesLastFecth
            completion?(nil)
        }
        else {
            
            let url = "https://restcountries.com/v3.1/all?fields=name,flags,population,translations,latlng,capital,cca3,area"
            
            AF.request(url, method: .get).validate().responseDecodable(of: [MB_Country].self) { response in
                
                switch response.result {
                case .success(let countries):
                    
                    do {
                        
                        let countriesLastFecthData = try JSONEncoder().encode(countries)
                        
                        UserDefaults.set(countriesLastFecthData, .countriesLastFecthData)
                        UserDefaults.set(Date(), .countriesLastFecthDate)
                        
                        MB_Country.all = response.value
                        completion?(nil)
                    }
                    catch {
                        
                        completion?(error)
                    }
                    
                case .failure(let error):
                    
                    completion?(error)
                }
            }
        }
    }
    
    public enum GuessResult : String {
        
        case great = "great"
        case good = "good"
        case far = "far"
    }
    
    public func getResult(for guess:Int?) -> GuessResult {
        
        if let guess, let population, population > 0 {
            
            let errorRatio = abs(Double(guess - population)) / Double(population)
            
            switch errorRatio {
            case 0.0..<0.1:
                return .great
            case 0.1...0.5:
                return .good
            default:
                return .far
            }
        }
        
        return .far
    }
}

extension [MB_Country] {
    
    public mutating func getNew() -> MB_Country? {
        
        if let allCountries = MB_Country.all, !allCountries.isEmpty {
            
            let missingCountries = allCountries.filter({ !contains($0) && $0.population ?? 0 > 0 })
            
            if let newCountry = missingCountries.randomElement() {
                
                append(newCountry)
                return newCountry
            }
        }

        return nil
    }
    
    /// Pays absent de `self`, avec une population du même ordre de grandeur que `reference`.
    /// Fenêtre serrée ~×0,5…×2, puis élargie ~×0,2…×5, sinon les plus proches en échelle log.
    public mutating func getNew(withSimilarPopulationTo reference: MB_Country) -> MB_Country? {
        
        guard let allCountries = MB_Country.all, !allCountries.isEmpty else { return nil }
        
        let refPop = reference.population ?? 0
        guard refPop > 0 else { return getNew() }
        
        let ref = Double(refPop)
        
        let candidates = allCountries.filter { candidate in
            guard candidate != reference, !contains(candidate), (candidate.population ?? 0) > 0 else { return false }
            return true
        }
        guard !candidates.isEmpty else { return nil }
        
        func ratio(for country: MB_Country) -> Double? {
            guard let p = country.population, p > 0 else { return nil }
            return Double(p) / ref
        }
        
        let tight = candidates.filter {
            guard let r = ratio(for: $0) else { return false }
            return r >= 0.5 && r <= 2.0
        }
        let wide = candidates.filter {
            guard let r = ratio(for: $0) else { return false }
            return r >= 0.2 && r <= 5.0
        }
        
        let pool: [MB_Country]
        if !tight.isEmpty {
            pool = tight
        } else if !wide.isEmpty {
            pool = wide
        } else {
            let refLog = log(ref)
            let sorted = candidates.sorted {
                let da = abs(log(Double($0.population!)) - refLog)
                let db = abs(log(Double($1.population!)) - refLog)
                return da < db
            }
            let limit = Swift.min(24, sorted.count)
            pool = Array(sorted.prefix(limit))
        }
        
        guard let picked = pool.randomElement() else { return nil }
        append(picked)
        return picked
    }
}
