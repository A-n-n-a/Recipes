//
//  TableViewController.swift
//  Recipe
//
//  Created by Anna on 20.06.17.
//  Copyright © 2017 Anna. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    
    var isSearching = false
    
    var defaultRecipes = [Recipe]()
    var searchedRecipes = [Recipe]()


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
        
        
        
        var recipeName = String()
        
        if isSearching {
            if searchBar.text != nil || searchBar.text != "" {
                recipeName = searchBar.text!
                let recipeNameAddingPercentEncoding = recipeName.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)
                let searchUrl = URL(string: "http://www.recipepuppy.com/api/?q\(recipeNameAddingPercentEncoding)")
                
                searchedRecipes = parseData(url: searchUrl!)
                print("COUNT 1: \(searchedRecipes.count)")
//                do {
//                    let data = try Data(contentsOf: searchUrl!)
//                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String: Any]
//                    //print(json)
//                    let result = json[resultsString] as! [[String:AnyObject]]
//                    
//                    //print("RESULT\n \(result)")
//                    //print(result.count)
//                    
//                    for i in result {
//                        
//                        let singleRecipe = Recipe(dictionary: i)
//                        
//                        searchedRecipes.append(singleRecipe)
//                    }
//                    print("SEARCH\n\(searchedRecipes.count)")
//                    //print(searchedRecipes[1])
//                    
//                    
//                    
//                }
//                catch {
//                    print(error)
//                }

            }
        } else {
            //Default url
            let defaultUrl = URL(string: "http://www.recipepuppy.com/api/?i=onions,garlic&q=omelet&p=3")
            
//            do {
//                let data = try Data(contentsOf: defaultUrl!)
//                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String: Any]
//                //print(json)
//                let result = json[resultsString] as! [[String:AnyObject]]
//                
//                //print("RESULT\n \(result)")
//                //print(result.count)
//                
//                for i in result {
//                    
//                    let singleRecipe = Recipe(dictionary: i)
//                    
//                    defaultRecipes.append(singleRecipe)
//                }
//                print(defaultRecipes.count)
//                print(defaultRecipes[1])
//                
//                
//                
//            }
//            catch {
//                print(error)
//            }
            
            defaultRecipes = parseData(url: defaultUrl!)
            print("COUNT 2: \(defaultRecipes.count)")

        }

    }



    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

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
        cell.photoImage.image = #imageLiteral(resourceName: "leather1.jpg")
        
        if isSearching {
            
            cell.titleLabel.text = searchedRecipes[indexPath.row].title
            cell.recipeLabel.text = searchedRecipes[indexPath.row].ingredients
            cell.photoImage.image = searchedRecipes[indexPath.row].recipeImage
            
        } else {
            
            cell.titleLabel.text = defaultRecipes[indexPath.row].title
            cell.recipeLabel.text = defaultRecipes[indexPath.row].ingredients
            cell.photoImage.image = defaultRecipes[indexPath.row].recipeImage
        }
        
        return cell

    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
            view.endEditing(true)
            tableView.reloadData()
        } else {
            isSearching = true
            tableView.reloadData()
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
            
            for i in result {
                
                let singleRecipe = Recipe(dictionary: i)
                
                recipeArray.append(singleRecipe)
            }
//            print(defaultRecipes.count)
//            print(defaultRecipes[1])
            
            
            
        }
        catch {
            print(error)
        }
            return recipeArray
    }
    

    


}
