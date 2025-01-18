import Combine
import Foundation
@testable import PlanetAppList

class MockNetworkService: NetworkServiceProtocol {
    private let mockData: Data
    
    init(mockData: Data) {
        self.mockData = mockData
    }
    
    func fetchPlanets() -> AnyPublisher<PlanetResponse, Error> {
        return Just(mockData)
            .tryMap { data -> PlanetResponse in
                try JSONDecoder().decode(PlanetResponse.self, from: data)
            }
            .eraseToAnyPublisher()
    }
} 