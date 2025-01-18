//
//  ContentView.swift
//  PlanetAppList
//
//  Created by Rohit Sankpal on 16/01/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var planetList: [PlanetModel]
    @StateObject private var viewModel: PlanetListViewModel
    
    init() {
        let networkService = NetworkService()
        _viewModel = StateObject(wrappedValue: PlanetListViewModel(networkService: networkService))
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("List of Planet")
                .font(.system(size: 30, weight: .bold))
                .font(.title)
                .padding(.leading, 20)
            
            ZStack {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(planetList, id: \.id) { planet in
                            PlanetRowView(planetModel: planet)
                        }
                    }
                    .padding(.vertical)
                }
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.ultraThinMaterial)
                }
            }
            .navigationTitle("Planets")
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("Retry") {
                    Task { await viewModel.loadPlanetData() }
                }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "Unknown error")
            }
            .onAppear {
                viewModel.setContext(modelContext)
                Task {
                    await viewModel.loadPlanetData()
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: PlanetModel.self, inMemory: true)
}
