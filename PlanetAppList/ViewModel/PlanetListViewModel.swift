//
//  PlanetListViewModel.swift
//  PlanetAppList
//
//  Created by Rohit Sankpal on 17/01/25.
//
import Combine
import SwiftUI
import SwiftData

@MainActor 
class PlanetListViewModel: ObservableObject {
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: Error?
    
    private let networkService: NetworkServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var modelContext: ModelContext? // to get access to swiftdata
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func setContext(_ context: ModelContext) {
        self.modelContext = context
        print("ModelContext set successfully")
    }
    
    func loadPlanetData() async { // Calling api
        isLoading = true
        
        do {
            let publisher = networkService.fetchPlanets()
            let response = try await publisher.async()
            self.error = nil
            
            // refresh data or delete old data
            try modelContext?.delete(model: PlanetModel.self)
            
            // load new data
            savePlanetList(planetList: response.results) // calling func to store data localy
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func savePlanetList(planetList: [PlanetsListData]) { // saving data
        do {
            planetList.forEach { item in // loading all data by iterating loop
                let newPlanet = item.toPlanetModel()
                modelContext?.insert(newPlanet)
            }
            
            try modelContext?.save() // saving data to local store
            self.error = nil
            
        } catch {
            self.error = error
        }
    }
}

extension Publisher {
    func async() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            
            cancellable = self.sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                },
                receiveValue: { value in
                    continuation.resume(returning: value)
                    cancellable?.cancel()
                }
            )
        }
    }
}
