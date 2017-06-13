//
//  TLWebRequester.swift
//  BuildTool
//
//  Created by Thorsten Liese on 08/02/15.
//  Copyright (c) 2015 Thorsten Liese. All rights reserved.
//

import Foundation

class TLWebRequester {
    
    class func request(_ method: String, url : String, doneOk: ((Data)->Void)?, doneFail: (()->Void)?) {
        let req = NSMutableURLRequest()
        req.url = URL(string: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        NSURLConnection.sendAsynchronousRequest(req as URLRequest, queue: OperationQueue.main, completionHandler: {(response: URLResponse?, data: Data?, error: Error?) -> Void in
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            if (error != nil || (statusCode != nil && statusCode! >= 300)) {
                doneFail?()
            } else {
                doneOk?(data!)
            }
        } as (URLResponse?, Data?, Error?) -> Void)

    }
    
}
