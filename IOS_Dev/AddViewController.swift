//
//  AddViewController.swift
//  IOS_Dev
//
//  Created by Jasmine Emanouel on 4/5/21.
//

import Foundation
import Coinpaprika
import UIKit

class AddViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var listPicker: UIPickerView!
    var list:[String] = [String]()
    var chosenCoin:String!
    var amount:String!
    var newThing:Int! //stores the values added in add vc for view vc
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    var userCoins: [[String]] = [];
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 22);
        
        self.listPicker.delegate = self
        self.listPicker.dataSource = self
        
        Coinpaprika.API.coins().perform { (response) in
            switch response {
            case .success(let coins):
                print(coins.count)
                for c in coins {
                    self.list.append(c.name)
                }
                self.listPicker.reloadAllComponents()
                break
            case .failure(let error):
                print(error)
                break
            }
        }
//        listPicker.selectedRow(inComponent: 0)
        amountTextField.addTarget(self, action: #selector(amountDidChanged(_:)), for: .editingChanged)
        submitButton.layer.cornerRadius = 5
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return list.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return list[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(list[row])
        self.chosenCoin = list[row]
    }
    
    @IBAction func amountDidChanged(_ sender: UITextField) {
        self.amount = sender.text
    }
    
    @IBAction func buttonDidPress(sender: UIButton) {
        self.view.endEditing(true)
        if self.chosenCoin != nil && self.amount != nil {
            let current = UserDefaults.standard.value(forKey: self.chosenCoin)
            var value = Int(self.amount)!
            if current != nil {
                if let curr = current as? Int {
                    value += curr
                } else if let curr = current as? Double {
                    value += Int(curr)
                }
                //
                self.newThing = value //added for view vc
                //
            }
            //
            UserDefaults.standard.set(newThing, forKey: "addedAmount") //added for view vc
            UserDefaults.standard.set(self.chosenCoin, forKey: "addedCoin") //added for view vc
            //
            UserDefaults.standard.setValue(value, forKey: self.chosenCoin)
            var added = UserDefaults.standard.value(forKey: "addedCrypto") as? [String] ?? [String]()
            print(added)
            if !added.contains(self.chosenCoin) {
                added.append(self.chosenCoin)
            }
            print(added)
            amountTextField.text = ""
            let alert = UIAlertController(title: "Success", message: "You have added \(self.chosenCoin!)", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
}


