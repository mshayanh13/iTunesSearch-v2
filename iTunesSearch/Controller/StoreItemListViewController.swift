//
//  StoreItemListViewController.swift
//  iTunesSearch
//
//  Created by Mohammad Shayan on 4/24/20.
//


import UIKit

class StoreItemListViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var originalSearchResults = [StoreItem]()
    var dictionary = [String: [StoreItem]]()
    var kinds = [String]()
    var favorites = [StoreItem]()
    let favoritesString = Constants.favorites.rawValue
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kinds = [favoritesString]
        getFavorites()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
    }
    
    func getFavorites() {
        let propertyListDecoder = PropertyListDecoder()
        if let retrievedFavoritesData = try? Data(contentsOf: FileService.shared.archiveURL), let decodedFavorites = try? propertyListDecoder.decode(Array<StoreItem>.self, from: retrievedFavoritesData) {
            
            favorites = decodedFavorites
            dictionary[favoritesString] = favorites
            
        }
    }
    
    func saveFavorites() {
        if let favoritesArray = dictionary[favoritesString] {
            favorites = favoritesArray
            let propertyListEncoder = PropertyListEncoder()
            let encodedArray = try? propertyListEncoder.encode(favoritesArray)
            try? encodedArray?.write(to: FileService.shared.archiveURL, options: .noFileProtection)
        }
    }

    
    func getKindsArray() {
        kinds.removeAll()
        for key in dictionary.keys {
            if !kinds.contains(key) {
                kinds.append(key)
            }
        }
        if let favoriteIndex = kinds.firstIndex(of: favoritesString) {
            let favorite = kinds.remove(at: favoriteIndex)
            kinds.append(favorite)
        } else {
            kinds.append(favoritesString)
        }
    }
    
    func changeFavorite(currentItem: StoreItem, indexPath: IndexPath) {
        
        var item = StoreItem(storeItem: currentItem)
        item.changeFavorite()
        let kind = item.kind
        
        if item.isFavorite {
            dictionary[kind]!.remove(at: indexPath.row)
            
            if let _ = dictionary[favoritesString] {
                dictionary[favoritesString]!.append(item)
            } else {
                dictionary[favoritesString] = [item]
            }
            
            if dictionary[kind]!.count == 0 {
                dictionary[kind] = nil
                if let index = kinds.firstIndex(of: kind) {
                    kinds.remove(at: index)
                }
            }
            
        } else {
            dictionary[favoritesString]!.remove(at: indexPath.row)
            
            if originalSearchResults.contains(item) {
                if let _ = dictionary[kind] {
                    dictionary[kind]!.append(item)
                } else {
                    dictionary[kind] = [item]
                }
                
                if kinds.firstIndex(of: kind) == nil && originalSearchResults.count > 0 {
                    let index = kinds.firstIndex(of: favoritesString)!
                    kinds.insert(kind, at: index)
                }
            }
            
            
        }
        saveFavorites()
        tableView.reloadData()
    }
    
    func fetchMatchingItems() {
        
        let searchTerm = searchBar.text ?? ""
        
        
        if !searchTerm.isEmpty {
            
            let query: [String: String] = [
                "term": searchTerm,
                "media": "all",
                "country": "US",
                "explicit": "N",
                "lang": "en_us",
                "limit": "5"
            ]
            
            NetworkServices.shared.fetchItems(matching: query) { (storeItems, errorMessage) in
                guard let storeItems = storeItems else {
                    self.showErrorMessage(text: errorMessage)
                    return
                }
                DispatchQueue.main.async {
                    self.originalSearchResults = storeItems
                    var modifiedStoreItems = storeItems
                    for favorite in self.favorites {
                        if let index = modifiedStoreItems.firstIndex(of: favorite) {
                            modifiedStoreItems.remove(at: index)
                        }
                    }
                    let favoritesArray = self.dictionary[self.favoritesString]
                    self.dictionary = StoreItem.sortIntoKindDictionary(storeItems: modifiedStoreItems)
                    self.dictionary[self.favoritesString] = favoritesArray
                    self.getKindsArray()
                    self.tableView.reloadData()
                    
                    
                }
            }
        }
    }
}

extension StoreItemListViewController: UITableViewDelegate, UITableViewDataSource {

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        
        if let array = dictionary[favoritesString], array.count > 0 {
            return kinds.count
        } else {
            return kinds.count - 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return kinds[section].replacingOccurrences(of: "-", with: " ").capitalized
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        let kind = kinds[section]
        if let array = dictionary[kind] {
            return array.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let kind = kinds[indexPath.section]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "StoreItemCell", for: indexPath) as? StoreItemCell, let items = dictionary[kind] {
            
            let item = items[indexPath.row]
            cell.buttonTapAction = {
                self.changeFavorite(currentItem: item, indexPath: indexPath)
            }
            cell.configureCellWith(item)
            
            return cell
        }
        

        return StoreItemCell()
    }
    
    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension StoreItemListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        fetchMatchingItems()
        searchBar.resignFirstResponder()
    }
}

