//
//  Script.swift
//  Extension
//
//  Created by Ivan Pavic on 17.2.22..
//

import UIKit

class Script: NSObject, Codable {
    var url: String
    var scriptText: String
    
    init (url: String, scriptText: String) {
        self.url = url
        self.scriptText = scriptText
    }
    required init(coder aDecoder: NSCoder) {
        url = aDecoder.decodeObject(forKey: "url") as? String ?? ""
        scriptText = aDecoder.decodeObject(forKey: "scriptText") as? String ?? ""
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(url, forKey: "url")
        aCoder.encode(scriptText, forKey: "scriptText")
    }

}
