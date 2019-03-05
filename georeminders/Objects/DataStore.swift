//
//  Deck.swift
//  bert8270_final
//
//  Created by Tudor Bertiean on 2018-03-21.
//  Copyright © 2018 wlu. All rights reserved.
//

import Foundation

class DataStore {
    static let sharedInstance = DataStore()
    private let fileName = "notifications.archive"
    private let rootKey = "rootKey"
    private var deck : Deck?

    // Define the path to the archive
    func dataFilePath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(
            FileManager.SearchPathDirectory.documentDirectory,
            FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory = paths[0] as NSString
        return documentsDirectory.appendingPathComponent(fileName) as String
    }
    
    // un-archive the data, load it into the Deck
    func loadDeck(){
        let filePath = self.dataFilePath()
        
        if (FileManager.default.fileExists(atPath: filePath)) {
            let data = NSMutableData(contentsOfFile: filePath)!
            let unarchiver = NSKeyedUnarchiver(forReadingWith: data as Data)
            deck = unarchiver.decodeObject(forKey: rootKey) as? Deck
            unarchiver.finishDecoding()
        }
        else {
            // If this is the initial app load, init the new deck and save it
            deck = Deck()
            saveDeck()
        }
    }
    
    // archive the Deck into the file
    func saveDeck(){
        let filePath = self.dataFilePath()
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)
        archiver.encode(deck, forKey: rootKey)
        archiver.finishEncoding()
        data.write(toFile: filePath, atomically: true)
    }
    
    func getDeck() -> Deck {
        return deck!
    }
    
    func setDeck(deck: Deck) {
        self.deck = deck
    }
}
