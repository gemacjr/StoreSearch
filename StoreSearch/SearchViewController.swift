//
//  SearchViewController.swift
//  StoreSearch
//
//  Created by Ed McCormic on 4/4/17.
//  Copyright © 2017 Swiftbeard. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchResults: [SearchResult] = []
    var hasSearched = false
    var isLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()
        //tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = 80
        
        searchBar.becomeFirstResponder()
        
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    struct TableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }
    
    func iTunesURL(searchText: String) -> URL {
        let escapedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = String(format: "https://itunes.apple.com/search?term=%@", escapedSearchText)
        
        let url = URL(string: urlString)
        return url!
    }
    
    func performStoreRequest(with url: URL) -> String? {
        do {
            return try String(contentsOf: url, encoding: .utf8)
        }catch {
            print("Download Error: \(error)")
            return nil
        }
    }
    
    func parse(json: String) -> [String: Any]? {
        guard let data = json.data(using: .utf8, allowLossyConversion: false)
            else { return nil }
        
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        }catch {
            print("JSON Error: \(error)")
            return nil
        }
    }
    
    func parse(dictionary: [String: Any]) -> [SearchResult]{
        // 1
        guard let array = dictionary["results"] as? [Any] else {
            print("Expected 'results' array")
            return []
        }
        
        var searchResults: [SearchResult] = []
        
        for resultDict in array {
            //3
            if let resultDict = resultDict as? [String: Any] {
                //4
                var searchResult: SearchResult?
                
                if let wrapperType = resultDict["wrapperType"] as? String {
                    switch wrapperType {
                    case "track":
                        searchResult = parse(track: resultDict)
                    case "audiobook":
                        searchResult = parse(audiobook: resultDict)
                    case "software":
                        searchResult = parse(software: resultDict)
                    default:
                        break
                    }
                } else if let kind = resultDict["kind"] as? String, kind == "ebook" {
                    searchResult = parse(ebook: resultDict)
                }
                if let result = searchResult {
                    searchResults.append(result)
                }
                
            }
        }
        
        return searchResults
    }
    
    func parse(track dictionary: [String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
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
    
    func kindForDisplay(_ kind: String) -> String {
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
        default: return kind
        }
    }
    
    func parse(audiobook dictionary: [String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        searchResult.name = dictionary["collectionName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
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
    
    func parse(software dictionary: [String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
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
    
    func parse(ebook dictionary: [String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        if let price = dictionary["price"] as? Double {
            searchResult.price = price
        }
        if let genres: Any = dictionary["genres"] {
            searchResult.genre = (genres as! [String]).joined(separator: ", ")
        }
        return searchResult
    }


    func showNetworkError() {
        let alert = UIAlertController(
            title: "Whoops...",
            message:
            "There was an error reading from the iTunes Store. Please try again.",
            preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        
        
        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()
            
            isLoading = true
            tableView.reloadData()
            hasSearched = true
            searchResults = []
            
            let queue = DispatchQueue.global()
            
            queue.async {
                let url = self.iTunesURL(searchText: searchBar.text!)
                if let jsonString = self.performStoreRequest(with: url),
                    let jsonDictionary = self.parse(json: jsonString) {
                    self.searchResults = self.parse(dictionary: jsonDictionary)
                    self.searchResults.sort(by: <)
                    // 3
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.tableView.reloadData()
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.showNetworkError()
                }
            }
            
            
        }
    }
}

extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 1
        }else if !hasSearched {
            return 0
        } else if searchResults.count == 0 {
            return 1
        }else {
            return searchResults.count
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loadingCell, for: indexPath)
            
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
            
        }else if searchResults.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.nothingFoundCell, for: indexPath)
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            let searchResult = searchResults[indexPath.row]
            cell.nameLabel.text = searchResult.name
            if searchResult.artistName.isEmpty {
                cell.artistNameLabel.text = "Unknown"
            } else {
                cell.artistNameLabel.text = String(format: "%@ (%@)",
                                                   searchResult.artistName, kindForDisplay(searchResult.kind))
            }
            return cell
        }
        
    }
    
}

extension SearchViewController: UITableViewDelegate {
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0 || isLoading {
            return nil
        }else {
            return indexPath
        }
    }
    
}

