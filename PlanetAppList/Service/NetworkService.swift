//
//  NetworkService.swift
//  PlanetAppList
//
//  Created by Rohit Sankpal on 16/01/25.
//

import Combine
import Foundation

enum NetworkError: Error, Equatable {
    case invalidURL
    case invalidResponse
    case decodingError
    case serverError(String)
}

class NetworkService: NetworkServiceProtocol {
    
    var baseURL: String { // declared baseurl in info plist
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
           let config = NSDictionary(contentsOfFile: path),
           let baseURL = config["BaseURL"] as? String {
            return baseURL + "?page=1"
        }
        return ""
    }
    
    func fetchPlanets() -> AnyPublisher<PlanetResponse, any Error> { // api service call
        guard let url = URL(string: baseURL) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.invalidResponse
                }
                return data
            }
            .decode(type: PlanetResponse.self, decoder: JSONDecoder())
            .mapError { error in
                if let decoddingError = error as? DecodingError {
                    return decoddingError
                }
                return NetworkError.serverError(error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
}
