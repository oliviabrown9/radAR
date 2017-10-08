//
//  TargetList.swift
//  radAR
//
//  Created by Suvir Copparam on 10/7/17.
//  Copyright © 2017 Olivia Brown. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreLocation
import SceneKit
import ModelIO
import SceneKit.ModelIO

class TargetListTableViewController: UITableViewController {
    // MARK: Properties
    
    var targetArray : [Target] = []
    
    var urlPath = "http://192.241.200.251/arobject/"
    
    var param = ["lat": "37.8710439", "long": "-122.2507724"]
    
    var post: Bool = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//
//        urlPath += buildQueryString(fromDictionary:param)
//        let url = URL(string: urlPath)!
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//
//        let thisArray = constructTask(request: request)
    }
    
    func buildQueryString(fromDictionary parameters: [String:String]) -> String {
        var urlVars:[String] = []
        for (k, value) in parameters {
            if let encodedValue = value.addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed) {
                urlVars.append(k + "=" + encodedValue)
            }
        }
        return urlVars.isEmpty ? "" : "?" + urlVars.joined(separator: "&")
    }
    
    func constructTask(request: URLRequest) -> [Target] {
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if !self.post {
                if let data = data {
                    let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    if let testTarget: [Target]? = self.processJson(json: json) {
                        if testTarget == nil {
                            print("yall are fucked")
                            print(json)
                        } else {
                            self.targetArray = testTarget!
                            print("targetArray fills")
                            print(self.targetArray)
                        }
                    }
                }
            }
        }
        task.resume()
        
        return self.targetArray
    }
    
    func processJson(json: Any) -> [Target]? {
        guard let targetData = json as? [[String: Any]] else {
            return nil
            
        }
        return targetData.flatMap(Target.init)
    }
    
//    private func loadSampleTargets() {
//        let target1 = Target(id: "bear", lat: 30, long: 10)
//        let target2 = Target(id: "thing", lat: 60, long: 20)
//        targetArray += [target1, target2]
//        print(targetArray)
//    }
    
    private func loadTargets() {

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // load the sample data
        loadTargets()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        urlPath += buildQueryString(fromDictionary:param)
        let url = URL(string: urlPath)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let array = constructTask(request: request)
        return array.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "TargetTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TargetTableViewCell else {
                fatalError("The dequeued cell is not an instance of TargetTableViewCell.")
        }
        
        let target = self.targetArray[indexPath.row]
        
        cell.nameLabel.text = target.id
        cell.proximityLabel.text = String(target.lat)   // temporarily latitude

        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
