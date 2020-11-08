//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by William K Hughes on 11/5/20.
//

import Foundation
import UIKit

class FlickrClient {
    
    //MARK: - API Keys and Stuff
    
    struct Auth {
        static let key: String = "4ea541a27f4e15a10ab6933083952dd2"
        static let secret: String = "6239b28305017601"
    }
    
    // MARK: - Endpoints
    
    enum Endpoints {
        case photosSearch([Float])
        case loadImage([String:String], Int)
        
        var stringValue: String{
            switch self{
            case .photosSearch(let coordinates): return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(Auth.key)&lat=\(coordinates[0])&lon=\(coordinates[1])&per_page=20&page=\(Int.random(in: 1..<10))&format=json"
            case .loadImage(let data, let farmID): return "https://farm\(farmID).staticflickr.com/\(data["Server"]!)/\(data["ID"]!)_\(data["Secret"]!).jpg"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    // MARK: - Image Request
    
    static func getPhotosSearch(latitude: Double, longitude: Double, completion: @escaping (FlickrResponse?, Error?) -> Void){
        let request = URLRequest(url: Endpoints.photosSearch([Float(latitude),Float(longitude)]).url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard var data = data else{
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            data = data.subdata(in: (14..<(data.count-1)))
            let decoder = JSONDecoder()
            do{
                let flickrPhotosSearchResponse = try decoder.decode(FlickrResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(flickrPhotosSearchResponse,nil)
                }
            }catch{
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    // MARK: - Image Download
    
    static func loadImage(photoData: FlickrPhotoData, image: Photo, completion: @escaping (Photo, Data?, Error?)->Void){
        let request = URLRequest(url: Endpoints.loadImage(
            ["Server": photoData.server,
             "ID": photoData.id,
             "Secret": photoData.secret],
              photoData.farm).url)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard error == nil, data != nil else{
                completion(image, nil, error)
                return
            }
            completion(image, data, nil)
        }
        task.resume()
    }
}
