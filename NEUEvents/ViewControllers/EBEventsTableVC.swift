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
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "EBEventCell")
//        tableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "CustomTableViewCell")
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchResultsUpdater = self
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.definesPresentationContext = true
        self.navigationItem.titleView = getSegmentControl()
        populateData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as! CustomTableViewCell
//        cell.textLabel?.text = self.dataSource[indexPath.row].0.name
        cell.descriptionView.text = self.dataSource[indexPath.row].0.getCellText()
        cell.customImageView.layer.cornerRadius = 30
        cell.customImageView.clipsToBounds = true
        cell.customImageView.image = getImageFromDataForList(UIImage(named: "default")!, size: CGSize(width: 170, height: 120))
//        cell.imageView?.image = getImageFromDataForList(UIImage.init(systemName: "target")!, size: CGSize(width: 200, height: 150))
        DispatchQueue.main.async {
//            cell.imageView?.kf.setImage(with: URL(string: self.dataSource[indexPath.row].0.imageURL))
            
            cell.customImageView!.kf.setImage(with: URL(string: self.dataSource[indexPath.row].0.imageURL), options: [], progressBlock: { receivedSize, totalSize in
                print("\(indexPath.row + 1): \(receivedSize)/\(totalSize)")}) { result in
                    do {
                        let imageResult = try result.get() as RetrieveImageResult
                        cell.customImageView?.image = resizeImage(imageResult.image, size: CGSize(width: 170, height: 120))
                    }
                    catch {
                        print(error)
                    }
                }
        }
        cell.layoutMargins.bottom = 8
        cell.layoutMargins.top = 8
        
        return cell
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.performSegue(withIdentifier: "EBEventShowSegue", sender: nil)
//    }
    
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
        populateData()
        if i > 0 {
            dataSource = dataSource.filter({$0.1.contains(filters[i])})
        }
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

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var customImageView: UIImageView!
    
    @IBOutlet weak var descriptionView: UITextView!
    
}
