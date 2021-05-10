//
//  APICaller.swift
//  CryptoTrack
//
//  Created by Ndayisenga Jean Claude on 09/05/2021.
//

import Foundation

final class APICaller {
    static let shared = APICaller()
    private struct Constants  {
        static let apiKey = "6C4FAD6C-C159-49D2-831C-FAC8CD8AE646"
        static let assetsEndpoint = "https://rest-sandbox.coinapi.io/v1/assets/"
    }
    
    private init() {}
    public var icons: [Icon] = []
    
    private var whenReadyBlock: ((Result<[Crypto], Error>) -> Void)?
    
    // MARK: - Public
    
    public func getAllCryptoData(
        completion: @escaping (Result<[Crypto], Error>) -> Void
    ) {
        guard !icons.isEmpty else {
            whenReadyBlock = completion
            return
        }
        guard let url = URL(string: Constants.assetsEndpoint + "?apikey=" + Constants.apiKey) else {
            
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                
                return
            }
            do {
                // Decode Response
                let cryptos = try JSONDecoder().decode([Crypto].self, from: data)
                completion(.success(cryptos.sorted { first, secodn -> Bool in
                    return first.price_usd ?? 0 > secodn.price_usd ?? 0
                }))
            }
            catch {
                completion(.failure(error))
                
            }
        }
        task.resume()
    }
    public func getAllIcons() {
        guard let url = URL(string: "https://rest-sandbox.coinapi.io/v1/assets/icons/55/?apikey=2365EB53-C1D2-4765-A671-1111698437C0") else {
                return
    }
    let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
        guard let data = data, error == nil else {
            
            return
        }
        do {
            
            self?.icons = try JSONDecoder().decode([Icon].self, from: data)
            if let completion = self?.whenReadyBlock {
                self?.getAllCryptoData(completion: completion)
            }
           
        }
        catch {
            
            print(error)
           
            
        }
    }
    task.resume()
 }
}
