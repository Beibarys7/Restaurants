//
//  StorageManager.swift
//  Restaurants
//
//  Created by Beibarys Shaggy on 20.08.2021.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func saveObject(_ place: Restaurant) {
        
        try! realm.write {
            realm.add(place)
        }
    }
    
    static func deleteObject(_ place: Restaurant) {
        
        try! realm.write {
            realm.delete(place)
        }
    }
}
