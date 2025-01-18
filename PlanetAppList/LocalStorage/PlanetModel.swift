//
//  PlanetModel.swift
//  PlanetAppList
//
//  Created by Rohit Sankpal on 16/01/25.
//

import Foundation
import SwiftData

@Model
final class PlanetModel: Identifiable {
    var id: String
    var name: String
    
    init(
        id: String = UUID().uuidString,
        name: String
    ) {
        self.id = id
        self.name = name
    }
}

struct PlanetsListData: Codable {
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case name
    }
    init(id: String, name: String) {
        self.name = name
    }
    
    func toPlanetModel() -> PlanetModel {
        PlanetModel(
            name: name
        )
    }
}
