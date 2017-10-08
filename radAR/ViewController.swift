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

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    
    var urlPath = "http://192.241.200.251/arobject/"
    
    var param = ["lat": "37.8710439", "long": "-122.2507724", "alt": "10"]
    
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
    
    func updateBearPosition() {
        guard let userLocation = mostRecentUserLocation else {
            print("yo this doesn't work")
            return
        }
        
        for target in targetArray {
            //update existing node if it exists
            if let existingNode = targetNodes[target.id] {
                print("node already exists")
                let move = SCNAction.move (
                    to: target.sceneKitCoordinate(relativeTo: userLocation),
                    duration: TimeInterval(2))
                
                let scale = SCNAction.scale(by: 0.5, duration: TimeInterval(2))
                
                print("\(target.sceneKitCoordinate(relativeTo: userLocation))")
                //existingNode.runAction(move)
                existingNode.runAction(scale)

            }
                // otherwise, make a new node
            else {
                let newNode = makeBearNode()
                targetNodes[target.id] = newNode
                
                newNode.position = target.sceneKitCoordinate(relativeTo: userLocation)
                sceneView.scene.rootNode.addChildNode(newNode)

                
                let scale = SCNAction.scale(by: 0.5, duration: TimeInterval(2))
//                newNode.runAction(scale)

            }
        }
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
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: sceneView)
        
        let hitResults = sceneView.hitTest(location, options: nil)
        if hitResults.count == 0 {
            let urlString = "http://192.241.200.251/arobject/"
            
            let locationArray = [locationManager.location!.coordinate.latitude, locationManager.location!.coordinate.latitude]

            param = ["description": "This is a description.",
                     "location": "POINT(\(locationArray[0]) \(locationArray[1]))",
                     "owner": "Olivia",
                     "asset": "bear.obj"]
                
            let bodyString = buildQueryString(fromDictionary:param)
            
            let url = URL(string: urlString)!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = bodyString.data(using: .utf8)

            constructTask(request: request)
            updateBearPosition()
        }
    }
    
    func constructTask(request: URLRequest) {
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                print("y'all attention here:")
                print(json)
                
                if let testTarget: [Target]? = self.processJson(json: json) {
                    if testTarget == nil {
                        print("yall are fucked: testTarget is nil")
                        print(json)
                    } else {
                        self.targetArray = testTarget!
                        print("there should be a bear")
                    }
                    print(testTarget)
                }
                print(json)
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
    
    
    func touchesBegan(touches: Set<UITouch>, with event: UIEvent?) {
        guard let sceneView = self.view as? ARSCNView else {
            return
        }
        
        if let currentFrame = sceneView.session.currentFrame {
            
            // Create a transform with a translation of 0.2 meters in front of the camera
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -0.4
            let transform = simd_mul(currentFrame.camera.transform, translation)
            
            
        }
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
    
    var didAdd: Bool = false
    func handleTap() {
        if addAllowed && !didAdd {

                
        }
        else if didAdd {
            didAdd = false
            addAllowed = false
        }
        else {
            // nothing?
        }
    }

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

// MARK: - String Extension
extension String {
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}


