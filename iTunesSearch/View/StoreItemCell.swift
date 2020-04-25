//
//  StoreItemCell.swift
//  iTunesSearch
//
//  Created by Mohammad Shayan on 4/24/20.
//  Copyright © 2020 Caleb Hicks. All rights reserved.
//

import UIKit

class StoreItemCell: UITableViewCell {

    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var urlTextView: UITextView!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var buttonTapAction: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        urlTextView.isEditable = false
        urlTextView.dataDetectorTypes = .all
        
        favoriteButton.imageView?.contentMode = .scaleAspectFit
    }
    
    func configureCellWith(_ storeItem: StoreItem) {
        itemImage.image = UIImage(named: "gray")!
        nameLabel.text = storeItem.trackName
        genreLabel.text = storeItem.genre
        urlTextView.text = storeItem.trackUrl.absoluteString
        if storeItem.isFavorite {
            print("MSH: button for: \(storeItem.trackName) should be red")
            favoriteButton.imageView?.image = UIImage(named: Constants.redHeart.rawValue)
        } else {
            favoriteButton.imageView?.image = UIImage(named: Constants.emptyHeart.rawValue)
        }
        favoriteButton.addTarget(self, action: #selector(heartButtonTapped(_:)), for: .touchUpInside)
        updateImage(storeItem: storeItem)
    }
    
    @objc func heartButtonTapped(_ sender: UIButton) {
        buttonTapAction?()
    }
    
    func updateImage(storeItem: StoreItem) {
        NetworkServices.shared.updateImage(storeItem: storeItem) { (image, errorMessage) in
            
            if let image = image {
                DispatchQueue.main.async {
                    self.itemImage.image = image
                    
                }
            } else {
                print("MSH: \(errorMessage ?? "Error")")
            }
            
        }
    }

}
