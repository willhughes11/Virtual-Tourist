//
//  FlickrResponse.swift
//  Virtual Tourist
//
//  Created by William K Hughes on 11/5/20.
//

import Foundation

struct FlickrResponse: Codable {
    let photos: FlickrPhotosData?
    let stat: String
}

struct  FlickrPhotosData: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [FlickrPhotoData]
}

struct FlickrPhotoData: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
}
