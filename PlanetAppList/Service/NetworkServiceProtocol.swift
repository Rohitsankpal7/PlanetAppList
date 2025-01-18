//
//  NetworkServiceProtocol.swift
//  PlanetAppList
//
//  Created by Rohit Sankpal on 16/01/25.
//

import Combine

protocol NetworkServiceProtocol {
    func fetchPlanets() -> AnyPublisher<PlanetResponse, Error>
}
