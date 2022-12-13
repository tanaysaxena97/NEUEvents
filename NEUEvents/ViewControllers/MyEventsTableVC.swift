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
        populateEventsAReoadTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        let event: Event = dataSource[indexPath.row]
        if event.organiserEmail == EventDAO.getSignedUserEmail() {
            let vc = CreateEventVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            // TODO: readonly view
        }
    }
    
    @IBAction func onSignOut(_ sender: UIBarButtonItem) {
        showConfirmationAlert(self, "Are you sure you want to signout?", cancelAction: {_ in}, okAction: {_ in
            signout()
            self.navigationController?.popViewController(animated: true)
        })
    }
    // MARK: - Table view data source
    
    func populateEventsAReoadTableView() {
        eventDAO.getAllEvents { data in
            self.dataSource.removeAll()
            for (_, v) in data.value! as! [String: Any] {
                let event = Event(v as! [String: Any])
                self.dataSource.append(event)
            }
            self.tableView.reloadData()
        }
    }
}

class showEventSegue: UIStoryboardSegue {
    override func perform(_ aSelector: Selector!) -> Unmanaged<AnyObject>! {
        <#code#>
    }
}
