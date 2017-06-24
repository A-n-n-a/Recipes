
import Foundation
import UIKit
import FirebaseDatabase


var ref: DatabaseReference? = Database.database().reference()


func saveDataToFirebase(text: [String : Any], isSearching: Bool) {
    
    if isSearching {
        
        ref?.child(searchString).childByAutoId().setValue(text)
        
    } else {

        ref?.child(defaultString).childByAutoId().setValue(text)

    }
    
}

func removeDataFromFirebase(isSearching: Bool) {
    if isSearching {

        ref?.child(searchString).removeValue()
       
    } else {
        ref?.child(defaultString).removeValue()
        
    }
}

func stringToImage(string: String) -> UIImage {
    let imageUrl = URL(string: string)!
    let data = NSData(contentsOf: imageUrl)
    let image = UIImage(data:data! as Data)!
    
    return image
    
}




