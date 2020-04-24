//
//  NetworkServices.swift
//  iTunesSearch
//
//  Created by Mohammad Shayan on 4/19/20.
//  Copyright © 2020 Mohammad Shayan. All rights reserved.
//

import UIKit

struct NetworkServices {
    static let shared = NetworkServices()
    
    func fetchItems(matching query: [String: String], completion: @escaping ([StoreItem]?, String?) -> Void) {
        
        let baseURL = URL(string: "https://itunes.apple.com/search?")!
        
        guard let url = baseURL.withQueries(query) else {
            completion(nil, "url query issues")
            return
        }

        let session = URLSession.shared
        let dataTask = session.dataTask(with: url) { (data, response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data, let storeItems = try? jsonDecoder.decode(StoreItems.self, from: data) {
                
                completion(storeItems.results, nil)
                
            } else {
                completion(nil, "Either no data was returned, or data was not serialized")
                return
            }
        }
        dataTask.resume()
        
    }
    
    func updateImage(storeItem: StoreItem, completion: @escaping (UIImage?, String?) -> Void ) {
        
        let url = storeItem.artworkUrl
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url) { (data, response, error) in
            if let data = data, let image = UIImage(data: data) {
                completion(image, nil)
            } else {
                completion(nil, error.debugDescription)
                return
            }
        }
        dataTask.resume()
    }
}
