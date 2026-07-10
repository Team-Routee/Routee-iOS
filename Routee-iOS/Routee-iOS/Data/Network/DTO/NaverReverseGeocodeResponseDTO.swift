//
//  NaverReverseGeocodeResponseDTO.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/8/26.
//

import Foundation

struct NaverReverseGeocodeResponseDTO: Decodable, Sendable {
    let results: [NaverReverseGeocodeResultDTO]
}

struct NaverReverseGeocodeResultDTO: Decodable, Sendable {
    let name: String
    let region: NaverReverseGeocodeRegionDTO
    let land: NaverReverseGeocodeLandDTO?
    
    var formattedAddress: String? {
        let regionNames = [
            region.area1.name,
            region.area2.name,
            region.area3.name,
            region.area4.name
        ].filter { !$0.isEmpty }
        
        guard let land else {
            return regionNames.joined(separator: " ")
        }
        
        let landNumber = [land.number1, land.number2]
            .filter { !$0.isEmpty }
            .joined(separator: "-")
        let roadAddressParts = regionNames + [land.name ?? "", landNumber]
            .filter { !$0.isEmpty }
        
        return roadAddressParts.joined(separator: " ")
    }
}

struct NaverReverseGeocodeRegionDTO: Decodable, Sendable {
    let area1: NaverReverseGeocodeAreaDTO
    let area2: NaverReverseGeocodeAreaDTO
    let area3: NaverReverseGeocodeAreaDTO
    let area4: NaverReverseGeocodeAreaDTO
}

struct NaverReverseGeocodeAreaDTO: Decodable, Sendable {
    let name: String
}

struct NaverReverseGeocodeLandDTO: Decodable, Sendable {
    let name: String?
    let number1: String
    let number2: String
}
