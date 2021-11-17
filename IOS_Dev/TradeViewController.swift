//
//  TradeViewController.swift
//  IOS_Dev
//
//  Created by Jasmine Emanouel on 4/5/21.
//

import Foundation
import UIKit
import Coinpaprika

class TradeViewController: UIViewController, UITextFieldDelegate {
    
    // Define IBOutlets
    @IBOutlet weak var exchangeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var sellCryptoButton: UIButton!
    @IBOutlet weak var sellCryptoLabel: UILabel!
    @IBOutlet weak var sellCryptoTextField: UITextField!
    
    @IBOutlet weak var buyCryptoButton: UIButton!
    @IBOutlet weak var buyCryptoLabel: UILabel!
    @IBOutlet weak var buyCryptoTextField: UITextField!
    
    @IBOutlet weak var swapButton: UIButton!
    @IBOutlet weak var tradeButton: UIButton!
    
    // Define id, symbol and name for initial cryptos
    var sellCryptoID = "btc-bitcoin"
    var sellCryptoSymbol = "BTC"
    var sellCryptoName = "Bitcoin"
    
    var buyCryptoID = "eth-ethereum"
    var buyCryptoSymbol = "ETH"
    var buyCryptoName = "Ethereum"
    
    // Boolean value used for determining what values and labels to change
    var isBuy = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI adjustments
        swapButton.setTitle("\u{2B83}", for: UIControl.State(rawValue: 0));
        swapButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17);
        tradeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15);
        
        // Set delegates
        self.sellCryptoTextField.delegate = self;
        self.buyCryptoTextField.delegate = self;
    }
    
    // View will appear used over view did load due to tab bar
    override func viewWillAppear(_ animated: Bool) {
        
        // UI adjustments
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22);
        self.tabBarController?.tabBar.isHidden = false;
        self.navigationController?.navigationBar.isHidden = true;
        self.sellCryptoTextField.text = "";
        self.buyCryptoTextField.text = "";
        
        // Retrieve the value of the sell crypto from User Defaults to display in the sell crypto label
        var value: Double = 0.0
        if let sellCryptoValue = UserDefaults.standard.value(forKey: self.sellCryptoName) as? Double {
            value = sellCryptoValue;
        }
        
        // Update sell button and label
        if value == 0 || value.truncatingRemainder(dividingBy: 1) == 0 {
            sellCryptoLabel.text = "I have \(String(Int(value))) \(sellCryptoName)"
        } else {
            sellCryptoLabel.text = "I have \(String(format: "%.4f", value)) \(sellCryptoName)"
        }
        sellCryptoButton.setTitle("\(sellCryptoSymbol) \u{25BE}", for: UIControl.State(rawValue: 0));
        
        //Update buy button and label
        buyCryptoButton.setTitle("\(buyCryptoSymbol) \u{25BE}", for: UIControl.State(rawValue: 0));
        buyCryptoLabel.text = "I want \(buyCryptoName)"
        
        // Update exchange rate
        exchange(type: "rate");
    }
    
    // Update buy text field when the sell text field is finished being edited
    @IBAction func onSellEdit(_ sender: Any) {
        exchange(type: "sell");
    }
    
    // Update sell text field when the buy text field is finished being edited
    @IBAction func onBuyEdit(_ sender: Any) {
        exchange(type: "buy");
    }
    
    // Function used to minimise repetitive code
    func exchange(type: String) {
        // Retrieve the value of both cryptos in USD
        var cryptoUSD: Double = 0.0;
        Coinpaprika.API.ticker(id: buyCryptoID, quotes: [.usd]).perform { (response) in
          switch response {
            case .success(let ticker):
                cryptoUSD = NSDecimalNumber(decimal: ticker[.usd].price).doubleValue;
                Coinpaprika.API.ticker(id: self.sellCryptoID, quotes: [.usd]).perform { (response) in
                    switch response {
                    case .success(let ticker):
                        
                        // Based on the type, slightly different maths is performed and different labels are changed
                        switch type {
                        case "sell":
                            let userInput: String = self.sellCryptoTextField.text ?? "";
                            let value: Double = NSDecimalNumber(decimal: ticker[.usd].price).doubleValue / cryptoUSD * (Double(userInput) ?? 1);
                            self.buyCryptoTextField.text = String(format: "%.4f", value);
                        case "buy":
                            let userInput: String = self.buyCryptoTextField.text ?? "";
                            let value: Double = (Double(userInput) ?? 1) * cryptoUSD / NSDecimalNumber(decimal: ticker[.usd].price).doubleValue;
                            self.sellCryptoTextField.text = String(format: "%.4f", value);
                        case "rate":
                            let exchangeValue: Double = NSDecimalNumber(decimal: ticker[.usd].price).doubleValue / cryptoUSD;
                            self.exchangeLabel.text = "Exchange Rate: 1 \(self.sellCryptoSymbol) = \(String(format: "%.6f", exchangeValue)) \(self.buyCryptoSymbol)";
                        default:
                            let error = "Invalid type selected for exchange function"
                            print(error)
                        }
                        
                    case .failure(let error):
                        print(error)
                    }
                }
            case .failure(let error):
                print(error);
          }
        }
    }
    
    // Trades the sell crypto for the equivalent amount of the buy crypto
    @IBAction func onTrade(_ sender: Any) {
        // If the user has entered a value and the exhcnage calcuation has been performed
        if (!self.sellCryptoTextField.text!.isEmpty && !self.buyCryptoTextField.text!.isEmpty) {
            // Get sell coin value from user defaults
            var sellValue: Double = 0.0
            if let sellCryptoValue = UserDefaults.standard.value(forKey: self.sellCryptoName) as? Double {
                sellValue = sellCryptoValue;
            }
            // Get buy coin value from user defaults
            var buyValue: Double = 0.0
            if let buyCryptoValue = UserDefaults.standard.value(forKey: self.buyCryptoName) as? Double {
                buyValue = buyCryptoValue;
            }
            
            // Alert the user if they do not have enough of the sell crypto
            if Double(self.sellCryptoTextField.text ?? "") ?? 0 > sellValue {
                tradeAlert(message: "You do not have enough \(self.sellCryptoName) to trade.", log: "insufficient funds")
            } else if sellValue > 0 {
                // Adjust sell and buy values accordingly and update user defaults
                sellValue -= Double(self.sellCryptoTextField.text ?? "") ?? 0;
                buyValue += Double(self.buyCryptoTextField.text ?? "") ?? 0;
                UserDefaults.standard.setValue(sellValue, forKey: self.sellCryptoName)
                UserDefaults.standard.setValue(buyValue, forKey: self.buyCryptoName)
                
                UserDefaults.standard.set(sellCryptoName, forKey: "soldCrypto")//added for view vc
                UserDefaults.standard.set(buyCryptoName, forKey: "boughtCrypto") //added for view vc
                UserDefaults.standard.set(sellValue, forKey: "soldCryptoHoldings") //added for view vc
                UserDefaults.standard.set(buyValue, forKey: "boughtCryptoHoldings") //added for view vc

                // Alert the user that the trade was successfull
                tradeAlert(message: "Success! You now have \(Double(self.buyCryptoTextField.text ?? "") ?? 0) \(self.buyCryptoName)", log: "success")
                
            }
            // Reload the view
            viewWillAppear(false);
        } else {
            tradeAlert(message: "Please enter the amount you would like to trade.", log: "no value entered")
        }
    }
    
    // Alert function used to minimise repetative code
    func tradeAlert(message: String, log: String) {
        let alert = UIAlertController(title: "Trade alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in NSLog("The \(log) trade alert occured.")}))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Swaps the sell crypto coin with the buy crypto coin
    @IBAction func onSwap(_ sender: Any) {
        var ID: String = "";
        var symbol: String = "";
        var name: String = "";
        
        ID = sellCryptoID;
        sellCryptoID = buyCryptoID;
        buyCryptoID = ID;
        
        symbol = sellCryptoSymbol;
        sellCryptoSymbol = buyCryptoSymbol;
        buyCryptoSymbol = symbol;
        
        name = sellCryptoName;
        sellCryptoName = buyCryptoName;
        buyCryptoName = name;
        
        // Once swapped, the view refreshes and displays the update values
        viewWillAppear(false);
    }
    
    // Send data to the trade select view based on the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tradeSelectVC = segue.destination as! TradeSelectViewController
        if segue.identifier == "sellToTradeSelect" {
            tradeSelectVC.sellCrypto = self.sellCryptoID;
            tradeSelectVC.buyCrypto = self.buyCryptoID;
            tradeSelectVC.isBuy = false;
        } else if segue.identifier == "buyToTradeSelect" {
            tradeSelectVC.sellCrypto = self.sellCryptoID;
            tradeSelectVC.buyCrypto = self.buyCryptoID;
            tradeSelectVC.isBuy = true;
        }
    }
    
    // Used to allow the user to exit the keyboard and stop editing the text fields
    func textFieldShouldReturn(_ sellCryptoTextField: UITextField) -> Bool {
        sellCryptoTextField.resignFirstResponder()
        return true;
    }
}
