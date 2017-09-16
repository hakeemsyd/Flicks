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
    UISearchBarDelegate, UICollectionViewDataSource,
    UICollectionViewDelegate{

    @IBOutlet weak var viewConfig: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchView: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyTableMessage: UILabel!
    
    var mMovies : [NSDictionary] = []
    var mSearchQuery = ""
    var mIsSearchInProgress = false
    var mSearchTask: URLSessionDataTask!
    var endPoint = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        let viewMode = UserDefaults.standard.integer(forKey: Utility.KEY_DEFAULT_VIEW_MODE)
        viewConfig.selectedSegmentIndex = viewMode
        if viewMode == 0 {
            tableView.isHidden = false
            collectionView.isHidden = true
        } else if viewMode == 1 {
            tableView.isHidden = true
            collectionView.isHidden = false
        }
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.searchView.delegate = self
        
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
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
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let cell  = tableView.cellForRow(at: indexPath){
            cell.contentView.backgroundColor = UIColor.gray
        }
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
            self.collectionView.reloadData()
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
            self.collectionView.reloadData()
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
            url = URL(string: "\(Utility.BASE_URL)\(endPoint)?\(Utility.API_KEY)")
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
        searchView.endEditing(true)
        let destinationViewController = segue.destination as! MovieDetailsViewController
        if viewConfig.selectedSegmentIndex == 0 {
            let indexPath = tableView.indexPath(for: sender as! UITableViewCell)!
            destinationViewController.mMovie = mMovies[indexPath.row] as! [String : Any]
        } else if viewConfig.selectedSegmentIndex == 1 {
            let indexPath = collectionView.indexPath(for: sender as! UICollectionViewCell)!
            destinationViewController.mMovie = mMovies[indexPath.row] as! [String : Any]
        }
    }
 
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return mMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCollectionViewCell
        
        let movie = mMovies[indexPath.row]
        let title = movie["title"] as? String
        
        cell.movieTitle.text = title
        if let path = movie["poster_path"] {
            print("collectionView: path: \(path)")
            Utility.loadPhoto(withUrl: "\(Utility.BASE_POSTER_URL)w185\(path)" , into: cell.posterView)
        }
        return cell
    }

    @IBAction func onViewConfigChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex
        {
        case 0:
            tableView.isHidden = false
            collectionView.isHidden = true
            break
        case 1:
            tableView.isHidden = true
            collectionView.isHidden = false
            break
        default:
            tableView.isHidden = false
            collectionView.isHidden = true
            break
        }
    }
}
