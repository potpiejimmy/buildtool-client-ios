//
//  TLWebRequester.swift
//  BuildTool
//
//  Created by Thorsten Liese on 08/02/15.
//  Copyright (c) 2015 Thorsten Liese. All rights reserved.
//

import Foundation

class TLWebRequester : NSObject {
    
    override init() {}
    
    var resultData : NSMutableData!
    var doneOk: ((NSData)->Void)!
    var doneFail: (()->Void)!
    
    func get(url : String, doneOk: (NSData)->Void, doneFail: ()->Void) {
        self.doneOk = doneOk
        self.doneFail = doneFail
        
        var req = NSMutableURLRequest()
        req.URL = NSURL(string: url)
        req.HTTPMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        NSURLConnection.sendAsynchronousRequest(req, queue: NSOperationQueue.mainQueue(), {(response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if (error != nil) {
                self.doneFail()
            } else {
                self.doneOk(data)
            }
        })

    }
    
}