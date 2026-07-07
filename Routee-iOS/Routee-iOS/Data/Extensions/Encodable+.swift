//
//  Encodable+.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/7/26.
//

import Foundation

import Alamofire

extension Encodable {
    func asParameters() -> Parameters? {
        guard
            let data = try? JSONEncoder().encode(self),
            let jsonObject = try? JSONSerialization.jsonObject(with: data),
            let parameters = jsonObject as? Parameters
        else {
            return nil
        }
        
        return parameters
    }
}
