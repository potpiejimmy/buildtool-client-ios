//
//  MainListViewController.swift
//  BuildTool
//
//  Created by Thorsten Liese on 08/02/15.
//  Copyright (c) 2015 Thorsten Liese. All rights reserved.
//

import UIKit

class MainListViewController: UITableViewController {

    static let XXX_HOST_NAME = "w7-deffm0366"
    static let BASE_URL_PREFIX = "http://www.doogetha.com/buildtool/res/"
    
    let BASE_URL = BASE_URL_PREFIX + "jobs/" + XXX_HOST_NAME + "/"
    
    @IBOutlet weak var mainList: UITableView!
    @IBOutlet weak var loadIndicatorView: UIView!
    
    var listData = NSMutableArray()
    
    var isLoading = false
    var mLastWaitForChangeRequest = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        startupInit();
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
    
    func startupInit() {
        self.setLoading(true)
        waitForChanges();
        refresh(self)
    }
    
    func waitForChangesElapsed() {
        waitForChanges();
        refresh(self);
    }
    
    func waitForChanges() {
        self.mLastWaitForChangeRequest = Date()
        TLWebRequester.request("GET", url: BASE_URL + "?waitForChange=true",
                               doneOk: {data in self.waitForChangesElapsed()},
                               doneFail: {() in
                                   if (Date().timeIntervalSince(self.mLastWaitForChangeRequest) > 1) {
                                       self.waitForChangesElapsed()
                                   }
                               })
    }
    
    func refresh(_ sender: AnyObject) {
        TLWebRequester.request("GET", url: BASE_URL,
            doneOk: {data in
                // okay
                let jsonResult: NSArray? = (try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)) as? NSArray
                //println("AsSynchronous\(jsonResult)")
                self.listData.removeAllObjects()
                if (jsonResult != nil) {self.listData.addObjects(from: jsonResult! as [AnyObject])}
                self.setLoading(false)
            },
            doneFail: {() in
                // failure
                self.setLoading(false)
                return
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    class func formatListItemDateTime(_ time : UInt64) -> String {
        let today = Date()
        let itemTime = Date(timeIntervalSince1970: TimeInterval(time/1000))
        
        let cal = Calendar.current
        let formatter = DateFormatter();
        
        let todayComp    = (cal as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day], from: today)
        let itemTimeComp = (cal as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day], from: itemTime)
        
        if (todayComp.day == itemTimeComp.day &&
            todayComp.month == itemTimeComp.month &&
            todayComp.year == itemTimeComp.year) {
            formatter.dateFormat = "HH:mm"
        } else {
            formatter.dateFormat = "MMM dd, HH:mm"
        }
        
        return formatter.string(from: itemTime)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return self.isLoading ? 0 : 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.isLoading ? 0 : listData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myTableCell", for: indexPath) 

        // Configure the cell...
        let item = listData[indexPath.row] as? NSDictionary
        let state = item?.object(forKey: "state") as? String
        let lastmodified = item?.object(forKey: "lastmodified") as? NSNumber
        let progress : Int? = Int(state!)
        
        (cell.viewWithTag(1) as! UILabel).text = item?.object(forKey: "name") as? String
        (cell.viewWithTag(2) as! UILabel).text = progress == nil ? state : state! + " %"
        (cell.viewWithTag(3) as! UIProgressView).isHidden = progress == nil
        (cell.viewWithTag(3) as! UIProgressView).progress = progress == nil ? 0 : Float(progress!)/100
        (cell.viewWithTag(4) as! UILabel).text = MainListViewController.formatListItemDateTime(UInt64((lastmodified?.int64Value)!))
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: nil, message: "Select Action", preferredStyle: UIAlertControllerStyle.actionSheet)
        alert.addAction(UIAlertAction(title: "Restart", style: UIAlertActionStyle.default, handler: {action in
            self.startTask(((self.listData[indexPath.row] as! NSDictionary).object(forKey: "name") as! String))
            self.tableView.deselectRow(at: indexPath, animated: false)
        }))
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.default, handler: {action in
            self.setLoading(true)
            TLWebRequester.request("DELETE", url: self.BASE_URL + ((self.listData[indexPath.row] as! NSDictionary).object(forKey: "name") as! String).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!,
                doneOk: nil,
                doneFail: {() in self.setLoading(false)}
            )
            self.tableView.deselectRow(at: indexPath, animated: false)
        }))
        alert.addAction(UIAlertAction(title: "Clear List", style: UIAlertActionStyle.default, handler: {action in
            self.setLoading(true)
            TLWebRequester.request("DELETE", url: self.BASE_URL, doneOk: nil, doneFail: {() in self.setLoading(false)})
            self.tableView.deselectRow(at: indexPath, animated: false)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {action in self.tableView.deselectRow(at: indexPath, animated: false)}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    //override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    //    return CGFloat.min
    //}
    
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

    @IBAction func returnedFromStartTaskList(_ segue: UIStoryboardSegue) {
        let startTaskView = segue.source as! StartTaskViewController
        
        startTask(startTaskView.selectedJob!)
    }
    
    func startTask(_ taskName: String) {
        self.setLoading(true)
        TLWebRequester.request("GET", url: BASE_URL + taskName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)! + "?set=pending",
            doneOk: nil,
            doneFail: {() in self.setLoading(false)}
        )
    }
}
