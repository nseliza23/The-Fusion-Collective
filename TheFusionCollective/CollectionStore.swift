//
//  CollectionStore.swift
//  TheFusionCollective
//
//  Created by nandana on 5/8/25.
//

import Foundation
import UIKit
import SwiftUICore

struct CollectionModel: Identifiable, Codable {
    let id: UUID
    var name: String
    var note: String
    var imagesData: [Data]
    var isFavorite: Bool
}

@Observable
final class CollectionStore: Codable {
    var collections: [CollectionModel]

    init() {
            #if DEBUG
            let url = Self.documentsURL(for: "collections")
            if FileManager.default.fileExists(atPath: url.path) {
                try? FileManager.default.removeItem(at: url)
            }
            // clear any first run flag
            UserDefaults.standard.removeObject(forKey: "hasInitializedCollections")
            #endif

            if let loaded = try? Self.load(fileName: "collections") {
                self.collections = loaded.collections
            } else {
                self.collections = []
            }
        }

    func addCollection(name: String, note: String, uiImages: [UIImage]) {
        let datas = uiImages.compactMap {
            $0.jpegData(compressionQuality: 0.8)
        }
        let new = CollectionModel(
            id: UUID(),
            name: name,
            note: note,
            imagesData: datas,
            isFavorite: false
        )
        collections.append(new)
        try? Self.save(fileName: "collections", store: self)
    }

    func deleteCollection(at offsets: IndexSet) {
           collections.remove(atOffsets: offsets)
           try? Self.save(fileName: "collections", store: self)
       }

    func deleteCollection(id: UUID) {
        if let idx = collections.firstIndex(where: {
            $0.id == id
        }) {
           collections.remove(at: idx)
           try? Self.save(fileName: "collections", store: self)
       }
    }

    func moveCollection(from source: IndexSet, to destination: Int) {
        collections.move(fromOffsets: source, toOffset: destination)
        try? Self.save(fileName: "collections", store: self)
    }

    func toggleFavorite(on id: UUID) {
        guard let idx = collections.firstIndex(where: { $0.id == id }) else { return }
        collections[idx].isFavorite.toggle()
        try? Self.save(fileName: "collections", store: self)
    }

    private static func documentsURL(for fileName: String) -> URL {
        FileManager
          .default
          .urls(for: .documentDirectory, in: .userDomainMask)
          .first!
          .appendingPathComponent(fileName)
          .appendingPathExtension("plist")
    }

    static func load(fileName: String) throws -> CollectionStore {
        let url = documentsURL(for: fileName)
        let data = try Data(contentsOf: url)
        return try PropertyListDecoder().decode(CollectionStore.self, from: data)
    }

    static func save(fileName: String, store: CollectionStore) throws {
        let url = documentsURL(for: fileName)
        let data = try PropertyListEncoder().encode(store)
        try data.write(to: url, options: .atomic)
    }
}

private struct CollectionStoreKey: EnvironmentKey {
    static let defaultValue = CollectionStore()
}

extension EnvironmentValues {
    var collectionStore: CollectionStore {
        get {
            self[CollectionStoreKey.self]
        }
        set {
            self[CollectionStoreKey.self] = newValue
        }
    }
}
