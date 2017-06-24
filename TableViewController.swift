//
//  TableViewController.swift
//  Recipe
//
//  Created by Anna on 20.06.17.
//  Copyright © 2017 Anna. All rights reserved.
//

import UIKit
import FirebaseDatabase

class TableViewController: UITableViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    
    var isSearching = false
    
    var defaultRecipes = [Recipe]()
    var searchedRecipes = [Recipe]()
    var recipesDefaultFromFirebase = [Recipe]()
    var recipesSearchFromFirebase = [Recipe]()

    var item = [String : AnyObject]()
    var dishes = [String]()
    var id = String()
    var idDefaultArray = [String]()
    var idSearchArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

//       let nib = UINib(nibName: "CustomCell", bundle: nil)
//        tableView.register(nib, forCellReuseIdentifier: "CustomCell")
        
        //self-resizing cell
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
        let backgroundImage = UIImage(named: "Puppy.png")
        let imageView = UIImageView(image: backgroundImage)
        self.tableView.backgroundView = imageView
        
        
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        
        retrieveDataFromFirebase(isSearching: isSearching)
        
        print(idDefaultArray.count)
        print(idDefaultArray)
        
        getData()
        
        // Cancel button color
        let cancelButtonAttributes: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes as? [String : AnyObject], for: UIControlState.normal)
       
        
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if isSearching {
            return searchedRecipes.count
        } else {
            return defaultRecipes.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        let cell = Bundle.main.loadNibNamed("CustomCell", owner: self, options: nil)?.first as! CustomCell
        cell.photoImage.image = #imageLiteral(resourceName: "leather Chanel.jpg")
        
        if isSearching {
            
            cell.titleLabel.text = searchedRecipes[indexPath.row].title
            cell.recipeLabel.text = searchedRecipes[indexPath.row].ingredients
            var cellImage = UIImage()
            if searchedRecipes[indexPath.row].recipeImage != "" {
                cellImage = stringToImage(string: searchedRecipes[indexPath.row].recipeImage!)
            }
            //let cellImage = stringToImage(string: searchedRecipes[indexPath.row].recipeImage!)
            cell.photoImage.image = cellImage
            
        } else {
            
            cell.titleLabel.text = defaultRecipes[indexPath.row].title
            cell.recipeLabel.text = defaultRecipes[indexPath.row].ingredients
            
            var cellImage = UIImage()
            if defaultRecipes[indexPath.row].recipeImage != "" {
                cellImage = stringToImage(string: defaultRecipes[indexPath.row].recipeImage!)
            }
            cell.photoImage.image = cellImage
        }
        
        return cell

    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if  searchBar.text == "" {
            isSearching = false
            view.endEditing(true)
            getData()
            tableView.reloadData()
//            } else {
//                                isSearching = true
//                                getData()
//                                tableView.reloadData()
        }

    }
    
//    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//                if  searchBar.text == "" {
//                    isSearching = false
//                    view.endEditing(true)
//                    getData()
//                   tableView.reloadData()
////                } else {
////                    isSearching = true
////                    getData()
////                    tableView.reloadData()
//                }
    
           // }
    
//    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        if searchBar.text == nil || searchBar.text == "" {
//            isSearching = false
//            view.endEditing(true)
//            getData()
//            tableView.reloadData()
//        } else {
//            isSearching = true
//            getData()
//            tableView.reloadData()
//        }
//
//    }
//    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
            view.endEditing(true)
            getData()
            tableView.reloadData()
        } else {
            isSearching = true
            getData()
            tableView.reloadData()
        }

    }
    
    
    
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        
//        searchBar.text = ""
//        getData()
//        
//    }
    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchBar.text == nil || searchBar.text == "" {
//            isSearching = false
//            view.endEditing(true)
//            getData()
//            tableView.reloadData()
//        } else {
//            isSearching = true
//            getData()
//            tableView.reloadData()
//        }
//
//    }

 
    func parseData(url: URL) -> [Recipe] {
        
        var recipeArray = [Recipe]()
        do {
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String: Any]
            //print(json)
            let result = json[resultsString] as! [[String:AnyObject]]
            
            //print("RESULT\n \(result)")
            //print(result.count)
            
            removeDataFromFirebase(isSearching: isSearching)
            
            for i in result {
                
                let singleRecipe = Recipe(dictionary: i)
                
                recipeArray.append(singleRecipe)
                
                let recipesItem = [
                        titleString: singleRecipe.title,
                        hrefString: singleRecipe.href,
                        ingredientsString: singleRecipe.ingredients,
                        thumbnailString: singleRecipe.recipeImage ?? " "
                        ] as [String : Any]
                
                saveDataToFirebase(text: recipesItem, isSearching: isSearching)
                
            }
//            print(defaultRecipes.count)
//            print(defaultRecipes[1])
            
            
            
        }
        catch {
            print(error)
        }
            return recipeArray
    }
    
    
    func getData() {
        if isSearching {
            if searchBar.text != nil || searchBar.text != "" {
                let recipeName = searchBar.text!
                let recipeNameAddingPercentEncoding = recipeName.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)
                
                let searchUrl = URL(string: "http://www.recipepuppy.com/api/?q=\(recipeNameAddingPercentEncoding!)")
                
                searchedRecipes = parseData(url: searchUrl!)
                //print("COUNT 1: \(searchedRecipes.count)")
                
               // saveDataToFirebase(text: <#T##String#>)
                
            }
        } else {
            //Default url
            let defaultUrl = URL(string: "http://www.recipepuppy.com/api/?i=onions,garlic&q=omelet&p=3")
            

            
            defaultRecipes = parseData(url: defaultUrl!)
            //print("COUNT 2: \(defaultRecipes.count)")
            
        }

    }
    
    func getDefaultData() {
        
        //Default url
        let defaultUrl = URL(string: "http://www.recipepuppy.com/api/?i=onions,garlic&q=omelet&p=3")
        defaultRecipes = parseData(url: defaultUrl!)


        
    }
    
    func retrieveDataFromFirebase(isSearching: Bool) {
        
        if isSearching {
        
            ref?.child(defaultString).observe(.childAdded, with: { (snapshot) in
                
                self.item = snapshot.value! as! [String : AnyObject]
                let singleRecipe = Recipe(dictionary: self.item)
                self.recipesSearchFromFirebase.append(singleRecipe)
                self.id = snapshot.key
                self.idSearchArray.append(self.id)
                print(self.idSearchArray.count)
                
            })
        } else {
            
            ref?.child(defaultString).observe(.childAdded, with: { (snapshot) in
                
                self.item = snapshot.value! as! [String : AnyObject]
                let singleRecipe = Recipe(dictionary: self.item)
                self.recipesDefaultFromFirebase.append(singleRecipe)
                self.id = snapshot.key
                self.idDefaultArray.append(self.id)
                print(self.idDefaultArray.count)
                
            })
        }
        

    }
    
//    func retrieveDefaultDataFromFirebase() {
//        
//        ref?.child(defaultString).observe(.childAdded, with: { (snapshot) in
//            
//            self.item = snapshot.value! as! [String : AnyObject]
//            let singleRecipe = Recipe(dictionary: self.item)
//            self.recipesDefaultFromFirebase.append(singleRecipe)
//            self.id = snapshot.key
//            self.idDefaultArray.append(self.id)
//            print(self.idDefaultArray.count)
//            
//        })
//        
//    }
//    
//    func retrieveSearchDataFromFirebase() {
//        
//        ref?.child(defaultString).observe(.childAdded, with: { (snapshot) in
//            
//            self.item = snapshot.value! as! [String : AnyObject]
//            let singleRecipe = Recipe(dictionary: self.item)
//            self.recipesSearchFromFirebase.append(singleRecipe)
//            self.id = snapshot.key
//            self.idSearchArray.append(self.id)
//            print(self.idSearchArray.count)
//            
//        })
//    }

}
