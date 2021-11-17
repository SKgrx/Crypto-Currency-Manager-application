
//
//  ViewCurrencyViewController.swift
//  IOS_Dev
//
//  Created by Sara Krg on 10/5/21.
//
import Foundation
import UIKit
import Coinpaprika

class ViewCurrencyViewController: UIViewController{

    var boughtCrypto: String = "";
    var boughtCryptoHoldings: Double! = 0.0
    var coinID: String! = "btc-bitcoin"
    var addedValue: Double = 0.0
    var addedCoin: String = "Bitcoin"
    var addedAmount: Int! = 0
    var soldCrypto: String = "";
    var soldCryptoHoldings: Int! = 0
    var coinIDArray:[String]! = []
    var coinsAddedArray: [String] = []
    //add everything to these arrays
    var listArray:[String] = [] //iniatials
    var valueArray:[String] = [] //initials
    var holdingsArray:[String] = [] //initials
    var userCoins: [[String]] = [];
    
    @IBOutlet weak var appLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var viewCurrencyTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22);
        appLabel.font = UIFont.boldSystemFont(ofSize: 17);
        
        let nib = UINib(nibName: "CustomTableViewCell", bundle: nil)
        viewCurrencyTableView.register(nib, forCellReuseIdentifier: "CustomTableViewCell")
        viewCurrencyTableView.dataSource = self
        viewCurrencyTableView.delegate = self
        
     }
    
    func resetDefaults() {
        let defaults = UserDefaults.standard;
        let dictionary = defaults.dictionaryRepresentation();
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key);
        }
    }
       
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.viewCurrencyTableView.rowHeight = 44;
        
        addedAmount = (UserDefaults.standard.value(forKey: "addedAmount") as? Int ?? 0)//info from add vc
        soldCryptoHoldings = Int((UserDefaults.standard.value(forKey: "soldCryptoHoldings") as? Double ?? 0.0))
        boughtCryptoHoldings = (UserDefaults.standard.value(forKey: "boughtCryptoHoldings") as? Double ?? 0.0)
        
        updateTableView();
        
        
        
        if let addedValue = (UserDefaults.standard.value(forKey: "addedCoin") as? String) {
            addedCoin = addedValue;
        } //info from add vc
        if let soldValue = (UserDefaults.standard.value(forKey: "soldCrypto") as? String) {
            soldCrypto = soldValue;
        } //info from trade vc
        if let boughtValue = (UserDefaults.standard.value(forKey: "boughtCrypto") as? String) {
            boughtCrypto = boughtValue;
        } //info from trade vc
        
        
    }
    
    func updateTableView() {
        if let userCoinList = (UserDefaults.standard.value(forKey: "userCoins") as? [[String]]) {
            userCoins = userCoinList;
        }
        
        Coinpaprika.API.coins().perform { (response) in
            switch response {
                case .success(let coins):
                    for c in coins {
                        var coinValue: Double = 0.0
                        if let value = UserDefaults.standard.value(forKey: c.name) as? Double {
                            coinValue = value
                        }
                        
                        self.updateCoins(coinValue: coinValue, coinID: c.id, coinName: c.name);
                        
                        self.addCoins(coinValue: coinValue, coinID: c.id, coinName: c.name);
                        
                    }
                    self.viewCurrencyTableView.reloadData();
                case .failure(let error):
                  print(error)
            }
        }
    }
    
    func addCoins(coinValue: Double, coinID: String, coinName: String) {
        if coinValue > 0 && !self.isAdded(coinName: coinName) {
            Coinpaprika.API.ticker(id: coinID, quotes: [.usd]).perform { (response) in
                switch response {
                case .success(let ticker):
                    let coinUSD = NSDecimalNumber(decimal: ticker[.usd].price).doubleValue;
                    self.userCoins.append([coinName, String(format: "%.2f", coinUSD), String(format: "%.2f", coinUSD * coinValue)]);
                    UserDefaults.standard.setValue(self.userCoins, forKey: "userCoins");
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func updateCoins(coinValue: Double, coinID: String, coinName: String) {
        if coinValue > 0 {
            for index in 0..<self.userCoins.count {
                
                Coinpaprika.API.ticker(id: coinID, quotes: [.usd]).perform { (response) in
                    switch response {
                    case .success(let ticker):
                        let coinUSD = NSDecimalNumber(decimal: ticker[.usd].price).doubleValue;
                        if Double(self.userCoins[index][2]) ?? 0 / coinValue != coinUSD && self.userCoins[index][0] == coinName {
                            
                            self.userCoins[index][2] = String(format: "%.2f", coinValue * coinUSD)
                            self.userCoins[index][1] = String(format: "%.2f", coinUSD)
                            
                            UserDefaults.standard.setValue(self.userCoins, forKey: "userCoins");
                        }
                        self.viewCurrencyTableView.reloadData();
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
    
    func isAdded(coinName: String) -> Bool {
        for coin in userCoins {
            if coinName == coin[0] {
                return true
            }
        }
        return false
    }
}



//tableview functions
    extension ViewCurrencyViewController: UITableViewDelegate {
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            print("this row is tapped")
        }

    }
    
extension ViewCurrencyViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.userCoins.count;
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = viewCurrencyTableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as! CustomTableViewCell
        
        if !userCoins.isEmpty {
            cell.coinNameLabel.text = userCoins[indexPath.row][0];
            cell.valueLabel.text = "$\(userCoins[indexPath.row][1])";
            cell.holdingsLabel.text = "$\(userCoins[indexPath.row][2])";
        }
            
    
                return cell
    }
}
    

    




