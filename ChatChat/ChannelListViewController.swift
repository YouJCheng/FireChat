

import UIKit
import Firebase

enum Section: Int {
    case createNewChannelSection = 0
    case currentChannelsSection
}


class ChannelListViewController: UITableViewController {
    /*
     sender's name
     adding new channel
     creatr empty array to store channels
     */
    var sendDisplayName: String?
    var newChannelTextField: UITextField?
    private var channelsArray: [Channel] = []
    private lazy var channelRef: FIRDatabaseReference = FIRDatabase.database().reference().child("channels")
    private var channelRefHandle: FIRDatabaseHandle?
    
    // MARK: View Lifecyle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "RW RIC"
        observeChannels()
    }
    
    deinit {
        if let refHandle = channelRefHandle {
            channelRef.removeObserver(withHandle: refHandle)
        }
    }
    
    // MARK: Actions
    @IBAction func createChannel(_ sender:AnyObject) {
        if let name = newChannelTextField?.text {
            let newChannelRef = channelRef.childByAutoId()
            let channelItem = [ "name": name]
            
            newChannelRef.setValue(channelItem)
        }
    }
    
    
    // MARK: UITableViweDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == Section.currentChannelsSection.rawValue {
            let channel = channelsArray[(indexPath as NSIndexPath).row]
            self.performSegue(withIdentifier: "ShowChannel", sender: channel)
        }
    }
    
    // MARK: UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentSection: Section = Section(rawValue:section) {
            switch currentSection {
            case .createNewChannelSection:
                return 1
            case .currentChannelsSection:
                return channelsArray.count
            }
        } else {
            return 0
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reuseIdentifier = (indexPath as NSIndexPath).section == Section.createNewChannelSection.rawValue ? "NewChannel" : "ExistingChannel"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        if (indexPath as NSIndexPath).section == Section.createNewChannelSection.rawValue {
            if let createNewChannelCell = cell as? CreateChannelCell {
                newChannelTextField = createNewChannelCell.newChannelNameField
            }
        } else if (indexPath as NSIndexPath).section == Section.currentChannelsSection.rawValue {
            cell.textLabel?.text = channelsArray[(indexPath as NSIndexPath).row].name
        }
        
        return cell
    }
    
   
    
    // MARK: Firebase related methods
    private func observeChannels() {
        // use observe method to listen for new
        // channels being written to Firebase DB
        channelRefHandle = channelRef.observe(.childAdded, with: { (snapshot) -> Void in
            let channelData = snapshot.value as! Dictionary <String, AnyObject>
            let id = snapshot.key
            if let name = channelData["name"] as! String! , name.characters.count > 0 {
                self.channelsArray.append(Channel(id: id, name: name))
                self.tableView.reloadData()
            } else {
                print("Error! Could not decode channel data")
            }
        })
        
    }
   
  //MARK: Navigation 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let channel = sender as? Channel {
            let chatVC = segue.destination as! ChatViewController
            
            chatVC.senderDisplayName = sendDisplayName
            chatVC.channel = channel
            chatVC.channelRef = channelRef.child(channel.id)
        }
    }
    
    
    
}
