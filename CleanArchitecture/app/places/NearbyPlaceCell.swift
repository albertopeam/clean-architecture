//
//  NearbyPlaceCell.swift
//  CleanArchitecture
//
//  Created by Penas Amor, Alberto on 19/4/18.
//  Copyright © 2018 Alberto. All rights reserved.
//

import UIKit
import Kingfisher

class NearbyPlaceCell: UITableViewCell {

    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var openLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func draw(place:Place) {
        nameLabel.text = place.name
        ratingLabel.text = "\(place.rating)"
        openLabel.text = place.openNow ? "OPEN":"!OPEN"
        let url = URL(string: place.icon)
        iconImageView.kf.setImage(with: url)
    }

    
}
