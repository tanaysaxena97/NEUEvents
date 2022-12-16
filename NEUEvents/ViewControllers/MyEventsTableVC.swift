//
//  MyEventsTableVC.swift
//  NEUEvents
//
//  Created by tanay on 11/24/22.
//

import UIKit
import Kingfisher

class MyEventsTableVC: UITableViewController {
    var dataSource: [(Event, String)] = []
    let eventDAO = EventDAO()
    let imageDAO = ImageDAO()
    var sortAsc = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "eventCell")
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchResultsUpdater = self
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.definesPresentationContext = true
        self.navigationItem.titleView = getSegmentControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateEventsAReoadTableView()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
        let event: Event = dataSource[indexPath.row].0
        cell.textLabel?.text = dataSource[indexPath.row].0.name
        cell.imageView?.image = getImageFromDataForList(UIImage.init(systemName: "target")!, size: CGSize(width: 200, height: 150))
        if event.imagePaths.count > 0 {
            imageDAO.getDownloadURL(event.imagePaths[0]) { url, error in
                if error == nil {
                    cell.imageView?.kf.setImage(with: url)
                }
            }
//            imageDAO.getImageFromPath(event.imagePaths[0]) { image in
//                cell.imageView?.image = getImageFromDataForList(image!, size: CGSize(width: 200, height: 150))
//            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ShowEventSegue", sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            showConfirmationAlert(self, "Are you sure you want to delete?", cancelAction: {_ in}, okAction: {[tableView] _ in
                tableView.beginUpdates()
                self.onRowDeletion(indexPath)
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.endUpdates()
            })
        }
    }

    // MARK: - Table view data source
    
    func populateEventsAReoadTableView() {
        eventDAO.getAllEvents { data in
            self.dataSource.removeAll()
            if !(data.value is NSNull) {
                for (_, v) in data.value! as! [String: Any] {
                    let event = Event(v as! [String: Any])
                    self.dataSource.append((event, event.searchString()))
                }
            }
            self.tableView.reloadData()
        }
    }
    func onRowDeletion(_ indexPath: IndexPath) {
        let event = dataSource[indexPath.row].0
        EventDAO().deleteEventWithId(event.id)
        self.dataSource.remove(at: indexPath.row)
    }
    
    @IBAction func onSortButtonTapped(_ sender: Any) {
        if sortAsc == 1 {
            dataSource = dataSource.sorted(by: {getDateFromString($0.0.startTime) < getDateFromString($1.0.startTime)})
//            {getDateFromString($0.0.startTime) < getDateFromString($1.0.startTime) }
        }
        else {
            dataSource = dataSource.sorted(by: {getDateFromString($0.0.startTime) > getDateFromString($1.0.startTime)})
        }
        sortAsc = 1 - sortAsc
        tableView.reloadData()
    }
    
    func getSegmentControl() -> UISegmentedControl {
        let segment = UISegmentedControl(items: filters)
        segment.sizeToFit()
        segment.selectedSegmentTintColor = UIColor.tintColor
        segment.selectedSegmentIndex = 0
        segment.addTarget(self, action: #selector(didChangeSegment), for: .valueChanged)
        return segment
    }
    
    @objc func didChangeSegment(_ sender: UISegmentedControl) {
        let i = sender.selectedSegmentIndex
        eventDAO.getAllEvents { data in
            self.dataSource.removeAll()
            if !(data.value is NSNull) {
                for (_, v) in data.value! as! [String: Any] {
                    let event = Event(v as! [String: Any])
                    self.dataSource.append((event, event.searchString()))
                }
                if i > 0 {
                    self.dataSource = self.dataSource.filter({$0.1.contains(filters[i])})
                }
            }
            self.tableView.reloadData()
        }
    }
    
}

class ShowEventSegue: UIStoryboardSegue {
    override func perform() {
        let src = self.source
        let dest = self.destination
        let destFvc = dest as! CreateEventVC
        let srcLvc = (src as! MyEventsTableVC)
        let idx = srcLvc.tableView.indexPathForSelectedRow?.row ?? 0
        destFvc.setEvent(srcLvc.dataSource[idx].0.id)
        if srcLvc.dataSource[idx].0.organiserEmail != EventDAO.getSignedUserEmail() {
            destFvc.readOnly = true
        }
        src.navigationController?.pushViewController(dest, animated: true)
    }
}

extension MyEventsTableVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        print("Searching with: " + (searchController.searchBar.text ?? ""))
        
        eventDAO.getAllEvents { data in
            self.dataSource.removeAll()
            if !(data.value is NSNull) {
                for (_, v) in data.value! as! [String: Any] {
                    let event = Event(v as! [String: Any])
                    self.dataSource.append((event, event.searchString()))
                }
                if var searchText = searchController.searchBar.text, searchText != "" {
                    searchText = searchText.lowercased()
                    print(searchText)
                    self.dataSource = self.dataSource.filter({$0.1.contains(searchText)})
                }
                
            }
            self.tableView.reloadData()
        }
    }

}
