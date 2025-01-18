//
//  PlanetModelTests.swift
//  PlanetAppListTests
//
//  Created by Rohit Sankpal on 17/01/25.
//

import Combine
import Foundation
import SwiftData
import Testing
@testable import PlanetAppList

struct PlanetModelTests {
    static let mockData = """
    {
        "count": 1,
        "next": null,
        "previous": null,
        "results": [{
            "name": "Tatooine",
            "rotation_period": "23",
            "orbital_period": "304",
            "diameter": "10465",
            "climate": "arid",
            "gravity": "1 standard",
            "terrain": "desert",
            "surface_water": "1",
            "population": "200000"
        }]
    }
    """.data(using: .utf8)!
    
    var cancellable: Set<AnyCancellable>!
    
    init() {
        cancellable = []
    }
    
    @Suite("PlanetModelTests")
    struct PlanetModelTestCases {
        // Positive test case for successful data fetch
        @Test("Test successful planet data fetch and parsing")
        func testSuccessfulPlanetDataFetch() async throws {
            let mockService = MockNetworkService(mockData: PlanetModelTests.mockData)
            let viewModel = await PlanetListViewModel(networkService: mockService)
            
            await viewModel.loadPlanetData()
            
            await #expect(viewModel.isLoading == false)
            await #expect(viewModel.error == nil)
            
            let response = try await mockService.fetchPlanets().async()
            #expect(response.results.count == 1)
            #expect(response.results.first?.name == "Tatooine")
        }
        
        // Negative test case for invalid JSON
        @Test("Test invalid JSON handling")
        func testInvalidJSONHandling() async throws {
            let invalidData = "invalid json".data(using: .utf8)!
            let mockService = MockNetworkService(mockData: invalidData)
            let viewModel = await PlanetListViewModel(networkService: mockService)
            
            await viewModel.loadPlanetData()
            
            await #expect(viewModel.isLoading == false)
            await #expect(viewModel.error != nil)
        }
        
        // Test empty response
        @Test("Test empty response handling")
        func testEmptyResponse() async throws {
            let emptyData = """
            {
                "count": 0,
                "next": null,
                "previous": null,
                "results": []
            }
            """.data(using: .utf8)!
            
            let mockService = MockNetworkService(mockData: emptyData)
            let viewModel = await PlanetListViewModel(networkService: mockService)
            
            await viewModel.loadPlanetData()
            
            await #expect(viewModel.isLoading == false)
            await #expect(viewModel.error == nil)
            
            let response = try await mockService.fetchPlanets().async()
            #expect(response.results.isEmpty)
        }
        
        // Test SwiftData operations
        @Test("Test SwiftData operations")
        func testSwiftDataOperations() async throws {
            
            let mockService = MockNetworkService(mockData: PlanetModelTests.mockData)
            let mockResults = try await mockService.fetchPlanets().async().results
            
            do {
                let container = try ModelContainer(for: PlanetModel.self)
                let context = ModelContext(container)
                try context.delete(model: PlanetModel.self)
                // Test insertion
                for planet in mockResults {
                    let planetModel = PlanetModel(
                        name: planet.name
                    )
                    context.insert(planetModel)
                }
                
                // Verify insertion
                let descriptor = FetchDescriptor<PlanetModel>()
                let savedPlanets = try context.fetch(descriptor)
                #expect(!savedPlanets.isEmpty, "Saved planets should not be empty")
                #expect(savedPlanets.count == mockResults.count, "Should have same number of planets as mock data")
                
                if let firstPlanet = savedPlanets.first {
                    #expect(firstPlanet.name == "Tatooine", "First planet should be Tatooine")
                }
                
                // Test deletion
                for planet in savedPlanets {
                    context.delete(planet)
                }
                
                // Verify deletion
                let emptyPlanets = try context.fetch(descriptor)
                #expect(emptyPlanets.isEmpty, "All planets should be deleted")
            } catch {
                print("Something failed.\(error)")
                throw error
            }
        }
        
        // Test network error handling
        @Test("Test network error handling")
        func testNetworkError() async throws {
            struct ErrorMockNetworkService: NetworkServiceProtocol {
                func fetchPlanets() -> AnyPublisher<PlanetResponse, Error> {
                    return Fail(error: NetworkError.invalidURL)
                        .eraseToAnyPublisher()
                }
            }
            
            let mockService = ErrorMockNetworkService()
            let viewModel = await PlanetListViewModel(networkService: mockService)
            
            await viewModel.loadPlanetData()
            
            await #expect(viewModel.isLoading == false)
            await #expect(viewModel.error != nil)
        }
    }
}
