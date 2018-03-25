//
//  SettingsViewController.swift
//  Envroom
//
//  Created by Jeff Kim on 3/24/18.
//  Copyright © 2018 Jeff Kim. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

var selectedYear: Int?
class SettingsViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var theYearCell: UITableViewCell!
    @IBOutlet weak var theModelCell: UITableViewCell!
    @IBOutlet weak var theMakeCell: UITableViewCell!
    @IBOutlet weak var selectedYearLabel: UILabel!
    @IBOutlet weak var selectedModelLabel: UILabel!
    @IBOutlet weak var selectedMakeLabel: UILabel!
    @IBOutlet var settingsTableView: UITableView!
    let yearPicker = UIPickerView()
    var selectedRow : Int = 0
    var years :[Int] = []
    let makes : [String] = []
    let dummy = UITextField(frame: CGRect.zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let attributes = [NSAttributedStringKey.font : UIFont(name: "Helvetica-Light", size: 20)!, NSAttributedStringKey.foregroundColor : UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        self.navigationItem.backBarButtonItem?.setTitleTextAttributes(attributes, for: UIControlState.normal)
        theMakeCell.layer.borderColor = UIColor.gray.cgColor
        theMakeCell.layer.borderWidth = 0.6
        theModelCell.layer.borderColor = UIColor.gray.cgColor
        theModelCell.layer.borderWidth = 0.6
        theYearCell.layer.borderColor = UIColor.gray.cgColor
        theYearCell.layer.borderWidth = 0.6
        view.addSubview(dummy)
        for number in 1980..<2018 {
            years.append(number)
        }
        settingsTableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        selectedMakeLabel.text = selectedMake
        selectedModelLabel.text = modelName
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            performSegue(withIdentifier: "seeMakes", sender: self)
        }
        else if indexPath.row == 1 {
            performSegue(withIdentifier: "seeModels", sender: self)
        }
        else {
            createYearPicker()
            createToolBar()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Car Information"
        }
        else {
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return UIScreen.main.bounds.height
        }
        else {
            return 70
        }
    }
    
    func createYearPicker() {
        yearPicker.delegate = self as UIPickerViewDelegate
        yearPicker.dataSource = self as UIPickerViewDataSource
        dummy.inputView = yearPicker
        yearPicker.selectRow(0, inComponent: 0, animated: true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return years.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(years[row])"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
         selectedRow = row
    }
    
    func createToolBar() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(SettingsViewController.dismissKeyboard))
        
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        dummy.inputAccessoryView = toolBar
        dummy.becomeFirstResponder()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        selectedYear = years[selectedRow]
        selectedYearLabel.text = "\(years[selectedRow])"
    }

}
