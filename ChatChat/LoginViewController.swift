

import UIKit
import Firebase

class LoginViewController: UIViewController {
  
  @IBOutlet weak var nameField: UITextField!
  @IBOutlet weak var bottomLayoutGuideConstraint: NSLayoutConstraint!
  
  // MARK: View Lifecycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShowNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHideNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
  }
  
  @IBAction func loginDidTouch(_ sender: AnyObject) {
    //check namefield is not empty
    if nameField?.text != "" {
        // FireAuth sign in
        FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
        
            //If successed, move to ChannelViewController
            self.performSegue(withIdentifier: "LoginToChat", sender: nil)
        })
        
     }
  }
  
  // MARK: - Notifications
  
  func keyboardWillShowNotification(_ notification: Notification) {
    let keyboardEndFrame = ((notification as NSNotification).userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
    let convertedKeyboardEndFrame = view.convert(keyboardEndFrame, from: view.window)
    bottomLayoutGuideConstraint.constant = view.bounds.maxY - convertedKeyboardEndFrame.minY
  }
  
  func keyboardWillHideNotification(_ notification: Notification) {
    bottomLayoutGuideConstraint.constant = 48
  }
  
    
 // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let navVC = segue.destination as! UINavigationController
        let channelVC = navVC.viewControllers.first as! ChannelListViewController
        
        channelVC.sendDisplayName = nameField?.text
    }
}

