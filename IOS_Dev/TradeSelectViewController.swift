//
//  TradeSelectViewController.swift
//  IOS_Dev
//
//  Created by Kieran Taverner on 15/5/21.
//

import UIKit
import Coinpaprika

class TradeSelectViewController: UIViewController {
    
    // Define IBOutlets
    @IBOutlet weak var tradeSelectTableView: UITableView!
    @IBOutlet weak var tradeLabel: UILabel!
    
    var cryptoList: [[String]] = [];
    // Store crypto symbols from trade view
    var sellCrypto: String = "";
    var buyCrypto: String = "";
    var isBuy = true;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Display nav bar and hide tab bar
        self.tabBarController?.tabBar.isHidden = true;
        self.navigationController?.navigationBar.isHidden = false;
        
        // Get a list of coins from the Coinpaprika API
        getCryptoList();
        
        // Changle trade label based on the crypto selected from trade view
        if isBuy == true {
            tradeLabel.text = "Buy";
        } else {
            tradeLabel.text = "Sell";
        }
        
        // Define nib and register table view
        let nib = UINib(nibName: "tradeTableViewCell", bundle: nil)
        tradeSelectTableView.register(nib, forCellReuseIdentifier: "tradeTableViewCell")
        self.tradeSelectTableView.rowHeight = 44;
        
        // Set delegates
        tradeSelectTableView.delegate = self;
        tradeSelectTableView.dataSource = self;
    }
    
    // Gets all of the coins from the Coinpaprika API and stores them in the 'cryptoList' 2D array
    func getCryptoList() {
        Coinpaprika.API.coins().perform { (response) in
            switch response {
            case .success(let coins):
                for c in coins {
                    if c.id != self.sellCrypto && c.id != self.buyCrypto {
                        self.cryptoList.append([c.id, c.symbol, c.name])
                    }
                }
                // Reload table data to display coins
                self.tradeSelectTableView.reloadData();
                break
            case .failure(let error):
                print(error)
                break
            }
        }
    }
        
}

// Table view delegate extension
extension TradeSelectViewController: UITableViewDelegate {
    
    // Handles the user selecting a row in the table view
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Define trade view controller and the cell selected
        let tradeVC = self.navigationController?.viewControllers[0] as! TradeViewController;
        let cell = tableView.cellForRow(at: indexPath) as! tradeTableViewCell;
        
        // Set isBuy in the trade view
        tradeVC.isBuy = self.isBuy;
        // Set the variables associated with the selected coin in the trade view based on isBuy
        if isBuy == false {
            tradeVC.sellCryptoSymbol = cell.symbolLabel.text ?? ""
            tradeVC.sellCryptoName = cell.nameLabel.text ?? ""
            if let index: Int = cryptoList.firstIndex(where: {$0[1] == cell.symbolLabel.text}) {
                tradeVC.sellCryptoID = cryptoList[index][0];
            }
        } else {
            tradeVC.buyCryptoSymbol = cell.symbolLabel.text ?? ""
            tradeVC.buyCryptoName = cell.nameLabel.text ?? ""
            if let index: Int = cryptoList.firstIndex(where: {$0[1] == cell.symbolLabel.text}) {
                tradeVC.buyCryptoID = cryptoList[index][0];
            }
        }
        
        // Return to trade view (previous view)
        self.navigationController?.popToRootViewController(animated: true);
    }
}

// Table view data source extension
extension TradeSelectViewController: UITableViewDataSource {
    // Set table view rows to number of coins
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cryptoList.count;
    }
    
    // Set the values for the symbol and name of each coin and display in the custom cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tradeSelectTableView.dequeueReusableCell(withIdentifier: "tradeTableViewCell", for: indexPath) as! tradeTableViewCell;
        cell.symbolLabel.text = cryptoList[indexPath.row][1];
        cell.nameLabel.text = cryptoList[indexPath.row][2];
        return cell;
    }
}
