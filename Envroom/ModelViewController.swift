//
//  ModelViewController.swift
//  Envroom
//
//  Created by Jeff Kim on 3/24/18.
//  Copyright © 2018 Jeff Kim. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData
import SVProgressHUD
import SCLAlertView

let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

class ModelViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var modelTableView: UITableView!
    var modelName : String = ""
    
    var vpicModelURL : String = ""
    var models = [CarModel]()
    var selectedMake: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.layer.borderWidth = 0
        searchBar.layer.borderColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1).cgColor
        searchBar.barTintColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        searchBar.tintColor = UIColor.black
        loadModels()
        vpicModelURL = "https://vpic.nhtsa.dot.gov/api/vehicles/GetModelsForMake/\(selectedMake.lowercased())"
        searchBar.delegate = self
        navigationItem.title = "Car Models"
        SVProgressHUD.setForegroundColor(UIColor.green)
        SVProgressHUD.show()
        requestCarModels()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func requestCarModels() {
        let parameters : [String: String] = ["format" : "json"]
        Alamofire.request(vpicModelURL, method: .get, parameters: parameters).responseJSON {
            (response) in
            if response.result.isSuccess {
                let carModelJSON : SwiftyJSON.JSON = JSON(response.result.value!)
                for number in 0..<carModelJSON["Count"].intValue {
                    let modelName = carModelJSON["Results"][number]["Model_Name"].stringValue
                    let newModel = CarModel(context: context)
                    newModel.modelName = modelName
                    self.models.append(newModel)
                }
                self.modelTableView.delegate = self
                self.modelTableView.dataSource = self
                self.modelTableView.register(UINib(nibName: "ModelCell", bundle: nil), forCellReuseIdentifier: "modelCell")
                self.modelTableView.bounces = true
                self.modelTableView.reloadData()
                self.configureModelTableView()
                SVProgressHUD.dismiss()
            }
            else {
                SVProgressHUD.dismiss()
            }
        }
    }
    
    func configureModelTableView() {
        modelTableView.rowHeight = UITableViewAutomaticDimension
        modelTableView.estimatedRowHeight = 120.0
    }
    
    func saveModels() {
        do {
            try context.save()
        }
        catch {
            print("Error saving context \(error)")
        }
        
    }
    
    func loadModels(with request: NSFetchRequest<CarModel> = CarModel.fetchRequest()) {
        do {
            models = try context.fetch(request)
        }
        catch {
            print("Error fetching data from context \(error)")
        }
        modelTableView.reloadData()
    }
    

}

extension ModelViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadModels()
        }
        else {
            let request: NSFetchRequest<CarModel> = CarModel.fetchRequest()
            
            request.predicate = NSPredicate(format: "modelName BEGINSWITH[cd] %@", searchText)
            
            request.sortDescriptors = [NSSortDescriptor(key: "modelName", ascending: false)]
            loadModels(with: request)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
}

extension ModelViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = modelTableView.dequeueReusableCell(withIdentifier: "modelCell", for: indexPath) as! ModelCell
        cell.modelLabel.text = models[indexPath.row].modelName
        cell.selectionStyle = .none
        cell.modelLabel.numberOfLines = 1
        cell.modelLabel.minimumScaleFactor = 0.5
        cell.modelLabel.adjustsFontSizeToFitWidth = true
        return cell
    }
}

extension ModelViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        modelName = models[indexPath.row].modelName!
        let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue-Light", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue-Light", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Light", size: 14)!,
            showCloseButton: false
        ))
        alert.addButton("OK", action: {
            alert.dismiss(animated: true, completion: nil)
        })
        alert.showSuccess("Car Model Selected!", subTitle: "You have selected a car model!")
        let modelDict = ["model" : modelName]
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateModel"), object: nil, userInfo: modelDict)
    }
    
}
