//
//  FileServcies.swift
//  iTunesSearch
//
//  Created by Mohammad Shayan on 4/24/20.
//  Copyright © 2020 Caleb Hicks. All rights reserved.
//

import UIKit

struct FileService {
    static let shared = FileService()
    
    let documentsDirectory: URL
    let archiveURL: URL
    
    init() {
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        archiveURL = documentsDirectory.appendingPathComponent("favorites_itunes_search").appendingPathExtension("plist")
    }
}
