//
//  StoreItems.swift
//  iTunesSearch
//
//  Created by Mohammad Shayan on 4/19/20.
//  Copyright © 2020 Mohammad Shayan. All rights reserved.
//

import UIKit

struct StoreItems: Codable {
    let results: [StoreItem]
    let resultCount: Int
}

struct StoreItem: Codable, Equatable, CustomStringConvertible {
    let kind: String
    let artistName: String
    let collectionName: String
    let trackName: String
    let trackUrl: URL
    let trackPrice: Double
    let artworkUrl: URL
    let genre: String
    let collectionId: Int
    let trackId: Int
    //private(set) public var artworkImage: UIImage
    private(set) public var isFavorite: Bool
    
    enum CodingKeys: String, CodingKey {
        case kind
        case artistName
        case collectionName
        case trackName
        case trackUrl = "trackViewUrl"
        case trackPrice
        case artworkUrl = "artworkUrl100"
        case genre = "primaryGenreName"
        case collectionId
        case trackId
        //case artworkImage
        case isFavorite
    }
    
    init(from decoder: Decoder) throws {
        let valueContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.kind = try valueContainer.decode(String.self, forKey: CodingKeys.kind)
        self.artistName = try valueContainer.decode(String.self, forKey: CodingKeys.artistName)
        self.collectionName = try valueContainer.decode(String.self, forKey: CodingKeys.collectionName)
        self.trackName = try valueContainer.decode(String.self, forKey: CodingKeys.trackName)
        self.trackUrl = try valueContainer.decode(URL.self, forKey: CodingKeys.trackUrl)
        self.trackPrice = try valueContainer.decode(Double.self, forKey: CodingKeys.trackPrice)
        self.artworkUrl = try valueContainer.decode(URL.self, forKey: CodingKeys.artworkUrl)
        self.genre = try valueContainer.decode(String.self, forKey: CodingKeys.genre)
        self.collectionId = try valueContainer.decode(Int.self, forKey: CodingKeys.collectionId)
        self.trackId = try valueContainer.decode(Int.self, forKey: CodingKeys.trackId)
        //self.artworkImage = UIImage(named: "gray")!
        do {
            try self.isFavorite = valueContainer.decode(Bool.self, forKey: CodingKeys.isFavorite)
        } catch {
            self.isFavorite = false
        }
    }
    
    init(storeItem: StoreItem) {
        self.kind = storeItem.kind
        self.artistName = storeItem.artistName
        self.collectionName = storeItem.collectionName
        self.trackName = storeItem.trackName
        self.trackUrl = storeItem.trackUrl
        self.trackPrice = storeItem.trackPrice
        self.artworkUrl = storeItem.artworkUrl
        self.genre = storeItem.genre
        self.collectionId = storeItem.collectionId
        self.trackId = storeItem.trackId
        //self.artworkImage = storeItem.artworkImage
        self.isFavorite = storeItem.isFavorite
    }
    
    func encode(to encoder: Encoder) throws {
        var valueContainer = encoder.container(keyedBy: CodingKeys.self)
        try valueContainer.encode(kind, forKey: .kind)
        try valueContainer.encode(artistName, forKey: .artistName)
        try valueContainer.encode(collectionName, forKey: .collectionName)
        try valueContainer.encode(trackName, forKey: .trackName)
        try valueContainer.encode(trackUrl, forKey: .trackUrl)
        try valueContainer.encode(trackPrice, forKey: .trackPrice)
        try valueContainer.encode(artworkUrl, forKey: .artworkUrl)
        try valueContainer.encode(genre, forKey: .genre)
        try valueContainer.encode(collectionId, forKey: .collectionId)
        try valueContainer.encode(trackId, forKey: .trackId)
        try valueContainer.encode(isFavorite, forKey: .isFavorite)
    }
    
    mutating func setImage(_ image: UIImage) {
        //self.artworkImage = image
    }
    
    mutating func changeFavorite() {
        self.isFavorite = !self.isFavorite
    }
    
    var description: String {
        return "Track Name: \(trackName) \tIs Favorite: \(isFavorite)"
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.collectionId == rhs.collectionId && lhs.trackId == rhs.trackId
    }
    
    static func sortIntoKindDictionary(storeItems: [StoreItem]) -> [String: [StoreItem]] {
        
        var dictionary = [String: [StoreItem]]()
        
        for storeItem in storeItems {
            let kind = storeItem.kind
            if let _ = dictionary[kind] {
                dictionary[kind]?.append(storeItem)
            } else {
                dictionary[kind] = [storeItem]
            }
        }
        
        return dictionary
        
    }
}

