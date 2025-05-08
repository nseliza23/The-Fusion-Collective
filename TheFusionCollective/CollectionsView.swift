//
//  CollectionsView.swift
//  TheFusionCollective
//
//  Created by nandana on 4/22/25.
//

import SwiftUI

struct CollectionsView: View {
    let username: String

    @Environment(\.collectionStore) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var showNewCollectionDialog = false
    @State private var newCollectionName = ""
    @State private var isEditing = false

    enum LayoutOption { case grid, list }
    @State private var layout: LayoutOption = .grid

    // Filtered list of models
    private var filteredCollections: [CollectionModel] {
        store.collections.filter {
            searchText.isEmpty ? true : $0.name.lowercased().contains(searchText.lowercased())
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.beige
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 15) {
                    Text("Welcome, \(username)!")
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)

                    Button {
                        showNewCollectionDialog = true
                    } label: {
                        Text("+ Add Collection")
                            .font(.system(size: 25, weight: .bold))
                            .foregroundColor(.chestnut)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.chestnut.opacity(0.5), lineWidth: 4)
                            )
                    }
                    .accessibilityLabel("Add Collection")
                    .padding(.horizontal)

                    collectionsContent

                    Spacer()
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search collections...")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation
                        {
                            isEditing.toggle()
                        }
                    }
                    label: {
                        Image(systemName: isEditing ? "checkmark.circle" : "trash")
                            .foregroundColor(.chestnut)
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // go to favorites
                    NavigationLink(destination: FavoritesView()) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.chestnut)
                    }

                    // layout options
                    Menu {
                        Button("Grid View") {
                            layout = .grid
                        }
                        Button("List View") {
                            layout = .list
                        }
                    } label: {
                        Image(systemName: layout == .grid ? "square.grid.2x2.fill" : "list.bullet")
                            .foregroundColor(.chestnut)
                    }
                }
            }
            .sheet(isPresented: $showNewCollectionDialog) {
                NavigationStack {
                    ZStack {
                        Color.beige
                            .ignoresSafeArea()
                        VStack(spacing: 20) {
                            Text("Collection Name")
                                .font(.headline)
                            TextField("Enter name", text: $newCollectionName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                            Spacer()
                        }
                        .padding()
                    }
                    .navigationTitle("Add New Collection")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showNewCollectionDialog = false
                                newCollectionName = ""
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Save") {
                                if !newCollectionName.isEmpty {
                                    store.addCollection(
                                        name: newCollectionName,
                                        note: "",
                                        uiImages: []
                                    )
                                }
                                showNewCollectionDialog = false
                                newCollectionName = ""
                            }
                            .disabled(newCollectionName.isEmpty)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
        private var collectionsContent: some View {
            switch layout {
            case .grid:
                let columns = [GridItem(.flexible()), GridItem(.flexible())]
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(filteredCollections, id: \.id) { model in
                        ZStack(alignment: .topTrailing) {
                            NavigationLink(destination:
                                CollectionItemView(collectionName: model.name)
                            ) {
                                Text(model.name)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(height: 100)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.chestnut)
                                    .cornerRadius(8)
                            }
                            // delete icon
                            if isEditing {
                                Button {
                                    withAnimation {
                                        store.deleteCollection(id: model.id)
                                    }
                                }
                                label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                        .background(Color.beige.opacity(0.8))
                                        .clipShape(Circle())
                                }
                                .offset(x: -8, y: 8)
                            }
                        }
                    }
                }
                .padding(.horizontal)

            case .list:
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(filteredCollections, id: \.id) { model in
                            ZStack(alignment: .topTrailing) {
                                NavigationLink(destination:
                                    CollectionItemView(collectionName: model.name)
                                ) {
                                    Text(model.name)
                                        .font(.headline)
                                        .foregroundColor(.beige)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.chestnut)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.beige, lineWidth: 2)
                                        )
                                        .cornerRadius(8)
                                }
                                // delete
                                if isEditing {
                                    Button {
                                        withAnimation {
                                            store.deleteCollection(id: model.id)
                                        }
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.red)
                                            .background(Color.beige.opacity(0.8))
                                            .clipShape(Circle())
                                    }
                                    .offset(x: -8, y: 8)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    #Preview {
        CollectionsView(username: "Nandana")
    }
