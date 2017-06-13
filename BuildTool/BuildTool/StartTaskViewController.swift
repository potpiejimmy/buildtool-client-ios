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
    
    override func viewWillAppear(_ animated: Bool) {
        refresh();
    }

    func setLoading(_ loading: Bool) {
        self.isLoading = loading
        self.navigationItem.rightBarButtonItem?.isEnabled = !loading;
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
                let jsonResult: NSObject? = (try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSObject
//                println("Joblist\(jsonResult)")
                if (jsonResult != nil) {
                    self.sections.removeAll(keepingCapacity: true)
                    self.jobList.removeAll(keepingCapacity: true)
                    let jobListJsonString = jsonResult?.value(forKey: "value") as? String
                    let jobListJsonStringData = jobListJsonString?.data(using: String.Encoding.utf8)
                    let jobListJson: NSArray? = (try? JSONSerialization.jsonObject(with: jobListJsonStringData!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSArray
                    var sectionList: Array<String> = []
                    for item in jobListJson! {
                        var itemString: String = item as! String
                        if (itemString[itemString.startIndex] == "-") {
                            itemString = itemString.substring(from: itemString.characters.index(after: itemString.startIndex))
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return self.isLoading ? 0 : jobList.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isLoading ? 0 : jobList[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) 

        // Configure the cell...
        cell.textLabel?.text = jobList[indexPath.section][indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedJob = jobList[indexPath.section][indexPath.row]
        self.performSegue(withIdentifier: "exitSegue", sender: self)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
