//
//  UserDefaults.swift
//  radAR
//
//  Created by Olivia Brown on 10/6/17.
//  Copyright © 2017 Olivia Brown. All rights reserved.
//

import Foundation
import UIKit

class SharingManager {
    
    var userDefaults: UserDefaults = UserDefaults.standard
    
    var collection: [String] = [] {
        didSet {
            userDefaults.set(collection, forKey: "Collection")
        }
    }
    
    static let sharedInstance = SharingManager()

    private init () {

        let storedCollection = userDefaults.array(forKey: "Collection") as? [String]
        if storedCollection != nil {
            collection = storedCollection!
        }
        else {
            userDefaults.set(collection, forKey: "Collection")
        }
    }
}
