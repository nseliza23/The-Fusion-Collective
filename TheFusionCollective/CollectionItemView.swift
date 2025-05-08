//
//  CollectionItemView.swift
//  TheFusionCollective
//
//  Created by nandana on 5/7/25.
//

import SwiftUI
import PhotosUI
import UIKit

struct CollectionItemView: View {
    let collectionName: String

    @Environment(\.dismiss) private var dismiss
    @Environment(\.collectionStore) private var store

    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var images: [Image] = []
    @State private var uiImages: [UIImage] = []
    @State private var noteText: String = ""
    @State private var isFavorite: Bool = false

    private var modelIndex: Int? {
        store.collections.firstIndex { $0.name == collectionName }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.beige
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text(collectionName)
                                .font(.largeTitle)
                                .bold()
                            Spacer()
                            Button {
                                isFavorite.toggle()
                                if let idx = modelIndex {
                                    let id = store.collections[idx].id
                                    store.toggleFavorite(on: id)
                                }
                            } label: {
                                Image(systemName: isFavorite ? "heart.fill" : "heart")
                                    .imageScale(.large)
                                    .foregroundColor(.chestnut)
                            }
                        }
                        .padding(.horizontal)

                        PhotosPicker(
                            selection: $selectedItems,
                            maxSelectionCount: 5,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            Label("Add Photos", systemImage: "photo.on.rectangle.angled")
                                .font(.headline)
                                .foregroundColor(.beige)
                                .padding()
                                .background(Color.chestnut)
                                .cornerRadius(8)
                                .padding(.horizontal)
                        }
                        .onChange(of: selectedItems) { _ in
                            loadPickedImages()
                        }

                        // display picked images
                        if !images.isEmpty {
                            let columns = Array(repeating: GridItem(.flexible()), count: 3)
                            LazyVGrid(columns: columns, spacing: 10) {
                                ForEach(images.indices, id: \.self) { idx in
                                    images[idx]
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipped()
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal)
                        }

                        // notes field
                        Text("Notes")
                            .font(.headline)
                            .padding(.horizontal)

                        TextEditor(text: $noteText)
                            .frame(minHeight: 150)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.chestnut, lineWidth: 3)
                            )
                            .padding(.horizontal)

                        Spacer()
                    }
                }
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(.chestnut)
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            saveChanges()
                            dismiss()
                        }
                        .bold()
                        .foregroundColor(.chestnut)
                        .disabled(modelIndex == nil)
                    }
                }
                .onAppear(perform: loadExistingData)
            }
        }
    }


    private func loadExistingData() {
        guard let idx = modelIndex else {
            return
        }
        let model = store.collections[idx]
        noteText = model.note
        uiImages = model.imagesData.compactMap {
            UIImage(data: $0)
        }
        images = uiImages.map {
            Image(uiImage: $0)
        }
        isFavorite = model.isFavorite
    }

    private func loadPickedImages() {
        images.removeAll()
        uiImages.removeAll()
        for item in selectedItems {
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data)
                {
                    await MainActor.run {
                        uiImages.append(uiImage)
                        images.append(Image(uiImage: uiImage))
                    }
                }
            }
        }
    }

    private func saveChanges() {
        guard let idx = modelIndex else {
            return
        }
        store.collections[idx].note = noteText
        store.collections[idx].imagesData = uiImages.compactMap {
            $0.jpegData(compressionQuality: 0.8)
        }
        try? CollectionStore.save(fileName: "collections", store: store)
    }
}

#Preview {
    CollectionItemView(collectionName: "My Collection")
}
