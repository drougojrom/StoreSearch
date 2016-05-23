//
//  ViewController.swift
//  StoreSearch
//
//  Created by Roman Ustiantcev on 26/04/16.
//  Copyright © 2016 Roman Ustiantcev. All rights reserved.
//

import UIKit

func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
    
    return lhs.name.localizedStandardCompare(rhs.name) == .OrderedAscending
    
}

class SearchViewController: UIViewController {
    
    // MARK: - Instance variables
    var searchResults = [SearchResult]()
    var hasSearched =  false
    var isLoading = false
    var dataTask: NSURLSessionDataTask?
    
    //MARK: - @IBOutlet

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        
        print("Segment changed: \(sender.selectedSegmentIndex)")
        performSearch()
        
    }
    
    
    
    struct TableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }
    
    func urlWithSearchText(searchText: String, category: Int) -> NSURL {
        
        let entityName: String
        switch category {
        case 1: entityName = "musicTrack"
        case 2: entityName = "software"
        case 3: entityName = "ebook"
        default: entityName = ""
        }
        
        let escapedSearchText = searchText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200&entity=%@", escapedSearchText, entityName)
        let url = NSURL(string: urlString)
        
        return url!
    }
    
    func parseJSON(data: NSData) -> [String: AnyObject]? {
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject]
        } catch {
            print("JSON Error: \(error)")
            return nil
        }
    }
    
    func showNetworkError(){
        let alert = UIAlertController(title: "Whoops...", message: "There is an error reading from iTunes Store. Please try again", preferredStyle: .Alert)
        
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        
        alert.addAction(action)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func parseTrack(dictionary: [String: AnyObject]) -> SearchResult {
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["trackPrice"] as? Double {
            searchResult.price = price
        }
        
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        
        return searchResult
        
    }
    
    func parseDictionary(dictionary: [String: AnyObject]) -> [SearchResult] {
        // 1 - if has such an array
        guard let array = dictionary["results"] as? [AnyObject] else { print("Expeted results array"); return [] }
        
        var searchResults = [SearchResult]()
        // 2 - using for-in loop to look it through
        for resultsDict in array {
            // 3 - each of the elements in another dict, check them also
            if let resultsDict = resultsDict as? [String: AnyObject] {
                // 4 - use optional to unwrap them
                var searchResult: SearchResult?
                if let wrapperType = resultsDict["wrapperType"] as? String {
                    switch wrapperType {
                    case "track":
                        searchResult = parseTrack(resultsDict)
                    case "audiobook":
                        searchResult = parseAudioBook(resultsDict)
                    case "software":
                        searchResult = parseSoftware(resultsDict)
                    default:
                        break
                    }
                } else if let kind = resultsDict["kind"] as? String where kind == "ebook" {
                    searchResult = parseEBook(resultsDict)
                }
                if let result = searchResult {
                    searchResults.append(result)
                }
            }
        }
        
        return searchResults
    }
    
    func parseAudioBook(dictionary: [String:AnyObject]) -> SearchResult {
        
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["collectionName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["collectionViewUrl"] as! String
        searchResult.kind = "audiobook"
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["collectionPrice"] as? Double {
            searchResult.price = price
        }
        
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        
        return searchResult
    }
    
    func parseSoftware(dictionary: [String:AnyObject]) -> SearchResult {
        
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["price"] as? Double {
            searchResult.price = price
        }
        
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        
        return searchResult
        
    }
    
    func parseEBook(dictionary: [String:AnyObject]) -> SearchResult {
        
        let searchResult = SearchResult()
        
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["price"] as? Double {
            searchResult.price = price
        }
        
        if let genres: AnyObject = dictionary["genres"] {
            searchResult.genre = (genres as! [String]).joinWithSeparator(", ")
        }
        
        return searchResult
        
    }
    
    func kindForDisplay(kind: String) -> String {
        
        switch kind {
        case "album": return "Album"
        case "audiobook": return "Audio Book"
        case "book": return "Book"
        case "ebook": return "E-Book"
        case "feature-movie": return "Movie"
        case "music-video": return "Music Video"
        case "podcast": return "Podcast"
        case "software": return "App"
        case "song": return "Song"
        case "tv-episode": return "TV Episode"
        
        default:
            return kind
        }
        
    }
    
    
    // MARK: - override
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.becomeFirstResponder()
        
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
        
        tableView.rowHeight = 80
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

// ***********
//
//  EXTENSIONS
//
// ***********

extension SearchViewController :UISearchBarDelegate {
    func performSearch(searchBar: UISearchBar) {
        
        performSearch()
        
    }
    
    func performSearch(){
        
        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()
            
            dataTask?.cancel()
            
            isLoading = true
            tableView.reloadData()
            
            hasSearched = true
            searchResults = [SearchResult]()
            
            // 1- create NSURL object
            let url = urlWithSearchText(searchBar.text!, category: segmentControl.selectedSegmentIndex)
            
            // 2- obtain session object
            let session = NSURLSession.sharedSession()
            // 3- create dataTask for sending HTTPS Get
            dataTask = session.dataTaskWithURL(url, completionHandler: {
                
                data, response, error in
                
                if let error = error where error.code == -999 {
                    print("Failure \(error)")
                    return
                } else if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode == 200 {
                    if let data = data, dictionary = self.parseJSON(data) {
                        self.searchResults = self.parseDictionary(dictionary)
                        self.searchResults.sortInPlace(<)
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            self.isLoading = false
                            self.tableView.reloadData()
                        })
                        return
                    }
                } else {
                    print("Failure \(response)")
                    dispatch_async(dispatch_get_main_queue(), {
                        self.hasSearched = false
                        self.isLoading = false
                        self.tableView.reloadData()
                        self.showNetworkError()
                    })
                }
            })
            // 4- start dataTask
            dataTask?.resume()
        }
        
    }


    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}

extension SearchViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isLoading {
            return 1
        } else if !hasSearched {
            return 0
        } else if searchResults.count == 0 {
            return 1
        } else {
            return searchResults.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell
        
        
        
        if isLoading {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell)
            let spinner = cell!.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell!
        
        } else if searchResults.count == 0 {
            return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath)
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell
            
            let searchResult = searchResults[indexPath.row]
            cell.configureForSearchResult(searchResult)
            
            }
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("ShowDetail", sender: indexPath)
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if searchResults.count == 0 || isLoading {
            return nil
        } else {
            return indexPath
        }
    }
    
}

