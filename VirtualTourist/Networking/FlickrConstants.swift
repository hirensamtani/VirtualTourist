//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by Hiren Samtani on 02/06/18.
//  Copyright © 2018 Hiren Samtani. All rights reserved.
//

import Foundation

extension FlickrClient {
    // MARK: Constants
    struct Constants {
        static let ApiScheme = "https"
        static let ApiHost = "api.flickr.com"
        static let ApiPath = "/services/rest"
        static let ApiKey = "" //hbs
    }
    // MARK: Methods
    struct Methods {
        // MARK: Search
        static let Search = "flickr.photos.search"
    }
    // MARK: Header Keys
    struct HeaderKeys {
    }
    // MARK: Parameter Keys
    struct ParameterKeys {
        static let ApiKey = "api_key"
        static let Method = "method"
        static let Callback = "nojsoncallback"
        static let Format = "format"
        static let BBox = "bbox"
        static let PerPage = "per_page"
        static let Page = "page"
    }
    struct URLKeys {
        static let Id = "id"
    }
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        static let Photos = "photos"
        static let Photo = "photo"
        static let PhotoId = "id"
        static let PhotoTitle = "title"
        static let PhotoFarm = "farm"
        static let PhotoServerId = "server"
        static let PhotoSecret = "secret"
    }
}
