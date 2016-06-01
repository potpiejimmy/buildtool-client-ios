//
//  StartTaskViewController.swift
//  BuildTool
//
//  Created by Thorsten Liese on 10/02/15.
//  Copyright (c) 2015 Thorsten Liese. All rights reserved.
//

import UIKit

class StartTaskViewController: UITableViewController {

    let BASE_URL = MainListViewController.BASE_URL_PREFIX + "params/" + MainListViewController.XXX_HOST_NAME + "/"
    
    var sections = ["Build","Database","Deploy"]
    var jobList = [
        ["Resynch Current Sandbox",
        "Build Project",
        "Execute doEverything"],
        ["Create Database HKG0",
        "Populate Database HKG0",
        "DevSystemInit HKG0",
        "Disable Rops HKG0",
        "Create Database HKG1",
        "Populate Database HKG1",
        "DevSystemInit HKG1",
        "Disable Rops HKG1"],
        ["Deploy Server HKG0",
        "Deploy Rops HKG0",
        "Deploy Rars HKG0",
        "Deploy Server HKG1",
        "Deploy Rars HKG1",
        "Deploy KKO"]
    ]
    
    @IBOutlet weak var mainList: UITableView!
    @IBOutlet weak var loadIndicatorView: UIView!
    
    var isLoading = false
    
    var selectedJob : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        refresh();
    }

    func setLoading(loading: Bool) {
        self.isLoading = loading
        self.navigationItem.rightBarButtonItem?.enabled = !loading;
        if (loading) {
            (self.loadIndicatorView.viewWithTag(1) as! UIActivityIndicatorView).startAnimating()
            mainList.tableHeaderView = loadIndicatorView
        } else {
            (self.loadIndicatorView.viewWithTag(1) as! UIActivityIndicatorView).stopAnimating()
            mainList.tableHeaderView = nil
        }
        self.mainList.reloadData() // update table
    }
    
    func refresh() {
        self.setLoading(true)
        TLWebRequester.request("GET", url: BASE_URL + "jobs",
            doneOk: {data in
                // okay
                let jsonResult: NSObject? = (try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)) as? NSObject
//                println("Joblist\(jsonResult)")
                if (jsonResult != nil) {
                    self.sections.removeAll(keepCapacity: true)
                    self.jobList.removeAll(keepCapacity: true)
                    let jobListJsonString = jsonResult?.valueForKey("value") as? String
                    let jobListJsonStringData = jobListJsonString?.dataUsingEncoding(NSUTF8StringEncoding)
                    let jobListJson: NSArray? = (try? NSJSONSerialization.JSONObjectWithData(jobListJsonStringData!, options: NSJSONReadingOptions.MutableContainers)) as? NSArray
                    var sectionList: Array<String> = []
                    for item in jobListJson! {
                        var itemString: String = item as! String
                        if (itemString[itemString.startIndex] == "-") {
                            itemString = itemString.substringFromIndex(itemString.startIndex.successor())
                            self.sections.append(itemString)
                            if (sectionList.count > 0) {self.jobList.append(sectionList)}
                            sectionList = []
                        } else {
                            sectionList.append(itemString)
                        }
                    }
                    if (sectionList.count > 0) {self.jobList.append(sectionList)}
                }
                self.setLoading(false)
            },
            doneFail: {() in
                // failure
                self.setLoading(false)
                return
        })
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return self.isLoading ? 0 : jobList.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isLoading ? 0 : jobList[section].count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("taskCell", forIndexPath: indexPath) 

        // Configure the cell...
        cell.textLabel?.text = jobList[indexPath.section][indexPath.row]

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedJob = jobList[indexPath.section][indexPath.row]
        self.performSegueWithIdentifier("exitSegue", sender: self)
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
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
