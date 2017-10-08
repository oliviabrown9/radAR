//
//  ViewController.swift
//  radAR
//
//  Created by Olivia Brown on 10/6/17.
//  Copyright © 2017 Olivia Brown. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreLocation
import SceneKit
import ModelIO
import SceneKit.ModelIO
import Starscream

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
<<<<<<< HEAD
=======
    
   
>>>>>>> origin/master
    var urlPath = "http://192.241.200.251/arobject/"
    
    var param = ["lat": "37.8710439", "long": "-122.2507724"]
    
    fileprivate let locationManager = CLLocationManager()
    
    // Fake date rn because we don't have data
    var mostRecentUserLocation: CLLocation? {
        didSet {
                updateBearPosition()
            print("LOADED USER LOCATION")
        }
    }

    // Put API call here
    // Parse JSON to targetArray?
    var targetNodes = [String: SCNNode]()
    
    lazy var bearObject: MDLObject = {
        let bearObjectURL = Bundle.main.url(forResource: "bear", withExtension: "obj")!
        return MDLAsset(url: bearObjectURL).object(at: 0)
    }()
    
    var targetArray: [Target] = [] {
        didSet {
            
            updateBearPosition()
        }
    }
    
    var socket = WebSocket(url: URL(string: "ws://79406c46.ngrok.io/connect")!)
    
    
    func updateBearPosition() {
        guard let userLocation = mostRecentUserLocation else {
            print("yo this doesn't work")
            return
        }
        
        for target in targetArray {
            //update existing node if it exists
            
            let dist = target.location.distance(from: mostRecentUserLocation!)
            print("Distance to bear: \(dist)")
            if let existingNode = targetNodes[target.id] {
                let scale_matrix = SCNMatrix4MakeScale(0.05, 0.05, 0.05)
                existingNode.transform = scale_matrix
            }
                // otherwise, make a new node
            else {
                if !SharingManager.sharedInstance.collection.contains(target.id) {
                    let newNode = makeBearNode()
                    targetNodes[target.id] = newNode
                
                    newNode.position = target.sceneKitCoordinate(relativeTo: userLocation)
                
                    sceneView.scene.rootNode.addChildNode(newNode)
                }
            }
        }
    }
    
    func scaleTarget(recentUserLocation: CLLocation, target: Target) {
        let dist = recentUserLocation.distance(from: target.location)
    }

    func processJson(json: Any) -> [Target]? {
        guard let targetData = json as? [[String: Any]] else {
            return nil
        }
        return targetData.flatMap(Target.init)
    }

    func makeBearNode() -> SCNNode {
        let node = SCNNode(mdlObject: bearObject)
        return node
    }
    
    
    
    func setupTap() {
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        tapRecognizer.addTarget(self, action: #selector(handleTap(_:)))
        sceneView.gestureRecognizers = [tapRecognizer]
    }
    
    var post: Bool = false
    var numberOfTaps: Int = 0
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        numberOfTaps -= 1
        let location = sender.location(in: sceneView)
        
        let hitResults = sceneView.hitTest(location, options: nil)
        if hitResults.count == 0 {
            post = true
            let urlString = "http://192.241.200.251/arobject/"
            
            let locationArray = [locationManager.location!.coordinate.latitude, locationManager.location!.coordinate.longitude]

            param = ["description": "",
                     "location": "POINT(\(locationArray[0]) \(locationArray[1]))",
                     "owner": "",
                     "asset": "bear.obj"]
                
            let bodyString = buildQueryString(fromDictionary:param)
            
            let url = URL(string: urlString)!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = bodyString.data(using: .utf8)
            
            constructTask(request: request)
            
            let temporaryTarget: Target = Target(id: "\(numberOfTaps)", lat: locationArray[0], long: locationArray[1])
            targetArray.append(temporaryTarget)
<<<<<<< HEAD
=======
            
            /* Sends notification view websocket */
            print("Here is the body string: \(bodyString)")
            socket.write(string: bodyString)

>>>>>>> origin/master
            updateBearPosition()
        }
        else {
            guard let collectedNode = hitResults.first?.node,
                let myNode = targetNodes.allKeys(forValue: collectedNode).first,
                let myTarget = targetArray.first(where: { $0.id == myNode}),
                let myIdentifier: String? = myTarget.id else {
                return
            }
            addCollected(collectedTarget: myIdentifier!)
        }
        post = false
    }
    
    func addCollected(collectedTarget: String) {
        if !SharingManager.sharedInstance.collection.contains(collectedTarget) {
            SharingManager.sharedInstance.collection.append(collectedTarget)
            print(SharingManager.sharedInstance.collection)
        }
    }
    
    func constructTask(request: URLRequest) {
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if !self.post {
                if let data = data {
                    let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    if let testTarget: [Target]? = self.processJson(json: json) {
                        if testTarget == nil {}
                        else {
                            self.targetArray = testTarget!
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        let scene = SCNScene()
        sceneView.scene = scene

        // Comment next line once app is ready - good to check performance
        sceneView.showsStatistics = true
        print(targetArray)
        
        socket.onConnect = {
            print("websocket is connected")
        }
        //websocketDidDisconnect
        socket.onDisconnect = { (error: Error?) in
            print("websocket is disconnected: \(error?.localizedDescription)")
        }
        //websocketDidReceiveMessage
        socket.onText = { (text: String) in
            print("got some text: \(text)")
        }
        //websocketDidReceiveData
        socket.onData = { (data: Data) in
            print("got some data: \(data.count)")
        }
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

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setUpLocationManager()
        setupTap()

        urlPath += buildQueryString(fromDictionary:param)
        let url = URL(string: urlPath)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        sceneView.session.run(configuration)
        
        constructTask(request: request)
        }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }
    
    var addAllowed: Bool = false
    // MARK: add target button
    @IBAction func addTargetButtonPressed(_ sender: UIBarButtonItem) {
        
        if addAllowed == false {
            addAllowed = true
        }
    }
    
    // allow tap to add?
    // tap gesture recognizer
    
//    var didAdd: Bool = false
//    func handleTap() {
//        if addAllowed && !didAdd {
//
//
//        }
//        else if didAdd {
//            didAdd = false
//            addAllowed = false
//        }
//        else {
//            // nothing?
//        }
//    }

    // MARK: - ARSCNViewDelegate
    
    // Override to create and configure nodes for anchors added to the view's session.

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    }


    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
}

// MARK: - CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    
    func setUpLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        mostRecentUserLocation = locationManager.location
    }
    

    // Updates location variable every time location changes
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        mostRecentUserLocation = locations[0] as CLLocation
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("\(error)")
    }
}

// MARK: - MDLMaterial
extension MDLMaterial {
    func setTextureProperties(textures: [MDLMaterialSemantic:String]) -> Void {
        for (key,value) in textures {
            guard let url = Bundle.main.url(forResource: value, withExtension: "") else {
                fatalError("Failed to find URL for resource \(value).")
            }
            let property = MDLMaterialProperty(name:value, semantic: key, url: url)
            self.setProperty(property)
        }
    }
}

// MARK: - Dictionary Extension
extension Dictionary where Value: Equatable {
    func allKeys(forValue val: Value) -> [Key] {
        return self.filter { (keyvalue) in keyvalue.value == val }.map { $0.0 }
    }
}
