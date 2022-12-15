//
//  EBEventsTableVC.swift
//  NEUEvents
//
//  Created by tanay on 12/14/22.
//

import UIKit
import Kingfisher

class EBEventsTableVC: UITableViewController {
    var dataSource: [(EBEvent, String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "EBEventCell")
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchResultsUpdater = self
        self.navigationItem.searchController = searchController
        self.definesPresentationContext = true
        populateData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EBEventCell", for: indexPath)
//        var content = cell.defaultContentConfiguration()
//        content.text = self.dataSource[indexPath.row].name
//        content.secondaryText = self.dataSource[indexPath.row].summary
//        content.image = UIImage(systemName: "target")
//        content.image?.kf.setImage(with: URL(string: self.dataSource[indexPath.row].imageURL))
//        cell.contentConfiguration = content
        cell.textLabel?.text = self.dataSource[indexPath.row].0.name
        cell.imageView?.image = getImageFromDataForList(UIImage.init(systemName: "target")!, size: CGSize(width: 200, height: 150))
        cell.imageView?.kf.setImage(with: URL(string: self.dataSource[indexPath.row].0.imageURL))
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "EBEventShowSegue", sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func populateData() {
        self.dataSource.removeAll()
        for event in EBEventDAO.events!.events {
            self.dataSource.append((event, event.getSearchText()))
        }
    }
}

extension EBEventsTableVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        print("Searching with: " + (searchController.searchBar.text ?? ""))
        
        if var searchText = searchController.searchBar.text, searchText != "" {
            searchText = searchText.lowercased()
            print(searchText)
            populateData()
            dataSource = dataSource.filter({$0.1.contains(searchText)})
        }
        else {
            populateData()
        }
        tableView.reloadData()
    }

}

class EBEventShowSegue: UIStoryboardSegue {
    override func perform() {
        let src = self.source
        let dest = self.destination
        let destFvc = dest as! EBEventVC
        let srcLvc = (src as! EBEventsTableVC)
        let idx = srcLvc.tableView.indexPathForSelectedRow?.row ?? 0
        destFvc.setEvent(srcLvc.dataSource[idx].0)
        src.navigationController?.pushViewController(dest, animated: true)
    }
}