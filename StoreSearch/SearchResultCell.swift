//
//  SearchResultCell.swift
//  StoreSearch
//
//  Created by Roman Ustiantcev on 03/05/16.
//  Copyright © 2016 Roman Ustiantcev. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel:UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor(red: 20/255.0, green: 160/255.0, blue: 160/255.0, alpha: 1.0)
        selectedBackgroundView = selectedView
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }


}
