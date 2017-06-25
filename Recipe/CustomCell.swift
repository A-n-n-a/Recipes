//
//  CustomCell.swift
//  Recipe
//
//  Created by Anna on 20.06.17.
//  Copyright © 2017 Anna. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {


    @IBOutlet weak var viewForBounds: UIView!
    
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var recipeLabel: UILabel!

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
