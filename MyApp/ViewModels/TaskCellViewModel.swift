//
//  TaskCellViewModel.swift
//  MyApp
//
//  Created by admin on 14/09/2020.
//  Copyright © 2020 Signe. All rights reserved.
//

import Foundation
import Combine
import Resolver

// Why identifiable: Want the ListView to use task cell ViewModels

// Need two view models - got CellView and ListView
class TaskCellViewModel: ObservableObject, Identifiable
{
    // Each task cell view models will hold a reference to a task
    // Need to be published, so any change on the task can be listned to
    @Published var task: Task
    
    @Published var taskRepository = TaskRepository()
        
    var id: String = ""
    
    @Published var completionStateIconName = ""
    
    // Keep track of the subscribers and assign them to a cancellable
    private var cancellables = Set<AnyCancellable>()
    
    init(task: Task)
    {
        self.task = task
        
        // Have a number of pipelines that are subscribed to the task property (the @Published task). So anytimes a task or one of the Task Fields is updated, both pipelines gets executed
        
        // Map operation on the task to transform it into a string
        // the String is going to tell which icon to use
        // Looks like in the view, but we are extracting this into the view model
        $task
            .map { task in
                task.completed ? "checkmark.circle.fill" : "circle"
        }
        // store the icon information in completionStateIconName
        .assign(to: \.completionStateIconName, on: self)
        // Store the information to the cancellables collection - Memory management purposes
        .store(in: &cancellables)
        
        // Keep track of the id
        $task
            .compactMap { task in
                task.id
        }
        // store the id information in id
        .assign(to: \.id, on: self)
        // Store the information to the cancellables collection - Memory management purposes
        .store(in: &cancellables)
        
        // Take the update, and push it to the repository, and send it to Firestore
        // This pipeline is going to be executed every time the user changes the text, and it whould be sent indviduel down here, then to the repository and then to Firestore
        // Instead of that, we can changes it to only send updates, when we stop typing - use the debounce operator .debounce(for: 0.8, scheduler: RunLoop.main)
        // It will wait 0.8 seconds and run it on the main run loop
        
        // If we make the changes to the task, instead of the user, we would end in an endless loop - use .dropFirst() that drops the first update and only send the following updates
        $task
            .dropFirst()
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .sink
            {
                task in
                self.taskRepository.updateTask(task)
            }
            .store(in: &cancellables)
    }
    
}

//class TaskCellViewModel: ObservableObject, Identifiable  {
//  @Injected var taskRepository: TaskRepository
//  
//  @Published var task: Task
//  
//  var id: String = ""
//  @Published var completionStateIconName = ""
//  
//  private var cancellables = Set<AnyCancellable>()
//  
//  static func newTask() -> TaskCellViewModel {
//    TaskCellViewModel(task: Task(title: "", priority: .medium, completed: false))
//  }
//  
//  init(task: Task) {
//    self.task = task
//    
//    $task
//      .map { $0.completed ? "checkmark.circle.fill" : "circle" }
//      .assign(to: \.completionStateIconName, on: self)
//      .store(in: &cancellables)
//
//    $task
//      .compactMap { $0.id }
//      .assign(to: \.id, on: self)
//      .store(in: &cancellables)
//    
//    $task
//      .dropFirst()
//      .debounce(for: 0.8, scheduler: RunLoop.main)
//      .sink { [weak self] task in
//        self?.taskRepository.updateTask(task)
//      }
//      .store(in: &cancellables)
//  }
//  
//}
