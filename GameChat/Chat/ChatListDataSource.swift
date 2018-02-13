//
//  ChatListDataSource.swift
//  GameChat
//
//  Created by ido talmor on 03/01/2018.
//  Copyright © 2018 idotalmor. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ChatListDataSource{
    
    var index : [String] = []
    var chats = [String:Chatlistitem]()
    
    let userUID = Auth.auth().currentUser!.uid
    var chatRef:DatabaseReference
    
    func delete(at indexPath:IndexPath)->Chatlistitem?{
        let friendUID = index.remove(at: indexPath.row)
        //need to delete from firebase
        return chats.removeValue(forKey: friendUID)
    }
    
    func insert(_ chat: Chatlistitem, at indexPath:IndexPath)->Bool{
        let friendUID = chat.friendUID
        if(index.contains(friendUID)){return false}
        
        index.insert(friendUID, at: indexPath.row)
        chats[friendUID] = chat
        return true
    }
//    init(listener: (Chatlistitem)->Void) {
     init() {
        //why twice??
       chatRef = Database.database().reference(withPath:"Users/"+userUID+"/Chats")
//        chatRef.observe(.value) { (datasnapshot) in
//
//            guard let data = datasnapshot.value as? Json else{return}
//            for (key,value) in data {
//
//                if let dictionary = value as? Json{
//                guard let c = Chatlistitem(dictionary:dictionary) else{return}
//                    print(dictionary)
//                    print("sdfgfdsg")
//                    print(key)
//            let friendUID = key
//            self.chats[friendUID] = c
//                    self.index.append(friendUID)}}
//            print(self.chats.count)
//
//        }
        
    }
    
    
    
}

//        let test = Chatlistitem(chatUID: "56A24F07-1A0D-4ADE-B180-571EC69122A0", friendUID: "56A24F07-1A0D-4ADE-B180-571EC69122A0", friendName: "idos", photoURL: "placeholderimg.jpg", unreadMsg: 4, lastMsg: Message(msgUID: "56A24F07-1A0D-4ADE-B180-571EC69122A0", autherUID: "56A24F07-1A0D-4ADE-B180-571EC69122A0", msg: "sadfsdf", time: 2))
//        chatRef.child(UUID().uuidString).setValue(test.json)
//        chats.append(test)
