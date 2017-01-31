

import UIKit
import UserNotifications
import AssetsLibrary

protocol ConfigurationViewControllerDelegate {
  func configurationCompleted(newNotifications new: Bool)
}

class ConfigurationViewController: UIViewController {
  
  var delegate: ConfigurationViewControllerDelegate?
  
  @IBOutlet weak var cuddlePixCount: UISegmentedControl!
  
  @IBAction func handleScheduleTapped(_ sender: UIButton) {
    guard let selectedString = cuddlePixCount.titleForSegment(at: cuddlePixCount.selectedSegmentIndex),
      let selectedNumber = Int(selectedString) else {
        delegate?.configurationCompleted(newNotifications: false)
        return
    }
    scheduleRandomNotifications(selectedNumber) {
      DispatchQueue.main.async(execute: {
        self.delegate?.configurationCompleted(newNotifications: selectedNumber > 0)
      })
    }
  }
  
  @IBAction func handleCuddleMeNow(_ sender: UIButton) {
    scheduleRandomNotification(in: 5) { success in
      DispatchQueue.main.async(execute: {
        self.delegate?.configurationCompleted(newNotifications: success)
      })
    }
  }
}

// MARK: - Notification Scheduling
extension ConfigurationViewController {
  func scheduleRandomNotifications(_ number: Int, completion: @escaping () -> ()) {
    guard number > 0  else {
      completion()
      return
    }
    
    let group = DispatchGroup()
    
    for _ in 0..<number {
      let randomTimeInterval = TimeInterval(arc4random_uniform(3600))
      group.enter()
      scheduleRandomNotification(in: randomTimeInterval, completion: {_ in
        group.leave()
      })
    }
    
    group.notify(queue: DispatchQueue.main) {
      completion()
    }
  }
  
  func scheduleRandomNotification(in seconds: TimeInterval, completion: @escaping (_ success: Bool) -> ()) {
    let randomImageName = "hug\(arc4random_uniform(12) + 1)"
    guard let imageURL = Bundle.main.url(forResource: randomImageName, withExtension: "jpg") else {
      completion(false)
      return
    }
    
    let attachment = try! UNNotificationAttachment(identifier:
      randomImageName, url: imageURL, options: .none)
    
    let content = UNMutableNotificationContent()
    content.title = "New cuddlePix!"
    content.subtitle = "What a treat"
    content.body = "Cheer yourself up with a hug 🤗 "
    content.attachments = [attachment]
    content.categoryIdentifier = newCuddlePixCategoryName
    
    let trigger = UNTimeIntervalNotificationTrigger(
      timeInterval: seconds, repeats: false)
    
    let request = UNNotificationRequest(
      identifier: randomImageName, content: content, trigger: trigger)
    
    UNUserNotificationCenter.current().add(request, withCompletionHandler:
      { (error) in
        if let error = error {
          print(error)
          completion(false)
        } else {
          completion(true)
        }
    })
  }
}
