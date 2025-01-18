//
//  PlanetRowView.swift
//  PlanetAppList
//
//  Created by Rohit Sankpal on 17/01/25.
//

import SwiftUI
// Seperate row for List
struct PlanetRowView: View {
    let planetModel: PlanetModel
    var body: some View {
        VStack {
            Text(planetModel.name)
                .font(.system(size: 20, weight: .semibold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
        .padding(.vertical, 6)
    }
}
