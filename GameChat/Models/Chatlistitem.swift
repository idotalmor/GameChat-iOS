//
//  Chatlistitem.swift
//  GameChat
//
//  Created by ido talmor on 01/01/2018.
//  Copyright © 2018 idotalmor. All rights reserved.
//

import Foundation
import Firebase

class Chatlistitem{
    
    let chatUID : String
    let friendUID : String
    let friendName : String
    let photoURL : String
    var unreadMsg : Int
    var lastMsg : Message
    
    var json: Json{
        return [
            "ChatUID": chatUID,
            "friendUID": friendUID,
            "friendName": friendName,
            "photoURL" : photoURL,
            "unreadMsg": unreadMsg,
            "lastMsg": lastMsg.json,
        ]
    }
    
    init(chatUID : String, friendUID : String ,friendName : String ,photoURL : String, unreadMsg : Int ,lastMsg : Message ) {
        self.chatUID = chatUID
        self.friendUID = friendUID
        self.friendName = friendName
        self.photoURL = photoURL
        self.unreadMsg = unreadMsg
        self.lastMsg = lastMsg
    }
 
    convenience init?(dictionary: Json){
        guard let chatUID = dictionary["ChatUID"] as? String,
        let friendUID = dictionary["friendUID"] as? String,
        let friendName = dictionary["friendName"] as? String,
        let photoURL = dictionary["photoURL"] as? String,
        let unreadMsg = dictionary["unreadMsg"] as? Int,
        let lastMsg = dictionary ["lastMsg"] as? Json,
        let msg = Message(dictionary: lastMsg)
            else {return nil}
        
        self.init(chatUID: chatUID, friendUID: friendUID,friendName : friendName ,photoURL : photoURL, unreadMsg : unreadMsg, lastMsg: msg)
        
    }
    
    convenience init?(dataSnapshot : DataSnapshot){
        //dataSnapshot.key
        guard let values = dataSnapshot.value as? Json
            else{return nil}
        self.init(dictionary: values)
    }
    
}
