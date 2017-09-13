//
//  MovieDetailsViewController.swift
//  Flicks
//
//  Created by Syed Hakeem Abbas on 9/12/17.
//  Copyright © 2017 codepath. All rights reserved.
//

import UIKit
import AFNetworking

class MovieDetailsViewController: UIViewController {

    @IBOutlet weak var posterImage: UIImageView!
    var posterPath = ""
    var mMovie: [String: Any] = [String: Any]()
    override func viewDidLoad() {
        super.viewDidLoad()
        if let path = mMovie["poster_path"] {
            let p = "\(Constants.BASE_POSTER_URL_ORIGINAL)\(path)"
            if let posterUrl = URL(string: p){
                print(p)
                posterImage.setImageWith(posterUrl)
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
