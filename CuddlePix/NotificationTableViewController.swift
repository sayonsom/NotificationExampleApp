import UIKit
import UserNotifications

class NotificationTableViewController: UITableViewController {
  
  var tableSectionProviders = [NotificationTableSection : TableSectionProvider]()
  
  @IBAction func handleRefresh(_ sender: UIRefreshControl) {
    loadNotificationData {
      DispatchQueue.main.async(execute: {
        self.tableView.reloadData()
        sender.endRefreshing()
      })
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    UNUserNotificationCenter.current()
      .requestAuthorization(options: [.alert, .sound]) {
        (granted, error) in
        if granted {
          self.loadNotificationData()
        } else {
          print(error?.localizedDescription)
        }
    }
    NotificationCenter.default.addObserver(self, selector: #selector(handleNotificationReceived), name: userNotificationReceivedNotificationName, object: .none)
  }
}

// MARK: - Table view data source
extension NotificationTableViewController {
  override func numberOfSections(in tableView: UITableView) -> Int {
    return tableSectionProviders.count
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let notificationTableSection = NotificationTableSection(rawValue: section),
      let sectionProvider = tableSectionProviders[notificationTableSection] else { return 0 }
    
    return sectionProvider.numberOfCells
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell = tableView.dequeueReusableCell(withIdentifier: "standardCell", for: indexPath)
    
    guard let tableSection = NotificationTableSection(rawValue: indexPath.section),
      let sectionProvider = tableSectionProviders[tableSection],
      let cellProvider = sectionProvider.cellProvider(at: indexPath.row)
      else { return cell }
    
    cell = cellProvider.prepare(cell)
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    guard let notificationTableSection = NotificationTableSection(rawValue: section),
      let sectionProvider = tableSectionProviders[notificationTableSection]
      else { return .none }
    
    return sectionProvider.name
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return NotificationTableSection(rawValue: indexPath.section) == .some(.pending)
  }
  
  override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
    return NotificationTableSection(rawValue: indexPath.section) == .some(.pending) ? .delete : .none
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    guard let section =
      NotificationTableSection(rawValue: indexPath.section),
      editingStyle == .delete && section == .pending else { return }
    
    guard let provider = tableSectionProviders[.pending]
      as? PendingNotificationsTableSectionProvider else { return }
    let request = provider.requests[indexPath.row]
    
    UNUserNotificationCenter.current()
      .removePendingNotificationRequests(withIdentifiers:
        [request.identifier])
    loadNotificationData(callback: {
      self.tableView.deleteRows(at: [indexPath], with: .automatic)
    })
  }
}

// MARK: - Table refresh handling
extension NotificationTableViewController {
  func handleNotificationReceived(_ notification: Notification) {
    loadNotificationData()
  }
  
  func loadNotificationData(callback: (() -> ())? = .none) {
    let group = DispatchGroup()
    
    let notificationCenter = UNUserNotificationCenter.current()
    let dataSaveQueue = DispatchQueue(label:
      "com.raywenderlich.CuddlePix.dataSave")
    
    group.enter()
    notificationCenter.getNotificationSettings { (settings) in
      let settingsProvider = SettingTableSectionProvider(settings:
        settings, name: "Notification Settings")
      dataSaveQueue.async(execute: {
        self.tableSectionProviders[.settings] = settingsProvider
        group.leave()
      })
    }
    
    group.enter()
    notificationCenter.getPendingNotificationRequests { (requests) in
      let pendingRequestsProvider =
        PendingNotificationsTableSectionProvider(requests:
          requests, name: "Pending Notifications")
      dataSaveQueue.async(execute: {
        self.tableSectionProviders[.pending] = pendingRequestsProvider
        group.leave()
      })
    }
    
    group.enter()
    notificationCenter.getDeliveredNotifications { (notifications) in
      let deliveredNotificationsProvider =
        DeliveredNotificationsTableSectionProvider(notifications:
          notifications, name: "Delivered Notifications")
      dataSaveQueue.async(execute: {
        self.tableSectionProviders[.delivered]
          = deliveredNotificationsProvider
        group.leave()
      })
    }
    
    group.notify(queue: DispatchQueue.main) {
      if let callback = callback {
        callback()
      } else {
        self.tableView.reloadData()
      }
    }
  }
}

// MARK: - ConfigurationViewControllerDelegate
extension NotificationTableViewController: ConfigurationViewControllerDelegate {
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destVC = segue.destination as? ConfigurationViewController {
      destVC.delegate = self
    }
  }
  
  func configurationCompleted(newNotifications new: Bool) {
    if new {
      loadNotificationData()
    }
    _ = navigationController?.popViewController(animated: true)
  }
}
