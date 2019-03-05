//
//  Deck.swift
//  bert8270_final
//
//  Created by Tudor Bertiean on 2018-03-21.
//  Copyright © 2018 wlu. All rights reserved.
//

import Foundation
import UIKit

class Deck: NSObject, NSCoding {
    private var notifications = [Notification]()
    private let deckKey = "deckKey"
    
    override init(){

    }
    
    required convenience init?(coder decoder: NSCoder) {
        self.init()
        notifications = (decoder.decodeObject(forKey: deckKey) as? [Notification])!
    }
    
    func encode(with acoder: NSCoder) {
        acoder.encode(notifications, forKey: deckKey)
    }
    
    func getNotifications() -> [Notification] {
        return notifications
    }
    
    func setNotifications(notifications: [Notification]) {
        self.notifications = notifications
    }
}


