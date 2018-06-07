//
//  FlickrPhoto.swift
//  VirtualTourist
//
//  Created by Hiren Samtani on 03/06/18.
//  Copyright © 2018 Hiren Samtani. All rights reserved.
//

import Foundation

struct FlickrPhoto {
    let id: Int
    let title: String
    let photoUrl: String
    
    init(dictionary: [String:AnyObject]) {
        if let id = dictionary[FlickrClient.JSONResponseKeys.PhotoId] as? String {
            debugPrint("--- ID: \(id)")
            self.id = Int(id)!
        } else {
            self.id = 0
            debugPrint("--- ID: NIL!!!!!")
        }
        if let title = dictionary[FlickrClient.JSONResponseKeys.PhotoTitle] as? String {
            debugPrint("--- Title: \(title)")
            self.title = title
        } else {
            self.title = ""
            debugPrint("--- TITLE NIL!!!")
        }
        
        let farm = dictionary[FlickrClient.JSONResponseKeys.PhotoFarm] as! Int
        let server = dictionary[FlickrClient.JSONResponseKeys.PhotoServerId] as! String
        let secret = dictionary[FlickrClient.JSONResponseKeys.PhotoSecret] as! String
        
        self.photoUrl = "https://farm\(farm).staticflickr.com/\(server)/\(self.id)_\(secret).jpg"
        debugPrint(self.photoUrl)
        //https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}.jpg
    }
    
    static func flickrPhotosFrom(_ results: [String:AnyObject]) -> [FlickrPhoto] {
        var flickrPhotos = [FlickrPhoto]()
        
        if let photosObject = results[FlickrClient.JSONResponseKeys.Photos] as? [String:AnyObject] {
            if let photosArray = photosObject[FlickrClient.JSONResponseKeys.Photo] as? [[String:AnyObject]] {
                for result in photosArray {
                    debugPrint("\(result)")
                    flickrPhotos.append(FlickrPhoto(dictionary: result))
                }
            }
        }
        
        return flickrPhotos
    }
}
