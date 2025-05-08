//
//  FavoritesView.swift
//  TheFusionCollective
//
//  Created by nandana on 5/8/25.
//

import SwiftUI

struct FavoritesView: View {
    @Environment(\.collectionStore) private var store

    private var favorites: [CollectionModel] {
        store.collections.filter { $0.isFavorite }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.beige
                    .ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(favorites, id: \.id) { model in
                            NavigationLink(destination:
                                CollectionItemView(collectionName: model.name)
                            ){
                                Text(model.name)
                                    .font(.headline)
                                    .foregroundColor(.beige)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.chestnut)
                                    .overlay(RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.beige, lineWidth: 2)
                                    )
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Favorites")
        }
    }
}

#Preview {
    FavoritesView()
}
