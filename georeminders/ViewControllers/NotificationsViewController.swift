//
//  ViewController.swift
//  bert8270_final
//
//  Created by Tudor Bertiean on 2018-03-21.
//  Copyright © 2018 wlu. All rights reserved.
//

import UIKit
import CoreLocation


class NotificationsViewController: UITableViewController {
    private var notifications : [Notification] = []
    let locationManager = CLLocationManager()
    
    @IBOutlet var infoButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBAction func infoButtonAction(_ sender: Any) {
        Helper.showAlert(controller: self, title: "Maxed out!", message: "You are only allowed up to 20 notifications! Please swipe to delete some to keep on making more.")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = DataStore() // get the Singleton instance
        DataStore.sharedInstance.loadDeck() // un-archive data
        notifications = (DataStore.sharedInstance.getDeck().getNotifications())
        setupAddButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    // Form each table cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "NotificationTableViewCell"

        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? NotificationTableViewCell  else {
            fatalError("The dequeued cell is not an instance of NotificationTableViewCell.")
        }
        
        let notification = notifications[indexPath.row]
        cell.messageLabel.text = notification.getMessage()
        cell.locationLabel.text = notification.getLocation()
        cell.radiusLabel.text = "Radius: " + String(notification.getRadius()) + "m"
        cell.toggleSwitch.isOn = notification.isOn()
        cell.toggleSwitch.tag = indexPath.row
        cell.toggleSwitch.addTarget(self, action: #selector(self.switchToggled(_:)), for: .valueChanged)
        
        return cell
    }
    
    @objc func switchToggled(_ sender : UISwitch!){
        let index = sender.tag
        let notification = notifications[index]
        notification.setOn(on: sender.isOn, locationManager: locationManager, viewcontroller: self)
        // Ensure that the users has notifications enabled
        Helper.checkNotificationAccess(completionHandler: { (able) -> Void in
            if able == false {
                Helper.showAlert(controller: self, title: "Warning", message: "You will not receive notifications until they are enabled. Go into your phone's Settings app and locate 'GeoReminders' and enable your notifications for 'On'.")
            }
            
        })
        saveNewDeck()
    }
    
    // Handle the deleting of a question by swipe
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            notifications.remove(at: indexPath.row)
            saveNewDeck()
            setupAddButton()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    @IBAction func unwindToDeckView(sender: UIStoryboardSegue){
        if let sourceViewController = sender.source as? AddViewController, let notification =
            sourceViewController.getNotification() {
            notification.startMonitoring(locationManager: locationManager, viewcontroller: self)
            // Check if there is a new notification being added or if an existing one is edited
            if sourceViewController.getIsEdit() {
                let editIndexPath = tableView.indexPathForSelectedRow
                notifications[(editIndexPath?.row)!] = notification
                tableView.reloadData()
            } else {
                let newIndexPath = IndexPath(row: (notifications.count), section: 0)
                notifications.append(notification)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            setupAddButton()
            saveNewDeck()
        }
        
        // Ensure that the users has notifications enabled
        Helper.checkNotificationAccess(completionHandler: { (able) -> Void in
            if able == false {
                Helper.showAlert(controller: self, title: "Warning", message: "You will not receive notifications until they are enabled. Go into your phone's Settings app and locate 'GeoReminders' and enable your notifications for 'On'.")
            }

        })
    }
    
    
    // Set to deck and save to device
    func saveNewDeck() {
        DataStore.sharedInstance.getDeck().setNotifications(notifications: notifications)
        Helper.saveData()
    }
    
    // iOS only allows an application a max 20 geolocation triggers. If user already has 20,
    // disable the add button and show them the info button to see what the problem is
    private func setupAddButton() {
        if notifications.count >= 20 {
            addButton.isEnabled = false
            self.infoButton.isEnabled = true
            self.infoButton.tintColor = UIColor.red
        } else {
            addButton.isEnabled = true
            self.infoButton.isEnabled = false
            self.infoButton.tintColor = UIColor.clear
        }
    }
    
    // Send the notification to the AddViewController in the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navController = segue.destination as? UINavigationController {
            if let indexPath = tableView.indexPathForSelectedRow{
                let viewController = navController.topViewController as! AddViewController
                let selectedRow = indexPath.row
                viewController.isEdit = true
                viewController.notification = notifications[selectedRow]
            }
        }
    }
}

