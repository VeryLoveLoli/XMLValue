//
//  ViewController.swift
//  XMLValue
//
//  Created by 韦烽传 on 2018/10/4.
//  Copyright © 2018年 韦烽传. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        do {
            var htmlString = try String.init(contentsOf: URL.init(string: "http://www.baidu.com")!)
            htmlString = htmlString.xmlLegitimateString()
            let html = HTMLDocument.init(htmlString)
            print(html.xmlString())
            
            JSONXMLParser.xml(html.xmlData()) { (json, error) in
                
                let xml = XMLValue.init(json)
                let head = xml.getOne("head")
                print(head.elements[0].attributes)
            }
            
        } catch  {
            print(error)
        }
    }


}

