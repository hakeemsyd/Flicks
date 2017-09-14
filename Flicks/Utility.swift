//
//  Constants.swift
//  Flicks
//
//  Created by Syed Hakeem Abbas on 9/11/17.
//  Copyright © 2017 codepath. All rights reserved.
//

import UIKit
import Foundation

struct Utility {
    static let BASE_URL_NOW_PLAYING = "https://api.themoviedb.org/3/movie/now_playing"
    static let BASE_POSTER_URL = "https://image.tmdb.org/t/p/"
    static let BASE_POSTER_URL_W185 =  "https://image.tmdb.org/t/p/w185"
    static let BASE_POSTER_URL_W500 =  "https://image.tmdb.org/t/p/w500"
    static let BASE_POSTER_URL_ORIGINAL =  "https://image.tmdb.org/t/p/original"
    static let API_KEY = "api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"
    static let BASE_URL_SEARCH = "https://api.themoviedb.org/3/search/movie"
    static let KEY_DEFAULT_VIEW_MODE = "default_view_mode";
    
    static func loadPhoto(withUrl url: String, into view: UIImageView){
        if let u = URL(string: url) {
            let imageRequest = URLRequest(url: u)
            view.setImageWith(
                imageRequest,
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    
                    // imageResponse will be nil if the image is cached
                    if imageResponse != nil {
                        print("Image was NOT cached, fade in image")
                        view.alpha = 0.0
                        view.image = image
                        UIImageView.animate(withDuration: 0.3,animations: { () -> Void in
                            view.alpha = 1.0
                        })
                    } else {
                        print("Image was cached so just update the image")
                        view.image = image
                    }
            },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    // do something for the failure condition
            })
        }
    }
}
