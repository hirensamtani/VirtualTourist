//
//  Photo.swift
//  VirtualTourist
//
//  Created by Hiren Samtani on 30/05/18.
//  Copyright © 2018 Hiren Samtani. All rights reserved.
//

import UIKit
import CoreData

extension Photo {
    convenience init(imageURL: URL, image: UIImage? = nil, flickrId: String? = "", title : String? = "" ,context: NSManagedObjectContext) {
        self.init(context: context)
        self.flickrUrl = imageURL.absoluteString
        self.flickrId = flickrId
        self.title = title
        self.data = image != nil ? UIImagePNGRepresentation(image!) : nil
    }
}
