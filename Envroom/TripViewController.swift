//
//  ViewController.swift
//  Envroom
//
//  Created by Jeff Kim on 3/24/18.
//  Copyright © 2018 Jeff Kim. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation
import SwiftyXMLParser
import MapKit
import UserNotifications


class TripViewController: UIViewController {
    
    let idURL : String = "http://fueleconomy.gov/ws/rest/vehicle/menu/options"
    let mpgURL : String = ""
    var carID : Int? = nil
    var mpg : Double? = nil
    var count : Int = 0
    let locationManager = CLLocationManager()
    var startLocation: CLLocation!
    var lastLocation: CLLocation!
    var startDate: Date!
    var traveledDistance: Double = 0
    var traveledDistanceInMiles : Double = 0.00
    var gallonValue : Double = 0.00
    var CO2Value : Double = 0.00
    var trackingPressed:  Bool = false
    var carMake: String = ""
    var carModel: String = ""
    var carYear: Int?
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var gallonsSpent: UILabel!
    @IBOutlet weak var carbonEmission: UILabel!
    @IBOutlet weak var startTracking: UIButton!
    @IBOutlet weak var trackButton: UIButton!
    @IBOutlet weak var carLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    
    @objc func updateMake(_ notification: NSNotification) {
        if let make = notification.userInfo!["make"] as? String {
            carMake = make
        }
    }
    
    @objc func updateModel(_ notification: NSNotification) {
        if let model = notification.userInfo!["model"] as? String {
            carModel = model
        }
    }
    
    @objc func updateYear(_ notification: NSNotification) {
        if let year = notification.userInfo!["year"] as? Int {
            carYear = year
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateMake(_:)), name: Notification.Name(rawValue: "updateMake"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateModel(_:)), name: Notification.Name(rawValue: "updateModel"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateYear(_:)), name: Notification.Name(rawValue: "updateYear"), object: nil)
        topView.layer.borderColor = UIColor.green.cgColor
        topView.layer.borderWidth = 1
        mapView.layer.borderColor = UIColor.green.cgColor
        mapView.layer.borderWidth = 1
        let attributes = [NSAttributedStringKey.font : UIFont(name: "Helvetica-Light", size: 20)!, NSAttributedStringKey.foregroundColor : UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        self.navigationItem.backBarButtonItem?.setTitleTextAttributes(attributes, for: UIControlState.normal)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in
            if error != nil {
                print("Authorization Unsuccessful")
            }
            else {
                print("Authorization Successful")
            }
        }
        trackButton.setTitle("Start Tracking", for: .normal)
        trackButton.backgroundColor = UIColor.green
        trackButton.layer.cornerRadius = 10
        trackButton.layer.masksToBounds = true
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            locationManager.startMonitoringSignificantLocationChanges()
            locationManager.distanceFilter = 10
            mapView.showsUserLocation = true
            mapView.userTrackingMode = .follow
            mapView.isUserInteractionEnabled = true
            mapView.isScrollEnabled = true
            mapView.isZoomEnabled = true
        }
        gallonsSpent.text = "Gallons Spent: 0.00 gallons"
        carbonEmission.text = "Amount of CO2 Emitted: 0.00 lbs"
        gallonsSpent.numberOfLines = 1
        gallonsSpent.minimumScaleFactor = 0.5
        gallonsSpent.adjustsFontSizeToFitWidth = true
        carbonEmission.numberOfLines = 1
        carbonEmission.minimumScaleFactor = 0.5
        carbonEmission.adjustsFontSizeToFitWidth = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if carYear != 1980 && carMake != "" && carModel != "" {
            requestID()
        }
        if carYear != nil {
            carLabel.text = "\(carYear!) \(carMake) \(carModel)"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func requestID() {
        if carYear != nil {
            let parameters : [String: String] = ["year" : "\(carYear!)", "make" : carMake, "model" : carModel]
            Alamofire.request(idURL, method: .get, parameters: parameters).responseData {
                (response) in
                if response.result.isSuccess {
                    if let data = response.data {
                        let xml = XML.parse(data)
                        if let theID = xml["menuItems", "menuItem", 0, "value"].int {
                            self.carID = theID
                            self.requestMPG(id: self.carID!)
                        }
                        
                    }
                }
            }
        }
    }
    
    func requestMPG(id: Int) {
        if carID != nil {
            let parameters : [String: String] = [:]
            Alamofire.request("http://fueleconomy.gov/ws/rest/ympg/shared/ympgVehicle/\(id)", method: .get, parameters : parameters).responseData {
                (response) in
                if response.result.isSuccess {
                    if let data = response.data {
                        let xml = XML.parse(data)
                        if let theMPG = xml["yourMpgVehicle", "avgMpg"].double {
                            self.mpg = theMPG
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func trackingPressed(_ sender: Any) {
        if !trackingPressed {
            trackingPressed = true
            trackButton.backgroundColor = UIColor.red
            trackButton.setTitle("Stop Tracking", for: .normal)
        }
        else {
            trackingPressed = false
            trackButton.backgroundColor = UIColor.green
            trackButton.setTitle("Start Tracking", for: .normal)
        }
    }
    
    func timedNotifications(inSeconds: TimeInterval, completion: @escaping (_ Success: Bool) -> ()) {
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: inSeconds, repeats: false)
        let content = UNMutableNotificationContent()
        
        content.title = "Warning!"
        content.subtitle = "Too Much Driving!"
        content.body = "You have exceeded the recommended amount of CO2 emissions. Be sure to drive less in the future!"
        let request = UNNotificationRequest(identifier: "customNotification", content: content, trigger: trigger )
        UNUserNotificationCenter.current().add(request) { (error) in
            if error != nil {
                completion(false)
            }
            else {
                completion(true)
            }
        }
    }
    
}

extension TripViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if (error as? CLError)?.code == .denied {
            manager.stopUpdatingLocation()
            manager.stopMonitoringSignificantLocationChanges()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        mapView.showsUserLocation = true
        if startDate == nil {
            startDate = Date()
        }
        if startLocation == nil {
            startLocation = locations.first
        } else if let location = locations.last {
            if trackingPressed {
                traveledDistance += lastLocation.distance(from: location)
            }
            traveledDistanceInMiles = (100 * traveledDistance * 0.000621371) / 100
            if mpg != nil {
                gallonValue = (100 * (traveledDistanceInMiles/mpg!)) / 100
                CO2Value = (100 * gallonValue * 19.64) / 100
                gallonsSpent.text = "Fuel Spent: " + String(format: "%.2f", gallonValue) + " gallons"
                carbonEmission.text = "Amount of CO2 Emitted: " + String(format: "%.2f", CO2Value) + " lbs"
                if CO2Value > 27.78 {
                    if count == 0 {
                        timedNotifications(inSeconds: 1) { (success) in
                            if success {
                                print("Successfully Notified")
                            }
                        }
                        count = count + 1
                    }
                    
                }
            }
        }
        lastLocation = locations.last
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        if hour == 0 && minutes == 0 {
            traveledDistance = 0
            gallonsSpent.text = "Gallons Spent: 0.00 gallons"
            carbonEmission.text = "Amount of CO2 Emitted: 0.00 lbs"
        }
    }
}

