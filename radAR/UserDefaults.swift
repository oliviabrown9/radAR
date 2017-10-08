//
//  UserDefaults.swift
//  radAR
//
//  Created by Fiona Carty on 10/6/17.
//  Copyright © 2017 Olivia Brown. All rights reserved.
//

import Foundation
import UIKit

class UserDefault {
    
    var standard: UserDefaults = UserDefaults.standard
    
   
    
    var id: Int = 0 {
        didSet {
           standard.set(id, forKey: "Id")
        }
    }
    
    var asset: String = "" {
        didSet{
            standard.set(asset, forKey: "Asset")
        }
    }

    private init () {

        let storedId = standard.integer(forKey: "Id")
        let storedAsset = standard.string(forKey: "Asset")
        
        
        id = storedId
        asset = storedAsset!
    }
}
