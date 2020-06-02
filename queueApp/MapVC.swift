//
//  MapVC.swift
//  queueApp
//
//  Created by Bambam on 28/4/20.
//  Copyright © 2020 Bambam. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class MapVC: UIViewController, SendAddressDelegate {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var chooseButton: UIButton!
    
    let locationManager = CLLocationManager()
    var previousLocation: CLLocation?
    var resultSearchController: UISearchController? = nil
    var selectedPin: MKPlacemark? = nil
    var address1 = ""
    var delegate : SendAddressDelegate?
    var locationTF = ""
    var laTF = Double()
    var longTF = Double()
    var latitude1 : Double!
    var longitude1 : Double!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButtonNavBar()
        setlocationSearchTable()
        setLocationManager()
        
        mapView.delegate = self
        
        print(locationTF)
        
        if locationTF == "" {
            if let location = locationManager.location?.coordinate {
                let region = MKCoordinateRegion(center: location, latitudinalMeters: 200, longitudinalMeters: 200)
                mapView.setRegion(region, animated: true)
            }
        }
        else {  //ถ้าได้รับค่าจาก textfield หน้าก่อนหน้า
            print(laTF)
            print(longTF)
            let location = CLLocationCoordinate2D(latitude: laTF, longitude: longTF)
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 200, longitudinalMeters: 200)
            let searchBar = resultSearchController!.searchBar
            searchBar.text = locationTF
            mapView.setRegion(region, animated: true)
        }
        chooseButton.layer.cornerRadius = 5
        chooseButton.addTarget(self, action: #selector(choose), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isTranslucent = false
    }

    override func viewWillDisappear(_ animated: Bool){
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    @objc func choose() {
        let searchBar = resultSearchController!.searchBar
        delegate?.sendAddress(address: searchBar.text ?? "", latitude: latitude1, longitude: longitude1)
        performSegueToReturnBack()
    }
    
    //ส่งค่ากลับมาจากการ search
    func sendAddress(address: String, latitude: Double, longitude: Double) {
        address1 = address
        latitude1 = latitude
        longitude1 = longitude
        let searchBar = resultSearchController!.searchBar
        searchBar.text = address1
    }
    
    func setLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func setlocationSearchTable() {
        let locationSearchTable = storyboard?.instantiateViewController(identifier: "LocationSearchTableVC") as! LocationSearchTableVC
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable as! UISearchResultsUpdating
        locationSearchTable.mapView = mapView
        locationSearchTable.delegate = self
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "ค้นหาจาก ชื่อสถานที่, ถนน"
        navigationItem.titleView = resultSearchController?.searchBar
        navigationController?.navigationBar.isTranslucent = false
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        locationSearchTable.handleMapSearchDelegate = self
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }

}

extension MapVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            previousLocation = getCenterLocation(for: mapView)
        }
    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if locationTF == "" {
//            if let location = locations.first {
//                let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
//                print("เข้ามาไหม")
//                mapView.setRegion(region, animated: true)
//            }
//        }
//        else {
//            let location = CLLocationCoordinate2D(latitude: laTF, longitude: longTF)
//            let region = MKCoordinateRegion(center: location, latitudinalMeters: 200, longitudinalMeters: 200)
//            let searchBar = resultSearchController!.searchBar
//            searchBar.text = locationTF
//            mapView.setRegion(region, animated: true)
//        }
//    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
}

extension MapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
//        guard let previousLocation = self.previousLocation else { print("fdddgdgdsgdsfgf"); return }
        
//        guard center.distance(from: previousLocation) > 50 else { print("fdddgdgdsgdsfkmmkmkmkmlkmgf"); return }
        self.previousLocation = center
        geoCoder.reverseGeocodeLocation(center, completionHandler: { (placemarks, error) in
            if let _ = error {
                return
            }
            guard let placemark = placemarks?.first else {
                return
            }
            let address = "\(String(placemark.subThoroughfare ?? "")) \(placemark.thoroughfare ?? "") \(placemark.subLocality ?? "") \(placemark.locality ?? "") \(placemark.administrativeArea ?? "") \(placemark.postalCode ?? "") \(placemark.country ?? "")"
            DispatchQueue.main.async {
                let searchBar = self.resultSearchController!.searchBar
                searchBar.text = address
                self.latitude1 = center.coordinate.latitude
                self.longitude1 = center.coordinate.longitude
//                if self.locationTF != "" {
//                    searchBar.text = self.locationTF
//                }
            }
        })
    }
}

extension MapVC: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
//        selectedPin = placemark
        // clear existing pins
//        mapView.removeAnnotations(mapView.annotations)
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = placemark.coordinate
//        annotation.title = placemark.name
//        if let city = placemark.locality,
//        let state = placemark.administrativeArea {
//            annotation.subtitle = "\(city) \(state)"
//        }
//        mapView.addAnnotation(annotation)
        let region = MKCoordinateRegion(center: placemark.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
        mapView.setRegion(region, animated: true)
    }
}
