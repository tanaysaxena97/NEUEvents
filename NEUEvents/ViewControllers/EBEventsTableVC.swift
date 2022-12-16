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
    var sortAsc = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "EBEventCell")
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchResultsUpdater = self
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.definesPresentationContext = true
        populateData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EBEventCell", for: indexPath)
        cell.textLabel?.text = self.dataSource[indexPath.row].0.name
        cell.imageView?.image = getImageFromDataForList(UIImage.init(systemName: "target")!, size: CGSize(width: 200, height: 150))
        cell.imageView?.kf.setImage(with: URL(string: self.dataSource[indexPath.row].0.imageURL))
        cell.layoutMargins.bottom = 8
        cell.layoutMargins.top = 8
        
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
    @IBAction func onSortButtonTapped(_ sender: Any) {
        let format = "yyyy-MM-dd"
        if sortAsc == 1 {
            dataSource = dataSource.sorted {getDateFromString($0.0.startDate, format: format) < getDateFromString($1.0.startDate, format: format) }
        }
        else {
            dataSource = dataSource.sorted {getDateFromString($0.0.startDate, format: format) > getDateFromString($1.0.startDate, format: format) }
        }
        sortAsc = 1 - sortAsc
        tableView.reloadData()
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

class CustomTableCell: UITableViewCell {
    
    @IBOutlet weak var customImageView: UIImageView!
    @IBOutlet weak var venueField: UITextField!
    @IBOutlet weak var startDateField: UITextField!
    @IBOutlet weak var nameField: UITextField!
}
