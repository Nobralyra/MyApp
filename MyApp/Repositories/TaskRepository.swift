//
//  TaskRepository.swift
//  MyApp
//
//  Created by admin on 14/09/2020.
//  Copyright © 2020 Signe. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

// Can listen to any updates that are published by the publishers
class TaskRepository: ObservableObject
{
    // Properties
    // Store the firestore database
    let database = Firestore.firestore()
    
    // Listen to the collection task in the Firestore instance
    @Published var tasks = [Task]()
    
    
    
    init()
    {
        loadData()
    }
    
    // Implement method with a snapshot listener, that listens to the collection in the Firestore instance
    // Instead of querying all the tasks, we want to filter, and get all the tasks that belongs to one specific user - use .whereField where we only get all the documents where the userId is equal to current user
    func loadData()
    {
        let userId = Auth.auth().currentUser?.uid
        
        database.collection("tasks")
        .order(by: "createdTime")
        .whereField("userId", isEqualTo: userId)
        .addSnapshotListener
        {
            (querySnapshot, error) in
            
            if let querySnapshot = querySnapshot
            {
                // Get all the documents querySnapShot have fetched and iterate over the documents with compactMap
                // Transform all of the documents into task elements (tasks structs), and we can assign those to the Tasks collection
                // Usually you had to look into the document, which hosts all the fields that are in the document, and then marshall all those properties - all those fields on the document back into your data structure that we are using in the application. Codeable make it so we do not need to do that, but go straigt to document.data(as: Task.self)
                self.tasks = querySnapshot.documents.compactMap
                {
                    document in
                    do
                    {
                        let x = try document.data(as: Task.self) // Put the codable typealias on Task 
                        return x
                    }
                    catch
                    {
                        // Prints the error
                        print(error)
                    }
                    return nil
                }
            }
        }
    }
    
    // Add task to Firestore
    func addTask(_ task: Task)
    {
        do
        {
            // Helper instance to make sure we get the tasks from the current user
            var addedTask = task
            addedTask.userId = Auth.auth().currentUser?.uid
            
            // Codable will automatically be able to map this data into the document
            // With let _ = we are swallowing the results
            let _ = try database.collection("tasks").addDocument(from: addedTask)
        }
        catch
        {
            fatalError("Unable to encode task: \(error.localizedDescription)")
        }
    }
    
    // Update task to Firestore
    func updateTask(_ task: Task)
    {
        // Check if task have an ID
        if let taskId = task.id
        {
            do
            {
                // Get the tasks collection, to get the document with the task id, and overrite the information in Firestore
                try database.collection("tasks").document(taskId).setData(from: task)
            }
            catch
            {
                fatalError("Unable to encode task: \(error.localizedDescription)")
            }
        }
    }
}


