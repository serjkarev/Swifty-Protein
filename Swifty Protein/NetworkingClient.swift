//
//  NetworkingClient.swift
//  Swifty Protein
//
//  Created by MacBook Pro on 9/10/19.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class NetworkingClient {
    
    private let baseUrl: String = "https://rest.rcsb.org/rest/ligands/"
    
    func getLigand(ligandName: String, completion: @escaping (JSON?, Error?) -> Void) {
        Alamofire.request(baseUrl + ligandName, method: .get).validate().responseJSON { (response) in
            if let error = response.error {
                completion(nil, error)
            } else if let value = response.result.value {
                let json = JSON(value)
                completion(json, nil)
            }
        }
    }
}
