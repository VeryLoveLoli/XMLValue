# XMLValue

一个`Swift`语言简易的`XML`取值

1. [Integration](#Integration)
2. [Usage](#Usage)

## Integration

### Xcode
    File -> Swift Packages -> Add Package dependency

### CocoaPods

[GitHub XMLValue branch cocoapods](https://github.com/VeryLoveLoli/XMLValue/tree/cocoapods)

## Usage

### Initialization

```swift
import JSONValue
import XMLValue
```

```swift
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
            let xmljson = try JSONXMLParser.xml(xmlData)
            /// JSON值 XML方式取值
            let xml = XMLValue.init(xmljson)
            /// 获取第一个 head 节点
            let head = xml.getOne("head")
            /// 输出 head 节点 第一个 子节点的属性
            head.elements[0].attributes.formatPrint()
            
        } catch  {
            /// 错误信息
            print(error)
        }
```
