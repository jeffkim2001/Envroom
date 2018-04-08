//
//  MakeViewController.swift
//  Envroom
//
//  Created by Jeff Kim on 3/24/18.
//  Copyright © 2018 Jeff Kim. All rights reserved.
//

import UIKit
import SCLAlertView
var selectedMake : String = ""
let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Makes.plist")

class MakeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var makeTableView: UITableView!
    
    var carMakeArray = [CarMake(), CarMake(), CarMake(), CarMake(), CarMake(), CarMake(), CarMake(), CarMake(), CarMake(), CarMake(), CarMake(), CarMake(), CarMake(), CarMake(), CarMake(), CarMake(), CarMake(), CarMake(), CarMake(), CarMake(), CarMake(), CarMake(), CarMake(), CarMake(), CarMake(), CarMake(), CarMake(), CarMake(), CarMake(), CarMake(), CarMake(), CarMake(), CarMake(), CarMake(), CarMake(), CarMake(), CarMake(), CarMake(), CarMake(), CarMake()]
    let makeNameArray : [String] = ["Acura", "Audi", "BMW", "Buick", "Cadillac", "Chevrolet", "Chrysler", "Dodge", "Ferrari", "Ford", "GMC", "Honda", "HUMMER", "Hyundai", "Infiniti", "Isuzu", "Jaguar", "Jeep", "Kia", "Lexus", "Lincoln", "Lotus", "Maserati", "Mazda", "Mercedes-Benz", "Mercury", "MINI", "Mitsubishi", "Nisssan", "Pontiac", "Porsche", "Rolls-Royce", "Saab", "Saturn", "Scion", "Subaru", "Suzuki", "Toyota", "Volkswagen", "Volvo"]

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCheckedData()
        navigationItem.title = "Car Makes"
        makeTableView.delegate = self
        makeTableView.dataSource = self
        makeTableView.register(UINib(nibName: "MakeCell", bundle: nil), forCellReuseIdentifier: "makeCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return makeNameArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = makeTableView.dequeueReusableCell(withIdentifier: "makeCell", for: indexPath) as! MakeCell
        cell.makeNameLabel?.text = makeNameArray[indexPath.row]
        cell.selectionStyle = .none
        cell.makeNameLabel?.numberOfLines = 1
        cell.makeNameLabel?.minimumScaleFactor = 0.5
        cell.makeNameLabel?.adjustsFontSizeToFitWidth = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedMake = makeNameArray[indexPath.row]
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue-Light", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue-Light", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Light", size: 14)!,
            showCloseButton: false
        ))
        alert.addButton("OK", action: {
            alert.dismiss(animated: true, completion: nil)
        })
        alert.showSuccess("Car Make Selected!", subTitle: "You have selected a car make!")
    }
    
    func saveCheckedData() {
        let encoder = PropertyListEncoder()
        do {
            let data = try? encoder.encode(carMakeArray)
            try data?.write(to: dataFilePath!)
        } catch {
            print("Error encoding data: \(error)")
        }
    }
    
    func loadCheckedData() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                carMakeArray = try decoder.decode([CarMake].self, from: data)
            } catch {
                print("Error decoding item array: \(error)")
            }
        }
    }

}
