//
//  LocationSearchTableVC.swift
//  queueApp
//
//  Created by Bambam on 28/4/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import UIKit
import MapKit

protocol SendAddressDelegate : class {
    func sendAddress(address: String, latitude: Double, longitude: Double)
}

class LocationSearchTableVC: UITableViewController {
    
    var matchingItems: [MKMapItem] = []
    var mapView: MKMapView? = nil
    var handleMapSearchDelegate: HandleMapSearch? = nil
    var delegate: SendAddressDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationSearchCell", for: indexPath)
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        
        let streetno = String(selectedItem.subThoroughfare ?? "")
        let alley = selectedItem.thoroughfare ?? ""
        let subdistrict = selectedItem.subLocality ?? ""
        let district = selectedItem.locality ?? ""
        let city = selectedItem.administrativeArea ?? ""
        let postalcode = selectedItem.postalCode ?? ""
        let country = selectedItem.country ?? ""
        let address = "\(streetno) \(alley) \(subdistrict) \(district) \(city) \(postalcode) \(country)"
        cell.detailTextLabel?.text = address

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
        let streetno = String(selectedItem.subThoroughfare ?? "")
        let alley = selectedItem.thoroughfare ?? ""
        let subdistrict = selectedItem.subLocality ?? ""
        let district = selectedItem.locality ?? ""
        let city = selectedItem.administrativeArea ?? ""
        let postalcode = selectedItem.postalCode ?? ""
        let country = selectedItem.country ?? ""
        let address = "\(streetno) \(alley) \(subdistrict) \(district) \(city) \(postalcode) \(country)"
        delegate?.sendAddress(address: address, latitude: selectedItem.coordinate.latitude, longitude: selectedItem.coordinate.longitude)
        dismiss(animated: true, completion: nil)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LocationSearchTableVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView, let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearch.Request()
        
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        
        let ff = mapView.region
        
        let search = MKLocalSearch(request: request)
        
        search.start { (response, error) in
            guard let response = response else { return }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
        
    }
}
