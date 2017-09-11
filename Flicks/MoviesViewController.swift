//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Syed Hakeem Abbas on 9/10/17.
//  Copyright © 2017 codepath. All rights reserved.
//

import UIKit

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
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath)
        cell.textLabel?.text = "row \(indexPath.row)"
        //print("row \(indexPath.row)")
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        mSearchQuery = searchText
        initTableView()
    }
    
    func initTableView(){
        fetchData(searchText: mSearchQuery, handler: {(data, response, error) in
            self.tableView.reloadData()
            self.mIsSearchInProgress = false;
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
        
        let url = URL(string: "\(Constants.BASE_URL)search?q=\(searchText)api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")
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
