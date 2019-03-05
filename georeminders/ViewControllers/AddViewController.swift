//
//  AddViewController.swift
//  bert8270_final
//
//  Created by Tudor Bertiean on 2018-03-21.
//  Copyright © 2018 wlu. All rights reserved.
//

import UIKit
import os.log
import MapKit
import CoreLocation
import UserNotifications


class AddViewController: UIViewController, UITextFieldDelegate{
    var store = DataStore.sharedInstance
    
    // Location based vars
    @IBOutlet var mapView: MKMapView!
    var locationManager = CLLocationManager()
    private var userLocation: CLLocation?
    
    @IBOutlet var centerLocationImage: UIImageView!
    
    var notification: Notification?
    var isEdit = false
    @IBOutlet var inputText: UITextField!
    
    // Save new/edited notification. Perform all checks before submitting
    @IBAction func submitButton(_ sender: Any) {
        if ((inputText.text?.isEmpty)!) {
            Helper.showAlert(controller: self, title: "Error", message: "Complete all the fields first")
            return
        }
        // Check for missing permissions and don't allow submit if one is not set
        else if !Helper.checkLocationAccess(viewcontroller: self) {
            return
        }
        else {
            performSegue(withIdentifier: "unwindToDeckView", sender: self)
        }
    }
    
    // Dismiss View without making any changes
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Radius slider vars
    private var radiusValue = 200
    @IBOutlet weak var slider: UISlider!
    @IBAction func radiusSlider(_ sender: UISlider) {
        radiusValue = Int(slider.value)
        removeRadiusOverlay()
        addRadiusOverlay()
    }
    
    @IBOutlet var locationText: UITextField!
    @IBAction func locationGoButton(_ sender: Any) {
        // Send address text and if Apple maps detects the address, set text and move mapview to that coordinate
        Helper.convertAddressToCoord(address: locationText.text!, locationText: self.locationText, completionHandler: { (coordinate) -> Void in
            if coordinate != nil {
                self.moveMapView(coordinate: coordinate!)
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        // Set all the data if user is editing
        if isEdit {
            self.title = "Edit Notification"
            radiusValue = Int(notification!.getRadius())
            slider.value = Float(notification!.getRadius())
            inputText.text = notification?.getMessage()
            moveMapView(coordinate: (notification?.getCoordinate())!)
        }
        centerLocationImage.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(centerTapped))
        centerLocationImage.addGestureRecognizer(tapRecognizer)
        
        // Handle keyboard dismissing
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)

        self.locationText.delegate = self
        self.inputText.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // prepare to send the card back to the NotificationsViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        notification = Notification(coordinate: mapView.centerCoordinate, radius: CLLocationDistance(radiusValue), message: inputText.text!, on: true, location: locationText.text!)
    }
    
    // Dismiss keyboard on return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        locationText.resignFirstResponder()
        inputText.resignFirstResponder()
        return true
    }
    
    // Dismiss keyboard by tap
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func centerTapped() {
        moveMapView(coordinate: (userLocation?.coordinate)!)
    }
    
    func getNotification() -> Notification? {
        return notification!
    }
    
    func getIsEdit() -> Bool {
        return isEdit
    }
}

extension AddViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer {
            userLocation = locations.last
        }
        
        // On initial location update, unless is edit, zoom in on the user and add the radius circle
        if userLocation == nil && isEdit == false {
            if let loc = locations.last {
                moveMapView(coordinate: loc.coordinate)
                Helper.convertCoordToAddress(location: loc, locationText: self.locationText)
            }
        }
    }
    
    // Error checking for debugging purposes
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error)")
    }
  }

// MARK: - MapView Delegate
extension AddViewController: MKMapViewDelegate {
    
    // When user stops scrolling, update radius circle to reflect the center once again
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        removeRadiusOverlay()
        addRadiusOverlay()
        Helper.convertCoordToAddress(location: CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude), locationText: self.locationText)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = UIColor(red:0.15, green:0.68, blue:0.38, alpha:1.0)
            circleRenderer.fillColor = UIColor(red:0.15, green:0.68, blue:0.38, alpha:0.4)
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func moveMapView(coordinate: CLLocationCoordinate2D){
        let viewRegion = MKCoordinateRegionMakeWithDistance(coordinate, 2000, 2000)
        mapView.setRegion(viewRegion, animated: false)
    }
    
    func addRadiusOverlay() {
        mapView?.add(MKCircle(center: mapView.centerCoordinate, radius: CLLocationDistance(radiusValue)))
    }
    
    func removeRadiusOverlay() {
        // Find exactly one overlay which has the same coordinates & radius to remove
        guard let overlays = mapView?.overlays else { return }
        for overlay in overlays {
            mapView?.remove(overlay)
        }
    }
}
