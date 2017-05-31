//
//  ViewController.swift
//  BleSetup
//
//  Created by Taras Zaporozhets on 5/29/17.
//  Copyright © 2017 Taras Zaporozhets. All rights reserved.
//

import UIKit
import CoreBluetooth

struct WifiAccessPointInfo {
    let ssid: String
    let encryption: String
    let rssi: Int
}

class NetworksView: UIViewController {

    @IBOutlet var tableView: UITableView!
    var refreshControl: UIRefreshControl!

    var wifiNetworksList = [WifiAccessPointInfo]()
    
    var testCounter :Int = 1
    
    var ble: BleController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        readWifiNetworksList()
        
        // Configure Refresh Control
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(NetworksView.refreshWifiNetworksInfo(sender:)), for: .valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController

        ble = BleController();
        ble.initialize();
    }

    deinit {
        ble.disconnect()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func refreshWifiNetworksInfo(sender:AnyObject) {
        readWifiNetworksList()
        refreshControl.endRefreshing()
        tableView.reloadData()
    }
    
    func readWifiNetworksList() {
    
        wifiNetworksList.removeAll()
        for index in 1...testCounter {
            wifiNetworksList.append(contentsOf: [.init(ssid: "ssid" + String(index), encryption: "none", rssi: index)])
        }
        
        testCounter = testCounter + 1
    }

}

extension NetworksView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wifiNetworksList.count + 1 // Always have Other item
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue Reusable Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: NetworkTableViewCell.ReuseIdentifier, for: indexPath) as! NetworkTableViewCell
        
        if (indexPath.row != wifiNetworksList.count) {
            // Fetch Network
            let wifiAccessPoint = wifiNetworksList[indexPath.row]
        
            // Configure Cell
            cell.ssidLabel.text = wifiAccessPoint.ssid
            cell.encryptionLabel.text = wifiAccessPoint.encryption
            cell.rssiLabel.text = String(wifiAccessPoint.rssi)
        } else {
            // Other Item
            cell.ssidLabel.text = "Other"
            cell.encryptionLabel.text = ""
            cell.rssiLabel.text = ""
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath[1] != wifiNetworksList.count) {
//            let alertMessage: String = "Message" + String(describing: indexPath[1])
//            
//            let alert = UIAlertController(title: "Alert", message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
//            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
            
            
            let dic = ["2": "B", "1": "A", "3": "C"]
            
            var jsonString: String = ""
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions.prettyPrinted)
                // here "jsonData" is the dictionary encoded in JSON data
                
                //Convert back to string. Usually only do this for debugging
                if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
                    jsonString = JSONString
                    print(jsonString);
                }
            } catch let error as NSError {
                print(error)
            }
            
            
            ble.writeData(dataToSend: jsonString)
        } else {
            let alert = UIAlertController(title: "Alert", message: "Not implemented", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        
        }
        

    }
}

class NetworkTableViewCell: UITableViewCell {
    
    static let ReuseIdentifier = "NetworkTableViewCell"
    
    @IBOutlet var ssidLabel: UILabel!
    @IBOutlet var encryptionLabel: UILabel!
    @IBOutlet var rssiLabel: UILabel!
    
}
