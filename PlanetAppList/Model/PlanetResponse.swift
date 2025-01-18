//
//  PlanerResponse.swift
//  PlanetAppList
//
//  Created by Rohit Sankpal on 16/01/25.
//
//

import Foundation

struct PlanetResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PlanetsListData]
}
