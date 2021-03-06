//
//  TableViewController.swift
//  Recipe
//
//  Created by Anna on 20.06.17.
//  Copyright © 2017 Anna. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CoreData

class TableViewController: UITableViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    
    var isSearching = false
    
    var defaultRecipes = [NSManagedObject]()
    var searchedRecipes = [NSManagedObject]()
    var recipesDefaultFromFirebase = [NSManagedObject]()
    var recipesSearchFromFirebase = [NSManagedObject]()

    var item = [String : AnyObject]()
    

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
    
    //NUMBER OF ROWS

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearching {
            return recipesSearchFromFirebase.count
        } else {
            return recipesDefaultFromFirebase.count
        }
    }

    // CELL FOR ROW
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Bundle.main.loadNibNamed("CustomCell", owner: self, options: nil)?.first as! CustomCell
        
        var cellImage = UIImage()
        
        

        if isSearching {
            
            let recipe = recipesSearchFromFirebase[indexPath.row]
            
            cell.titleLabel.text = recipe.value(forKey: titleString) as? String
            cell.recipeLabel.text = recipe.value(forKey: ingredientsString) as? String
            if recipe.value(forKey: thumbnailString) as? String != "" {
                cellImage = stringToImage(string: (recipe.value(forKey: thumbnailString) as? String)!)
            } else {
                cellImage = #imageLiteral(resourceName: "NoImageIcon.png")
            }
            cell.photoImage.image = cellImage
            
        } else {
            
            let recipe = recipesDefaultFromFirebase[indexPath.row]
            
            cell.titleLabel.text = recipe.value(forKey: titleString) as? String
            cell.recipeLabel.text = recipe.value(forKey: ingredientsString) as? String
            if recipe.value(forKey: thumbnailString) as? String != "" {
                cellImage = stringToImage(string: (recipe.value(forKey: thumbnailString) as? String)!)
            } else {
                cellImage = #imageLiteral(resourceName: "NoImageIcon.png")
            }
            cell.photoImage.image = cellImage
        }
        
        return cell

    }
    
    // DID SELECT ROW AT INDEX PATH
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isSearching {
            let url = URL(string: recipesSearchFromFirebase[indexPath.row].href)
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            
        } else {
            let url = URL(string: recipesDefaultFromFirebase[indexPath.row].href)
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)

        }
    }
    
    //SEARCH BAR TEXT DID CHANGED
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if  searchBar.text == "" {
            isSearching = false
            view.endEditing(true)
            getData()
            tableView.reloadData()
        }

    }
    
    // SEARCH BUTTON CLICKED
    
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
    
    // PARSE DATA
    
    func parseData(url: URL) -> [Recipe] {
        
        var recipeArray = [Recipe]()
        do {
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String: Any]
            let result = json[resultsString] as! [[String:AnyObject]]
            
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
    
    // GET DATA
    
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
    
    // RETRIEVE DATA
    
    func retrieveDataFromFirebase(isSearching: Bool) {
        
        if isSearching {
        
            ref?.child(searchString).observe(.childAdded, with: { (snapshot) in
                
                self.item = snapshot.value! as! [String : AnyObject]
                let singleRecipe = Recipe(dictionary: self.item)
                self.recipesSearchFromFirebase.append(singleRecipe)
                
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
                if self.recipesDefaultFromFirebase.count == 10 {
                    self.tableView.reloadData()
                  //  return
                }
            })
        }
    }
    
   
    

}
