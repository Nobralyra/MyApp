//
//  Task.swift
//  MyApp
//
//  Created by admin on 14/09/2020.
//  Copyright © 2020 Signe. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

// A Struct is codable if all the pieces in it are codable as well - in Swift all primitive types are codable
struct Task: Codable, Identifiable
{
    // Properties
    
    // Property wrapper @DocumentID - tells the Firebase codable support that whenever we are reading something from Firestore, and there is an ID property on a struct there, it should read the document ID from Firestore, and map it to this field
    // Use the document ID and map it to the ID
    @DocumentID var id: String?
    var title: String
    var completed: Bool
    // Make sure that all new items appear at the bottom of the list, is to add a new field that captures the created time of a new task, and we sort by created time
    // The @ServerTimestamp tells Firestore that when it saves a task, and the created time is not filled, it should use the server timestamp in order to fill the timestamp. Because the client time (clock) can be out of sync, with the general worlds time or the backend time, and we need to make sure that all data is in sync, at uses the same clock
    @ServerTimestamp var createdTime: Timestamp?
    
    // Use to track who a task belongs to
    var userId: String?
    
    
    
    // Before
    // Uses the UUID class and make it to a String
    // var id: String = UUID().uuidString
}

// Test data
#if DEBUG
// Collection of task
let testDataTasks = [
    Task(title: "Implement the UI", completed: true),
    Task(title: "Connect to Firebase", completed: false),
    Task(title: "???", completed: false),
    Task(title: "Profit!!", completed: false)
]
#endif
