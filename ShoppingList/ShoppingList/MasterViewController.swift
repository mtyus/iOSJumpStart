//
//  MasterViewController.swift
//  ShoppingList
//
//  Created by Michael on 11/19/14.
//  Copyright (c) 2014 ACME, Inc. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController, DetailViewControllerDelegateProtocol
{
    // ++++++ Variable Declaration ++++++
    
    // Dictionary, containing a String key and String Array value, used to keep track of the user's shopping lists and their associated items.
    var shoppingListDictionary: Dictionary<String,[String]> = [:]
    
    // Array used to manage displaying shopping lists values on the master view controller.
    var shoppingListArray:[String] = []
    
    // Will serve as a delegate for the DetailViewController table view controller object.
    var detailViewController: DetailViewController = DetailViewController()

    // ++++++ Custom Methods/Functions ++++++
    
    // When the user creates a new shopping list item, via the DetailViewController scene, this
    // protocol method will update the "shoppingListDictionary" dictionary variable.
    func passDataBack(listKey: String, listValues: [String])
    {
        shoppingListDictionary.updateValue(listValues, forKey: listKey)
        manageShoppingListPListFile("saveData")
    }

    // This method will capture new shopping list values and handle displaying sorted shopping list values to the user.
    func insertNewObject(sender: AnyObject)
    {
        let newShoppingListAlert = UIAlertController(title: "New Shopping List",
            message: "Enter a name for this shopping list.",
            preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .Default)
            {(action) in let newShoppingListValue = newShoppingListAlert.textFields![0] as UITextField
                if String(newShoppingListValue.text).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) != ""
                {
                    self.shoppingListDictionary[newShoppingListValue.text] = []
                    self.shoppingListArray.append(newShoppingListValue.text)
                    var sortedShoppingList = sorted(self.shoppingListArray, {(s1: String, s2: String) -> Bool in return s1 < s2})
                    self.shoppingListArray.removeAll()
                    self.shoppingListArray = sortedShoppingList
                    self.tableView.reloadData()
                    self.manageShoppingListPListFile("saveData")
                }
        }
        newShoppingListAlert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in textField.placeholder = "Shopping List Name"})
        newShoppingListAlert.addAction(cancelAction)
        newShoppingListAlert.addAction(saveAction)
        self.presentViewController(newShoppingListAlert, animated: true, completion: nil)
    }
    
    // This function manages saving data to and retreiving data from the ShoppingList.plist file.
    func manageShoppingListPListFile(actionToTake:String)
    {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.LibraryDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let filePath:String = paths[0].stringByAppendingPathComponent("ShoppingList.plist") as String
        
        // Display
        println("Directory Path & File Being Written To: \(filePath)")
        
        // Retrieve shopping list and item data from the "ShoppingList.plist" file.
        if actionToTake == "getData"
        {
            if (NSFileManager.defaultManager().fileExistsAtPath(filePath))
            {
                let plistNSDictionary = NSDictionary(contentsOfFile: filePath)
                let plistSwiftDictionary = (plistNSDictionary)! as Dictionary
                for (plistKeyValue, plistDataValue) in plistSwiftDictionary
                {
                    let keyValue = plistKeyValue as String
                    let dataValue = plistDataValue as [String]
                    shoppingListDictionary[keyValue] = dataValue
                    //shoppingListArray.append(keyValue)
                }
                let shoppingListKeyValues = shoppingListDictionary.keys
                let sortedShoppingListKeyValues = sorted(shoppingListKeyValues, {(s1: String, s2: String) -> Bool in return s1 < s2})
                shoppingListArray = sortedShoppingListKeyValues
            }
        }
        
        // Save shopping list and item data to the "ShoppingList.plist" file.
        // Note: Data will be saved when either of the following three events occur
        //       (1) App loses focus.
        //       (2) User enters a new Shopping List value.
        //       (3) User enters a new Shopping List Item value.
        if actionToTake == "saveData"
        {// If the file exists then delete it, which will accommodate the user's deletions of data.
            if (NSFileManager.defaultManager().fileExistsAtPath(filePath))
            {
                NSFileManager.defaultManager().removeItemAtPath(filePath, error: nil)
            }
            let dictionaryArray: Dictionary<String,[String]> = self.shoppingListDictionary
            (dictionaryArray as NSDictionary).writeToFile(filePath, atomically:true)
        }
    }
    
    // Save shopping list and item data to the "ShoppingList.plist" file when the ShoppingList app loses focus or is no longer active.
    func applicationWillResignActive(notification:NSNotification)
    {
        manageShoppingListPListFile("saveData")
    }
    
    // ++++++ Override Methods ++++++
    
    // Perform additional setup tasks.
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Add an Add and Edit button to the MasterViewController.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        
        // Retrieve shopping list and item data from the "ShoppingList.plist" file.
        manageShoppingListPListFile("getData")
        
        // Subscribe to the UIApplicationWillResignActiveNotification notification (i.e. the ShoppingList app loses focus or is no longer active)
        // to trigger the execution of the applicationWillResignActive method, which will save shopping list and item data to the "ShoppingList.plist" file.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationWillResignActive:",
                                                               name: UIApplicationWillResignActiveNotification,
                                                               object: UIApplication.sharedApplication())
    }
    
    // Handle memory warnings.
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Prepare for the transition to the DetailViewController by passing the shopping list values and their associated shopping list items to
    // the DetailViewController. In addition, setup the "detailViewController" table view controller variable to act as a delegate of the
    // DetailViewController object.
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "showDetail"
        {
            if let indexPath = self.tableView.indexPathForSelectedRow()
              {
                (segue.destinationViewController as DetailViewController).shoppingListKey = shoppingListArray[indexPath.row]
                (segue.destinationViewController as DetailViewController).shoppingListValuesArray = shoppingListDictionary[shoppingListArray[indexPath.row]]!
                detailViewController = segue.destinationViewController as DetailViewController
                detailViewController.delegate = self
              }
        }
    }

    // Get the number of table view sections.
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    // Get the number of table view rows.
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return shoppingListArray.count
    }

    // Populate the table view cells.
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let masterDetailcell = tableView.dequeueReusableCellWithIdentifier("masterViewCell", forIndexPath: indexPath) as UITableViewCell
        let object = shoppingListArray[indexPath.row] as NSString
        masterDetailcell.textLabel.text = object.description
        return masterDetailcell
    }

    // Determine if item can be edited.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Mange deleting items from the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete
          {
            shoppingListDictionary.removeValueForKey(shoppingListArray[indexPath.row])
            shoppingListArray.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            manageShoppingListPListFile("saveData")
          }
    }
}

