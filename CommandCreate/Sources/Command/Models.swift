//
//  File.swift
//  
//
//  Created by Diana Maria Perez Afanador on 10/11/23.
//

import RealmSwift

// Paste the schema for the database
class Dog: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var name: String
    @Persisted var age: Int
    @Persisted var breed: String
}

