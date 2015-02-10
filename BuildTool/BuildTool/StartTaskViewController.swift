//
//  StartTaskViewController.swift
//  BuildTool
//
//  Created by Thorsten Liese on 10/02/15.
//  Copyright (c) 2015 Thorsten Liese. All rights reserved.
//

import UIKit

class StartTaskViewController: UITableViewController {

    let jobList = [
        "Resynch Current Sandbox",
        "Build Project",
        "Execute doEverything",
        "Create Database HKG0",
        "Populate Database HKG0",
        "DevSystemInit HKG0",
        "Disable Rops HKG0",
        "Create Database HKG1",
        "Populate Database HKG1",
        "DevSystemInit HKG1",
        "Disable Rops HKG1",
        "Deploy Server HKG0",
        "Deploy Rops HKG0",
        "Deploy Rars HKG0",
        "Deploy Server HKG1",
        "Deploy Rars HKG1",
        "Deploy KKO"
    ]
    
    var selectedJob : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jobList.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("taskCell", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...
        cell.textLabel?.text = jobList[indexPath.row]

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedJob = jobList[indexPath.row]
        self.performSegueWithIdentifier("exitSegue", sender: self)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
