//
//  Custom Functions.swift
//  Recipe
//
//  Created by Anna on 21.06.17.
//  Copyright © 2017 Anna. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase


var ref: DatabaseReference? = Database.database().reference()



//MARK: Save data to Firebase
func saveDataToFirebase(text: [String : Any]) {
    
    
    ref?.child(dishesString).childByAutoId().setValue(text)
    
}

func stringToImage(string: String) -> UIImage {
    let imageUrl = URL(string: string)!
    let data = NSData(contentsOf: imageUrl)
    let image = UIImage(data:data! as Data)!
    
    return image
    
}




