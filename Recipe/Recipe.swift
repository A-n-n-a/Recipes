//
//  File.swift
//  Recipe
//
//  Created by Anna on 20.06.17.
//  Copyright © 2017 Anna. All rights reserved.
//

import Foundation
import UIKit

struct Recipe {
    
    var title: String
    var href: String
    var ingredients: String
    var recipeImage: String?
    
    init(dictionary: [String:AnyObject]) {
        
        let title = dictionary[titleString] as! String
        let ingredients = dictionary[ingredientsString] as! String
        let href = dictionary[hrefString] as! String
        

        let thumbnail = dictionary[thumbnailString] as! String?
        let stringImage = thumbnail ?? ""

        
        self.title = title
        self.href = href
        self.ingredients = ingredients
        self.recipeImage = stringImage
        
    }
    
}
