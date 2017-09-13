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

    @IBOutlet weak var overViewLabel: UILabel!
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var votinAverageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var movieNameLabel: UILabel!
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
        
        movieNameLabel.text = mMovie["title"] as? String
        dateLabel.text = mMovie["release_date"] as? String
        let avg = mMovie["vote_average"] as? Float
        votinAverageLabel.text = "\(avg!) %"
        lengthLabel.text = "2 hours 36 minutes"
        overViewLabel.text = mMovie["overview"] as? String
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
