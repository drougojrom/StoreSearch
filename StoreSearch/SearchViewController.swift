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
    
    //MARK: - @IBOutlet

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    struct TableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
    }
    
    func urlWithSearchText(searchText: String) -> NSURL {
        
        let escapedSearchText = searchText.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        let urlString = String(format: "https://itunes.apple.com/search?term=%@", escapedSearchText)
        let url = NSURL(string: urlString)
        
        return url!
    }
    
    func performStoreRequestWithURL(url: NSURL) -> String? {
        
        do {
            return try String(contentsOfURL: url, encoding: NSUTF8StringEncoding)
        } catch {
            print("Download error: \(error)")
            return nil
        }
    }
    
    func parseJSON(jsonString: String) -> [String: AnyObject]? {
        guard let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding) else { return nil }
        
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String:AnyObject]
        } catch {
            print("Error with : \(error)")
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
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {

        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()
            
            hasSearched = true
            searchResults = [SearchResult]()
            
            let url = urlWithSearchText(searchBar.text!)
            print("\(url)")
            
            if let jsonString = performStoreRequestWithURL(url) {
                print("Recieved json string: \(jsonString)")
                if let dictionary = parseJSON(jsonString) {
                    print("Dictionary: \(dictionary)")
                    
                    searchResults = parseDictionary(dictionary)
                    
                    searchResults.sortInPlace(<)
                    tableView.reloadData()
                    return
                }
            }
            
            showNetworkError()
            
        }
        
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}

extension SearchViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !hasSearched {
            return 0
        } else if searchResults.count == 0 {
            return 1
        } else {
            return searchResults.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell
        
        if searchResults.count == 0 {
            return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath)
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell
            
            let searchResult = searchResults[indexPath.row]
            cell.nameLabel.text = searchResult.name
            if searchResult.artistName.isEmpty {
                cell.artistNameLabel.text = "Unknown"
            } else {
                cell.artistNameLabel.text = String(format: "%@ (%@)", searchResult.artistName, kindForDisplay(searchResult.kind))
            }
        }
        
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if searchResults.count == 0 {
            return nil
        } else {
            return indexPath
        }
    }
    
}

