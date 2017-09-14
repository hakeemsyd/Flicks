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

    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var detailsContainerView: UIView!
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
            let p = "\(Utility.BASE_POSTER_URL_ORIGINAL)\(path)"
            Utility.loadPhoto(withUrl: p, into: posterImage)
            print(p)
        }
        
        //detailsContainerView.sizeToFit()
        movieNameLabel.text = mMovie["title"] as? String
        self.navigationItem.title = movieNameLabel.text
        
        dateLabel.text = mMovie["release_date"] as? String
        let avg = mMovie["vote_average"] as? Float
        votinAverageLabel.text = "\(avg!) %"
        lengthLabel.text = "2 hours 36 minutes"
        overViewLabel.text = mMovie["overview"] as? String
        //overViewLabel.sizeToFit()
        containerScrollView.contentSize = CGSize(width: detailsContainerView.bounds.width * 2, height: detailsContainerView.bounds.height * 2)
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
