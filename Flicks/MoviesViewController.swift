//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Syed Hakeem Abbas on 9/10/17.
//  Copyright © 2017 codepath. All rights reserved.
//

import UIKit
import AFNetworking

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,
    UISearchBarDelegate {

    @IBOutlet weak var searchView: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var mMovies : [NSDictionary] = []
    var mSearchQuery = ""
    var mIsSearchInProgress = false
    var mSearchTask: URLSessionDataTask!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.searchView.delegate = self
        
        initTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        print("Movies Count: \(mMovies.count)")
        return mMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieTableViewCell
        
        let movie = mMovies[indexPath.row]
        let title = movie["title"] as? String
        let synopsis = movie["overview"] as? String
        
    
        if let path = movie["poster_path"] {
            let p = "\(Constants.BASE_POSTER_URL)\(path)"
            print(p)
            if let posterUrl = URL(string: p){
                cell.posterView.setImageWith(posterUrl)
            }
        }
    
        cell.titleLabel.text = title;
        cell.synopsisLabel.text = synopsis;
        print("row \(indexPath.row)")
        return cell
    }
    
    func parseMovies(data: Data? ) -> [NSDictionary] {
        if let data = data {
            if let responseDictionary = try! JSONSerialization.jsonObject(
                with: data, options:[]) as? NSDictionary {
                let movies = responseDictionary["results"] as! [NSDictionary]
                return movies;
            }
        }
        return [];
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        mSearchQuery = searchText
        initTableView()
    }
    
    func initTableView(){
        fetchData(searchText: mSearchQuery, handler: {(data, response, error) in
            self.mIsSearchInProgress = false;
            self.mMovies = self.parseMovies(data: data)
            self.tableView.reloadData()
            print("Finished search")
        });
    }
    
    func fetchData(searchText: String, handler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) {
        print("Search = \(searchText)")
        if (mIsSearchInProgress) {
            print("Cancelling task \(mSearchTask.state)")
            mSearchTask?.cancel()
            mIsSearchInProgress = false;
        }
        
        var url: URL!
        if (searchText.isEmpty){
            url = URL(string: "\(Constants.BASE_URL_NOW_PLAYING)?\(Constants.API_KEY)")
        } else {
            url = URL(string: "\(Constants.BASE_URL_SEARCH)?\(Constants.API_KEY)&query=\(searchText)")
        }
        let request = URLRequest(url: url!)
        
        // Configure session so that completion handler is executed on main UI thread
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        mSearchTask = session.dataTask(
            with: request as URLRequest,
            completionHandler: handler);
        
        mIsSearchInProgress = true;
        mSearchTask.resume()
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
