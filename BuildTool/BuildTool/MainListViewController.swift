//
//  MainListViewController.swift
//  BuildTool
//
//  Created by Thorsten Liese on 08/02/15.
//  Copyright (c) 2015 Thorsten Liese. All rights reserved.
//

import UIKit

class MainListViewController: UITableViewController {

    let BASE_URL = "http://www.doogetha.com/buildtool/res/jobs/test/w7-deffm0287/"
    
    @IBOutlet weak var mainList: UITableView!
    @IBOutlet weak var loadIndicatorView: UIView!
    
    var listData = NSMutableArray()
    
    var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        refresh(self)
    }
    
    func setLoading(loading: Bool) {
        self.isLoading = loading
        self.navigationItem.rightBarButtonItem?.enabled = !loading;
        if (loading) {
            (self.loadIndicatorView.viewWithTag(1) as UIActivityIndicatorView).startAnimating()
            mainList.tableHeaderView = loadIndicatorView
        } else {
            (self.loadIndicatorView.viewWithTag(1) as UIActivityIndicatorView).stopAnimating()
            mainList.tableHeaderView = nil
        }
        self.mainList.reloadData() // to fetch count 0 when loading
    }
    
    @IBAction func refresh(sender: AnyObject) {
        self.setLoading(true)
        TLWebRequester.request("GET", url: BASE_URL,
            {data in
                // okay
                let jsonResult: NSArray = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSArray
                //println("AsSynchronous\(jsonResult)")
                self.listData.removeAllObjects()
                self.listData.addObjectsFromArray(jsonResult)
                self.setLoading(false)
            },
            {() in
                // failure
                self.setLoading(false)
                return
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.isLoading ? 0 : listData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("myTableCell", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...
        var item = listData[indexPath.row] as? NSDictionary
        let state = item?.objectForKey("state") as? String
        let progress : Int? = state?.toInt()
        
        (cell.viewWithTag(1) as UILabel).text = item?.objectForKey("name") as? String
        (cell.viewWithTag(2) as UILabel).text = progress == nil ? state : state! + " %"
        (cell.viewWithTag(3) as UIProgressView).hidden = progress == nil
        (cell.viewWithTag(3) as UIProgressView).progress = progress == nil ? 0 : Float(progress!)/100
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let alert = UIAlertController(title: "Delete entry", message: "Really delete?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: {action in
            self.setLoading(true)
            TLWebRequester.request("DELETE", url: self.BASE_URL + ((self.listData[indexPath.row] as NSDictionary).objectForKey("name") as String).stringByReplacingOccurrencesOfString(" ", withString: "%20", options: NSStringCompareOptions.LiteralSearch, range: nil),
                {data in self.refresh(self)},
                {() in self.setLoading(false)}
            )
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)}))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: {action in self.tableView.deselectRowAtIndexPath(indexPath, animated: false)}))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func returnedFromStartTaskList(segue: UIStoryboardSegue) {
        let startTaskView = segue.sourceViewController as StartTaskViewController
        
        self.setLoading(true)
        TLWebRequester.request("GET", url: BASE_URL + startTaskView.selectedJob!.stringByReplacingOccurrencesOfString(" ", withString: "%20", options: NSStringCompareOptions.LiteralSearch, range: nil) + "?set=pending",
            {data in self.refresh(self)},
            {() in self.setLoading(false)}
        )
    }
}
