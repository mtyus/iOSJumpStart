//
//  DetailViewController.swift
//  ShoppingList
//
//  Created by Michael on 11/19/14.
//  Copyright (c) 2014 ACME, Inc. All rights reserved.
//

import UIKit

// Protocol used to pass shopping list item data back to the MasterViewController controller
// object so that the "shoppingListDictionary" dictionary variable can be kept up to date.
protocol DetailViewControllerDelegateProtocol
{
    func passDataBack(listKey:String, listValues:[String])
}

class DetailViewController: UITableViewController
{
    // ++++++ Variable Declaration ++++++
    
    // These two variables are used to keep track of the shopping list value and the shopping list item values.
    // In addition, these two variables are used by the "passDataBack" protocol method to pass the shopping list
    // value and shopping list item values back to the MasterDetailController object.
    var shoppingListKey: String = ""
    var shoppingListValuesArray: [String] = []
    
    // Used to trigger the execution of the "passDataBack" protocol method.
    var delegate: DetailViewControllerDelegateProtocol?
    
    // ++++++ Custom Methods/Functions ++++++
    
    // This method will capture new shopping list item values and handle displaying sorted shopping list item values to the user.
    func insertNewObject(sender: AnyObject)
    {
        let newListItemAlert = UIAlertController(title: "New List Item",
            message: "Enter a name for this list item.",
            preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .Default)
            {(action) in let newShoppingListItemValue = newListItemAlert.textFields![0] as UITextField
                // If a non-blank value was entered then save a new shopping list item value.
                if String(newShoppingListItemValue.text).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) != ""
                {
                    self.shoppingListValuesArray.append(newShoppingListItemValue.text)
                    let sortedShoppingListItems = sorted(self.shoppingListValuesArray, {(s1: String, s2: String) -> Bool in return s1 < s2})
                    self.shoppingListValuesArray.removeAll()
                    self.shoppingListValuesArray = sortedShoppingListItems
                    self.tableView.reloadData()
                    // Trigger the delegation call in the MasterViewController to  keep the "shoppingListDictionary" dictionary variable up to date.
                    self.delegate?.passDataBack(self.shoppingListKey,listValues:self.shoppingListValuesArray)
                }
        }
        newListItemAlert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in textField.placeholder = "Shopping List Name"})
        newListItemAlert.addAction(cancelAction)
        newListItemAlert.addAction(saveAction)
        self.presentViewController(newListItemAlert, animated: true, completion: nil)
    }
    
    // ++++++ Override Methods ++++++
    
    // Perform additional setup tasks.
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Set the DetailViewController's "navigationItem.title" equal to the name of the shopping list.
        navigationItem.title = shoppingListKey
        
        // Add an Add button to the DetailViewController.
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    // Handle memory warnings.
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Get the number of table view sections.
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    // Get the number of table view rows.
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return shoppingListValuesArray.count
    }

    // Populate the table view cells.
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let detailViewCell = tableView.dequeueReusableCellWithIdentifier("detailViewCell", forIndexPath: indexPath) as UITableViewCell
        let object = shoppingListValuesArray[indexPath.row] as NSString
        detailViewCell.textLabel.text = object.description
        return detailViewCell
    }

    // Determine if item can be edited.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool 
    {
        // Return NO if you do not want the specified item to be editable.
        return true
    }

    // Mange deleting items from the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) 
    {
        if editingStyle == .Delete 
        {
            shoppingListValuesArray.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            // Trigger the delegation call in the MasterViewController to  keep the "shoppingListDictionary" dictionary variable up to date.
            self.delegate?.passDataBack(shoppingListKey,listValues:shoppingListValuesArray)
        }
    }
}
