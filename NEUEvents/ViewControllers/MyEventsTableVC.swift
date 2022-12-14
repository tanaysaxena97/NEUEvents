//
//  MyEventsTableVC.swift
//  NEUEvents
//
//  Created by tanay on 11/24/22.
//

import UIKit

class MyEventsTableVC: UITableViewController {
    var dataSource: [Event] = []
    let eventDAO = EventDAO()
    let imageDAO = ImageDAO()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "eventCell")
//        populateEventsAReoadTableView()
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
        let event: Event = dataSource[indexPath.row]
        cell.textLabel?.text = dataSource[indexPath.row].name
        cell.imageView?.image = getImageFromDataForList(UIImage.init(systemName: "scope")!, size: CGSize(width: 200, height: 150))
        if event.imagePaths.count > 0 {
            imageDAO.getImageFromPath(event.imagePaths[0]) { image in
                cell.imageView?.image = getImageFromDataForList(image!, size: CGSize(width: 200, height: 150))
            }
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
    
    @IBAction func onSignOut(_ sender: UIBarButtonItem) {
        
    }
    // MARK: - Table view data source
    
    func populateEventsAReoadTableView() {
        eventDAO.getAllEvents { data in
            self.dataSource.removeAll()
            if !(data.value is NSNull) {
                for (_, v) in data.value! as! [String: Any] {
                    let event = Event(v as! [String: Any])
                    self.dataSource.append(event)
                }
            }
            self.tableView.reloadData()
        }
    }
    func onRowDeletion(_ indexPath: IndexPath) {
        let event = dataSource[indexPath.row]
        EventDAO().deleteEventWithId(event.id)
        self.dataSource.remove(at: indexPath.row)
    }
    
}

class ShowEventSegue: UIStoryboardSegue {
    override func perform() {
        let src = self.source
        let dest = self.destination
        let destFvc = dest as! CreateEventVC
        let srcLvc = (src as! MyEventsTableVC)
        let idx = srcLvc.tableView.indexPathForSelectedRow?.row ?? 0
        destFvc.setEvent(srcLvc.dataSource[idx].id)
        if srcLvc.dataSource[idx].organiserEmail != EventDAO.getSignedUserEmail() {
            destFvc.readOnly = true
        }
        src.navigationController?.pushViewController(dest, animated: true)
    }
}
