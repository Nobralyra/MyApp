//
//  TaskListViewModel.swift
//  MyApp
//
//  Created by admin on 14/09/2020.
//  Copyright © 2020 Signe. All rights reserved.
//

import Foundation
import Combine

// Need two view models - got CellView and ListView
// Wrapper around all the elements that is displaying in the list
class TaskListViewModel: ObservableObject
{
    // Properties
    //Use the repository - published so we can listen to the task collection in there
    @Published var taskRepository = TaskRepository()
    
    // Holding all the task cell view models in a array of task cell view model that is empty ()
    @Published var taskCellViewModels = [TaskCellViewModel]()
    
    // Keep track of the subscribers and assign them to a cancellable
    private var cancellables = Set<AnyCancellable>()
    
    // Instead of using the test data, we are using the data we're fetching and listening to using the task repository
    init()
    {
        // Take the taskRepository, take the tasks in there and map them.
        taskRepository.$tasks
            .map
            {
                // Get a collection of tasks in here
                tasks in
                // Maps the task and transform them into a task cell view model
                tasks.map
                {
                    // Get a task in
                    task in
                    // Convert it into a TaskCellViewModel, that takes a task and make it to a task
                    TaskCellViewModel(task: task)
                }
            }
            // Assign it to a collection on itself. The collelction it assign to is taskCellViewModels
            .assign(to: \.taskCellViewModels, on: self)
            // Store the cancelable
            .store(in: &cancellables)
    }
    
    // Convert all test tasks into little task cell view models
//    init()
//    {
//        self.taskCellViewModels = testDataTasks.map
//        {
//            task in
//            TaskCellViewModel(task: task)
//        }
//    }
    
    
    // Need to call the addTask from TaskRepository, beacuse whenever there is added a new item to our taskListViewModel, and make sure it goes to the repository and then back into Firestore.
    
    // Instead of just adding it to our collection - the internal collection here, we will use the reposiroy to manage that
    func addTask(task: Task)
    {
        taskRepository.addTask(task)
        
        // Method that capture out intent, adds it to the list of taskCellViewModels
        // Needs to be turned into a taskCellViewModel
//        let taskViewModel = TaskCellViewModel(task: task)
//        // add it to the collection
//        self.taskCellViewModels.append(taskViewModel)
    }
}
