//
//  TLWebRequester.swift
//  BuildTool
//
//  Created by Thorsten Liese on 08/02/15.
//  Copyright (c) 2015 Thorsten Liese. All rights reserved.
//

import Foundation

class TLWebRequester {
    
    class func request(method: String, url : String, doneOk: ((NSData)->Void)?, doneFail: (()->Void)?) {
        let req = NSMutableURLRequest()
        req.URL = NSURL(string: url)
        req.HTTPMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        NSURLConnection.sendAsynchronousRequest(req, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            if (error != nil || (response as? NSHTTPURLResponse)?.statusCode >= 300) {
                doneFail?()
            } else {
                doneOk?(data!)
            }
        })

    }
    
}