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
        
        var imageFromUrl = UIImage()
        let thumbnail = dictionary[thumbnailString] as! String?
        var stringImage = thumbnail ?? ""
        if stringImage.characters.count > 0 {
            let url = URL(string: stringImage) //NSURL(string: strIcon)
            
            let data = NSData(contentsOf: url!)  //(contentsOfURL:url! as URL)
            //if data != nil {
            
            imageFromUrl = UIImage(data:data! as Data)!

        }
        
//        let url = URL(string: stringImage) //NSURL(string: strIcon)
//        
//        let data = NSData(contentsOf: url!)  //(contentsOfURL:url! as URL)
//        //if data != nil {
//        
//        var imageFromUrl = UIImage(data:data! as Data)!
        
        //let recipeImage = stringToImage(string: thumbnail)
        
        self.title = title
        self.href = href
        self.ingredients = ingredients
        self.recipeImage = stringImage
        
    }
    
//    init (title: String, href: String, ingredients: [String], thumbnail: String) {
//        self.title = title
//        self.href = href
//        self.ingredients = ingredients
//        self.thumbnail = thumbnail
//    }
}
