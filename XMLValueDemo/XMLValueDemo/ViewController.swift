//
//  ViewController.swift
//  XMLValueDemo
//
//  Created by 韦烽传 on 2018/10/4.
//  Copyright © 2018年 韦烽传. All rights reserved.
//

import UIKit
import JSONValue
import XMLValue

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        do {
            /// 获取html文件
            var htmlString = try String.init(contentsOf: URL.init(string: "http://www.baidu.com")!)
            
            /// 过滤XML非法字符
            htmlString = htmlString.xmlLegitimateString()
            
            /// html文档
            let html = HTMLDocument.init(htmlString)
            print(html.xmlString())
            
            /// html文档转XML数据
            let xmlData = html.xmlData()
            
            /// 解析XML数据 转化成 JSONValue
            JSONXMLParser.xml(xmlData) { (json, error) in
                
                /// JSON值 XML方式取值
                let xml = XMLValue.init(json)
                /// 获取第一个 head 节点
                let head = xml.getOne("head")
                /// 输出 head 节点 第一个 子节点的属性
                print(head.elements[0].attributes)
            }
            
        } catch  {
            /// 错误信息
            print(error)
        }
    }


}

