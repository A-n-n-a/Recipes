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
//    var dishes = [String]()
//    var id = String()
//    var idDefaultArray = [String]()
//    var idSearchArray = [String]()

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

        
        getData()
        
        retrieveDataFromFirebase(isSearching: isSearching)
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearching {
            return recipesSearchFromFirebase.count
        } else {
            return recipesDefaultFromFirebase.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Bundle.main.loadNibNamed("CustomCell", owner: self, options: nil)?.first as! CustomCell
        
        var cellImage = UIImage()

        if isSearching {
            
            cell.titleLabel.text = recipesSearchFromFirebase[indexPath.row].title
            cell.recipeLabel.text = recipesSearchFromFirebase[indexPath.row].ingredients
            if recipesSearchFromFirebase[indexPath.row].recipeImage != "" {
                cellImage = stringToImage(string: recipesSearchFromFirebase[indexPath.row].recipeImage!)
            } else {
                cellImage = #imageLiteral(resourceName: "NoImageIcon.png")
            }
            cell.photoImage.image = cellImage
            
        } else {
            
            cell.titleLabel.text = recipesDefaultFromFirebase[indexPath.row].title
            cell.recipeLabel.text = recipesDefaultFromFirebase[indexPath.row].ingredients
            if recipesDefaultFromFirebase[indexPath.row].recipeImage != "" {
                cellImage = stringToImage(string: recipesDefaultFromFirebase[indexPath.row].recipeImage!)
            } else {
                cellImage = #imageLiteral(resourceName: "NoImageIcon.png")
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
        }

    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
            view.endEditing(true)
        } else {
            isSearching = true
            getData()
            tableView.reloadData()
            retrieveDataFromFirebase(isSearching: isSearching)
        }
    }
    
 
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
            }
        } else {

            let defaultUrl = URL(string: "http://www.recipepuppy.com/api/?i=onions,garlic&q=omelet&p=3")
            defaultRecipes = parseData(url: defaultUrl!)
        }
    }
    
    func retrieveDataFromFirebase(isSearching: Bool) {
        
        if isSearching {
        
            ref?.child(searchString).observe(.childAdded, with: { (snapshot) in
                
                self.item = snapshot.value! as! [String : AnyObject]
                let singleRecipe = Recipe(dictionary: self.item)
                self.recipesSearchFromFirebase.append(singleRecipe)
//                self.id = snapshot.key
//                self.idSearchArray.append(self.id)
               // print(self.idSearchArray.count)
                print("INSIDE CLOSURE\n\(self.recipesSearchFromFirebase.count)")
                
                if self.recipesSearchFromFirebase.count == 10 {
                    self.tableView.reloadData()
                    //  return
                }
                
            })
        } else {
            
            ref?.child(defaultString).observe(.childAdded, with: { (snapshot) in
                
                self.item = snapshot.value! as! [String : AnyObject]
                let singleRecipe = Recipe(dictionary: self.item)
                self.recipesDefaultFromFirebase.append(singleRecipe)
//                self.id = snapshot.key
//                self.idDefaultArray.append(self.id)
                //print(self.idDefaultArray.count)
                //print("INSIDE CLOSURE\n\(self.recipesDefaultFromFirebase.count)")
                
                if self.recipesDefaultFromFirebase.count == 10 {
                    self.tableView.reloadData()
                  //  return
                }
            })
        }
    }
    

}
