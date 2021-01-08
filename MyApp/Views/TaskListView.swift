//
//  TaskListView.swift
//  MyApp
//
//  Created by admin on 14/09/2020.
//  Copyright © 2020 Signe. All rights reserved.
//

import SwiftUI

struct TaskListView: View
{
    // Bind the taskListViewModel to the UI
    // SwiftUI listen to any updates that this is producing
    @ObservedObject var taskListViewModel = TaskListViewModel()
    
    // Gets the test data
    //let tasks = testDataTasks
    
    // Flag that hide and show a specific cell on demand, when the user presses on the "Add New Task" button
    @State var presentAddNewItem = false
    
    @State var showSignInForm = false
    
    var body: some View
    {
        NavigationView
        {
            VStack(alignment: .leading)
            {
                // For each that acces the View Model and iterates over all the elements (task cell view models) in the task collection in view model
                // And then add one specific new element - the editor element
                List()
                {
                    ForEach(taskListViewModel.taskCellViewModels)
                    {
                        taskCellViewModel in
                        TaskCell(taskCellViewModel: taskCellViewModel)
                    }
                    // Display a task cell, depending on whether a presentAddNewItem is true or false
                    // Need to create a dummy task cell view model here
                    if presentAddNewItem
                    {
                        TaskCell(taskCellViewModel: TaskCellViewModel(task: Task(title: "", completed: false)))
                        {
                            // Trailling closure
                            task in
                            self.taskListViewModel.addTask(task: task)
                            
                            // When the user hits enter, we will insert the element into the lists. That means the list will add a new line
                            self.presentAddNewItem.toggle()
                        }
                    }
                }
                
                // Whenever the user presses the button we want to show or hide the additional cell (presentAddNewItem)
                Button(action: { self.presentAddNewItem.toggle()})
                {
                    HStack
                    {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("Add New Task")
                    }
                }
                .padding()
            }
            
            // The button to sign in on the navigationbar
            .navigationBarItems(trailing:
                Button(action:
                {
                    self.showSignInForm.toggle()
                })
                {
                    Image(systemName: "person.circle")
                }
            )
            // First of the child in the NavigationView witch is the VStack
            .navigationBarTitle("Tasks")
            // Presentes the sign in the navigation
            // $ symbol er brugt til at bind
            .sheet(isPresented: $showSignInForm)
            {
                SignInView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider
{
    static var previews: some View
    {
        TaskListView()
    }
}

// Ved ikke hvad task er, så man laver en constant task, som kommer med som parameter
struct TaskCell: View
{
    @ObservedObject var taskCellViewModel: TaskCellViewModel
    
    // Callback
    var onCommit: (Task) -> (Void) = { _ in } // Provide an empty default implementation
    
    var body: some View
    {
        HStack
        {
            // ternary if statement
            // If task is completed use "checkmark.circle.fill"
            // else use "circle"
            
            // When the user taps on the image, the toggle the completed state of the underlying task
            Image(systemName: taskCellViewModel.task.completed ? "checkmark.circle.fill" : "circle")
                .resizable()
                .frame(width: 20, height: 20)
                .onTapGesture
                {
                    self.taskCellViewModel.task.completed.toggle()
                }
            // Bind the text value of the text field to the title of the task in the View Model
            
            // Listen to any change the users make and take those changes from the cell view model and put it back in the underlying data structure
            // Add a callback handler - listen to the uncommit event on the TextField, and when is fired, we want to call back into the view that then take the task, that is created and send it back into the underlying data strcuture
            TextField("Enter the task title", text: $taskCellViewModel.task.title, onCommit:
                { self.onCommit(self.taskCellViewModel.task)
            })
        }
    }
}
