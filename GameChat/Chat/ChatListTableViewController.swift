//
//  ChatListTableViewController.swift
//  GameChat
//
//  Created by ido talmor on 30/12/2017.
//  Copyright © 2017 idotalmor. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit
import SDWebImage

class ChatListTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImage: UIBarButtonItem!
    
    //MARK: - Table view data source
    let dataSource = ChatListDataSource()
    let userUID = Auth.auth().currentUser!.uid
    let ChatToLoginStoryboard = "ChatToLoginStoryboard"
    var chatRef:DatabaseReference!
    
    //computed properties
    
    var index:[String]{
        return dataSource.index
    }
    var chats:[String:Chatlistitem]{
        return dataSource.chats
    }
    
    @IBAction func signOut(_ sender: UIBarButtonItem) {
        
        let firebaseAuth = Auth.auth()
        do {
            //sign out from firebase
            try firebaseAuth.signOut()
            //signout from facebook if needed
            let loginmanager = FBSDKLoginManager()
            loginmanager.logOut()
            //go back to login storyboard
            self.tabBarController?.performSegue(withIdentifier: self.ChatToLoginStoryboard, sender: nil)
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    

    @IBAction func addChat(_ sender: UIBarButtonItem) {
       //segue to tableview with users
        //self.tableView.reloadData()
        


        var ref = Database.database().reference(withPath: "Users")
        ref.queryOrdered(byChild: "User/email").queryEqual(toValue: "talmorid@gmail.com").observe(.childAdded) { (data) in
            print(data)
        }
        var dte:String = "dsafdsf"
        
        
    }
    
    @objc func showProfileDialog(_ uibutton: UIButton){
        print("dddddd")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        var image = UIImage(named: "ido")

        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitleColor(UIColor.white, for: .highlighted)
        button.setImage(image, for: .normal)
        button.imageView!.contentMode = .scaleAspectFit
        button.sizeToFit()
        button.frame.size = CGSize(width: 32, height: 32)
        button.widthAnchor.constraint(equalToConstant: 32.0).isActive = true
        button.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        button.imageView!.layer.cornerRadius = 32 / 2;
        button.addTarget(self, action:#selector(self.showProfileDialog(_:)), for: .touchUpInside)

        //self.profileImage.ba
        self.profileImage.customView = button

        tableView.dataSource = self
        tableView.delegate = self
        
        if let username = Auth.auth().currentUser?.displayName{
            self.navigationItem.title = username
        }else {
            self.navigationItem.title = "No Display Name"
        }
        
        chatRef = Database.database().reference(withPath:"Users/"+userUID+"/Chats")
        chatRef.observe(.childAdded) { (childsnapshot) in
            
            guard let c = Chatlistitem(dataSnapshot: childsnapshot) else{return}
            let indexPath = IndexPath(row: 0, section: 0)
            if(self.dataSource.insert(c, at: indexPath)){
                self.tableView.insertRows(at: [indexPath], with: .left)
            }
        }

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return index.count
    }

    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Chatlistitem", for: indexPath) as! ChatCell
        let chatItem = chats[index[indexPath.row]] as! Chatlistitem

        cell.photoURL = chatItem.photoURL
        cell.chatFriendName.text = chatItem.friendName
        cell.lastMsg.text = chatItem.lastMsg.msg
        cell.unreadMsg.text = chatItem.unreadMsg.description

        return cell
    }
 
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //get chatuid and perform segue
        print("dfgdfg")
    }
    
    /*
    // Override to support conditional editing of the table view.
     
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ChatListTableViewController{
//
//    func showProfileDialog(uibutton: UIButton){
//        print("dddddd")
//    }
    
}
