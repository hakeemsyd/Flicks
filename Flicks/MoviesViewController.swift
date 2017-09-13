//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Syed Hakeem Abbas on 9/10/17.
//  Copyright © 2017 codepath. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,
    UISearchBarDelegate {

    @IBOutlet weak var searchView: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyTableMessage: UILabel!
    
    var mMovies : [NSDictionary] = []
    var mSearchQuery = ""
    var mIsSearchInProgress = false
    var mSearchTask: URLSessionDataTask!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.searchView.delegate = self
        
        // pull to referesh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        
        initTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        print("Movies Count: \(mMovies.count)")
        //let count = mMovies.count
        //emptyTableMessage.isHidden = count == 0 ? false : true
        return mMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieTableViewCell
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.red
        cell.selectedBackgroundView = backgroundView
        
        let movie = mMovies[indexPath.row]
        let title = movie["title"] as? String
        let synopsis = movie["overview"] as? String
        
    
        if let path = movie["poster_path"] {
            let p = "\(Utility.BASE_POSTER_URL)w185\(path)"
            Utility.loadPhoto(withUrl: "\(Utility.BASE_POSTER_URL)w185\(path)", into: cell.posterView)
            print(p)
        }
    
        cell.titleLabel.text = title;
        cell.synopsisLabel.text = synopsis;
        //print("row \(indexPath.row)")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated:true)
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
        print("Started init");
        if (mIsSearchInProgress) {
            print("Cancelling task \(mSearchTask.state)")
            mSearchTask?.cancel()
            mIsSearchInProgress = false;
            MBProgressHUD.hide(for: self.view, animated: true)
        }
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        fetchData(searchText: mSearchQuery, handler: {(data, response, error) in
            self.setErrorLabel(error);
            self.mIsSearchInProgress = false;
            self.mMovies = self.parseMovies(data: data)
            self.tableView.reloadData()
            MBProgressHUD.hide(for: self.view, animated: true)
            print("Finished init")
        });
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        print("Started pull referesh")
        if (mIsSearchInProgress) {
            print("Cancelling task \(mSearchTask.state)")
            mSearchTask?.cancel()
            mIsSearchInProgress = false;
            refreshControl.endRefreshing()
            MBProgressHUD.hide(for: self.view, animated: true)
        }
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        fetchData(searchText: mSearchQuery, handler: {(data, response, error) in
            self.setErrorLabel(error);
            self.mIsSearchInProgress = false;
            self.mMovies = self.parseMovies(data: data)
            self.tableView.reloadData()
            refreshControl.endRefreshing()
            MBProgressHUD.hide(for: self.view, animated: true)
            print("Finished pull refresh")
        });
    }
    
    func setErrorLabel(_ error: Error?){
        if error != nil {
            showErrorLabel(with: "No network!", isHidden: false)
        }
        else {
            showErrorLabel(with: "", isHidden: true)
        }
    }
    
    func showErrorLabel(with message: String?, isHidden hidden: Bool){
        emptyTableMessage.isHidden = hidden
        emptyTableMessage.text = message
    }
    
    func fetchData(searchText: String, handler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) {
        print("Search = \(searchText)")
        
        var url: URL!
        if (searchText.isEmpty){
            url = URL(string: "\(Utility.BASE_URL_NOW_PLAYING)?\(Utility.API_KEY)")
        } else {
            url = URL(string: "\(Utility.BASE_URL_SEARCH)?\(Utility.API_KEY)&query=\(searchText)")
        }
        
        if (url != nil){
        let request = URLRequest(url: url!)
        
            // Configure session so that completion handler is executed on main UI thread
            let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
            mSearchTask = session.dataTask(
                with: request as URLRequest,
                completionHandler: handler);
        }
        mIsSearchInProgress = true;
        mSearchTask.resume()
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination as! MovieDetailsViewController
        let indexPath = tableView.indexPath(for: sender as! UITableViewCell)!
        destinationViewController.mMovie = mMovies[indexPath.row] as! [String : Any]
    }
 

}
