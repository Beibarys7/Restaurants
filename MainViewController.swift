//
//  MainTableViewController.swift
//  Restaurants
//
//  Created by Beibarys Shaggy on 17.08.2021.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var restaurants: Results<Restaurant>!
    private var filtredPlaces: Results<Restaurant>!
    private var asendingSorting = true
    private let searchController = UISearchController(searchResultsController: nil)
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return  false}
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var reversedSortingButton: UIBarButtonItem!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        restaurants = realm.objects(Restaurant.self)
        // setup Search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
    }


     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filtredPlaces.count
        }
        return restaurants.isEmpty ? 0 : restaurants.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell

        var place = Restaurant()
        if isFiltering {
            place = filtredPlaces[indexPath.row]
        } else {
            place = restaurants[indexPath.row]
        }

        cell.nameLabel?.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData! )
       

        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height / 2
        cell.imageOfPlace.clipsToBounds = true
        return cell
    }
    
     func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let place = restaurants[indexPath.row]
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (_, _) in
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        return [deleteAction]
    }
    
    
    // Mark: table View delegate
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    @IBAction func reversedSorting(_ sender: Any) {

        asendingSorting.toggle()
        
        if asendingSorting {
            reversedSortingButton.image = #imageLiteral(resourceName: "AZ")
        } else {
            reversedSortingButton.image = #imageLiteral(resourceName: "ZA")
        }
        
        sorting()
        
    }
    
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
            sorting()
    }

    
    private func sorting() {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            restaurants = restaurants.sorted(byKeyPath: "date", ascending: asendingSorting)
        } else {
            restaurants = restaurants.sorted(byKeyPath: "name", ascending: asendingSorting)
        }
        tableView.reloadData()
    }
    
    @IBAction func cancelAction(_ segue: UIStoryboardSegue) {}
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {

            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            if let newPlaceVC = segue.destination as? NewPlaceViewController {
                var place: Restaurant?
                if isFiltering {
                    place = filtredPlaces[indexPath.row]
                } else {
                    place = restaurants[indexPath.row]
                }
                newPlaceVC.currentPlace = place
            }
        }
    }
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
        newPlaceVC.saveNewPlace()
        tableView.reloadData()
    }

}

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filtredPlaces = restaurants.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        
        tableView.reloadData()
    }
    
}
