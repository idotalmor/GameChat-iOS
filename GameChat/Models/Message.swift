//
//  Message.swift
//  GameChat
//
//  Created by ido talmor on 01/01/2018.
//  Copyright © 2018 idotalmor. All rights reserved.
//

import Foundation

class Message{
    
    let msgUID : String
    let autherUID : String
    let msg : String
    let time : TimeInterval
    
    var json: Json{
        return [
            "msgUID": msgUID,
            "autherUID": autherUID,
            "msg": msg,
            "time" : time
        ]
    }
    
    init(msgUID:String,autherUID:String,msg:String,time:TimeInterval){
        self.msgUID = msgUID
        self.autherUID = autherUID
        self.msg = msg
        self.time = time
    }
   convenience init?(dictionary:Json){
        guard let msgUID = dictionary["msgUID"] as? String,
        let autherUID = dictionary["autherUID"] as? String,
        let msg = dictionary["msg"] as? String,
        let time = dictionary["time"] as? TimeInterval
            else {return nil}
        
    self.init(msgUID: msgUID,autherUID:autherUID, msg: msg, time: time)
        
    }
}


