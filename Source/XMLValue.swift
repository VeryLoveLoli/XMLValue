//
//  XMLValue.swift
//  XMLValue
//
//  Created by 韦烽传 on 2018/10/4.
//  Copyright © 2018年 韦烽传. All rights reserved.
//

import Foundation
import JSONValue

// MARK: - XML数据取值

/**
 *  XML的取值方式
 *  用于XML转成JSON后的取值
 */
public class XMLValue {
    
    // MARK: Parameter
    
    /// 节点数据
    var JSON: JSONValue!
    
    // MARK: init
    
    public init(_ json: JSONValue) {
        
        JSON = json
    }
    
    /**
     获取节点
     
     - parameter    name:           节点名称
     - parameter    attributes:     节点属性
     
     - return:      返回匹配节点数组
     */
    public func get(_ name: String, attributes: [String: Any]? = nil) -> [XMLValue] {
        
        var items: [XMLValue] = []
        
        if self.name.string == name {
            
            if let parames = attributes {
                
                var bool = true
                
                for (key, value) in parames {
                    
                    if self.JSON[JSONXMLKEY.attributes.string][key].string != JSONValue(value).string {
                        
                        bool = false
                        break
                    }
                }
                
                if bool {
                    
                    items.append(XMLValue(self.JSON))
                }
            }
            else {
                
                items.append(XMLValue(self.JSON))
            }
        }
        
        for item in self.JSON[JSONXMLKEY.elements.string].array {
            
            items += XMLValue.init(item).get(name, attributes: attributes)
        }
        
        return items
    }
    
    /**
     获取节点
     
     - parameter    name:           节点名称
     - parameter    attributes:     节点属性
     
     - return:      第一个匹配节点
     */
    public func getOne(_ name: String, attributes: [String: Any]? = nil) -> XMLValue {
        
        let items = self.get(name, attributes: attributes)
        return items.count > 0 ? items[0] : XMLValue.init(JSONValue())
    }
    
    /// 节点名称
    public var name: JSONValue {
        
        return JSON[JSONXMLKEY.name.string]
    }
    
    /// 节点属性
    public var attributes: JSONValue {
        
        return JSON[JSONXMLKEY.attributes.string]
    }
    
    /// 节点内容
    public var elementContent: JSONValue {
        
        return JSON[JSONXMLKEY.content.string]
    }
    
    /// 节点下的节点
    public var elements: [XMLValue] {
        
        return JSON[JSONXMLKEY.elements.string].array.map({ (json) -> XMLValue in
            
            return XMLValue.init(json)
        })
    }
}

// MARK: - XML转JSON后的key

public enum JSONXMLKEY {
    
    /// 节点名称
    case name
    /// 属性
    case attributes
    /// 节点内容
    case content
    /// 节点数组
    case elements
    /// 命名空间URI
    case namespaceURI
    /// 合格名称
    case qualifiedName
    /// JS代码    base64后的字符串
    case CDATA
    
    public var string: String {
        
        get {
            
            switch self {
            case .name:
                return "name"
            case .attributes:
                return "attributes"
            case .content:
                return "content"
            case .elements:
                return "elements"
            case .namespaceURI:
                return "namespaceURI"
            case .qualifiedName:
                return "qualifiedName"
            case .CDATA:
                return "CDATA"
            }
        }
    }
}

// MARK: - XML解析

/**
 *  将XML解析成JSON
 *
 *  格式
 /*节点*/
 ["name": "",            /// 节点名称
 "attributes": [:],      /// 节点属性
 "content": "",          /// 节点内容
 "namespaceURI": "",     /// 命名空间URI
 "qualifiedName": ""     /// 合格名称
 "CDATA": ""             /// JS代码    base64后的字符串
 "elements": [           /// 节点列表
 ["name": "", ...],  /// 节点
 ...]
 ]
 */
public class JSONXMLParser: NSObject, XMLParserDelegate {
    
    // MARK: Parameter
    
    /// 闭包
    var block: (JSONValue, Error?)->Void = {_,_ in }
    
    /// 节点数组
    var keys: [String] = []
    /// JSON 数据
    var JSON = JSONValue()
    /// 当前节点路径
    var elementPath: [Any] = []
    
    // MARK: Class public func
    
    /**
     解析XML
     
     - parameter    string:     XML字符串
     - parameter    block:      解析结果
     */
    public class func xml(_ string: String, block: @escaping (JSONValue, Error?)->Void) {
        
        self.xml(string.data(using: .utf8) ?? Data(), block: block)
    }
    
    /**
     解析XML
     
     - parameter    data:       XML数据
     - parameter    block:      解析结果
     */
    public class func xml(_ data: Data, block: @escaping (JSONValue, Error?)->Void) {
        
        let xml = JSONXMLParser.init()
        xml.block = block
        
        let xmlParser = XMLParser.init(data: data)
        xmlParser.delegate = xml
        xmlParser.parse()
    }
    
    // MARK: XMLParserDelegate
    
    /**
     解析开始
     */
    public func parserDidStartDocument(_ parser: XMLParser) {
        
    }
    
    /**
     开始映射前缀
     */
    public func parser(_ parser: XMLParser, didStartMappingPrefix prefix: String, toURI namespaceURI: String) {
        
    }
    
    /**
     开始元素
     */
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        elementPath = createNextPath()
        
        JSON[elementPath + [JSONXMLKEY.name.string]] = JSONValue(elementName)
        
        if attributeDict.keys.count > 0 {
            
            JSON[elementPath + [JSONXMLKEY.attributes.string]] = JSONValue(attributeDict)
        }
        
        if namespaceURI != nil {
            
            JSON[elementPath + [JSONXMLKEY.namespaceURI.string]] = JSONValue(namespaceURI)
        }
        if qName != nil {
            
            JSON[elementPath + [JSONXMLKEY.qualifiedName.string]] = JSONValue(qName)
        }
        
        keys.append(elementName)
    }
    
    /**
     发现CDATA
     */
    public func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        
        JSON[elementPath + [JSONXMLKEY.CDATA.string]] = JSONValue(CDATABlock.base64EncodedString())
    }
    
    /**
     发现评论
     */
    public func parser(_ parser: XMLParser, foundComment comment: String) {
        
    }
    
    /**
     发现字符
     */
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        var content = string
        
        content = content.replacingOccurrences(of: "\\", with: "\\\\")
        content = content.replacingOccurrences(of: "\"", with: "\\\"")
        content = content.replacingOccurrences(of: "\r", with: "\\r")
        content = content.replacingOccurrences(of: "\t", with: "\\t")
        content = content.replacingOccurrences(of: "\n", with: "\\n")
        
        var filterString = string
        
        filterString = filterString.replacingOccurrences(of: "\r", with: "")
        filterString = filterString.replacingOccurrences(of: "\t", with: "")
        filterString = filterString.replacingOccurrences(of: "\n", with: "")
        filterString = filterString.replacingOccurrences(of: " ", with: "")
        
        if filterString.count > 0 {
            
            JSON[elementPath + [JSONXMLKEY.content.string]] = JSONValue(JSON[elementPath + [JSONXMLKEY.content.string]].string + content)
        }
    }
    
    /**
     发现可忽略的空白
     */
    public func parser(_ parser: XMLParser, foundIgnorableWhitespace whitespaceString: String) {
        
    }
    
    /**
     发现内部实体声明与名称
     */
    public func parser(_ parser: XMLParser, foundInternalEntityDeclarationWithName name: String, value: String?) {
        
    }
    
    /**
     发现带名称的元素声明
     */
    public func parser(_ parser: XMLParser, foundElementDeclarationWithName elementName: String, model: String) {
        
    }
    
    /**
     发现处理指令与目标
     */
    public func parser(_ parser: XMLParser, foundProcessingInstructionWithTarget target: String, data: String?) {
        
    }
    
    /**
     发现带名称的符号声明
     */
    public func parser(_ parser: XMLParser, foundNotationDeclarationWithName name: String, publicID: String?, systemID: String?) {
        
    }
    
    /**
     发现外部实体定义名称
     */
    public func parser(_ parser: XMLParser, foundExternalEntityDeclarationWithName name: String, publicID: String?, systemID: String?) {
        
    }
    
    /**
     发现带有名称的未解析的实体声明
     */
    public func parser(_ parser: XMLParser, foundUnparsedEntityDeclarationWithName name: String, publicID: String?, systemID: String?, notationName: String?) {
        
    }
    
    /**
     发现带名称的属性声明
     */
    public func parser(_ parser: XMLParser, foundAttributeDeclarationWithName attributeName: String, forElement elementName: String, type: String?, defaultValue: String?) {
        
    }
    
    /**
     解决外部实体名称
     */
    public func parser(_ parser: XMLParser, resolveExternalEntityName name: String, systemID: String?) -> Data? {
        
        return nil
    }
    
    /**
     解析错误
     */
    public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        
        block(JSONValue(), parseError)
    }
    
    /**
     验证错误
     */
    public func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
        
        block(JSONValue(), validationError)
    }
    
    /**
     结束映射前缀
     */
    public func parser(_ parser: XMLParser, didEndMappingPrefix prefix: String) {
        
    }
    
    /**
     结束元素
     */
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        keys.removeLast()
        
        elementPath = getCurrentPath()
    }
    
    /**
     解析结束
     */
    public func parserDidEndDocument(_ parser: XMLParser) {
        
        block(JSON, nil)
    }
    
    // MARK: Event
    
    /**
     创建下一个节点路径
     */
    public func createNextPath() -> [Any] {
        
        var path: [Any] = []
        
        for i in 0..<keys.count {
            
            path.append(JSONXMLKEY.elements.string)
            
            if i == keys.count - 1 {
                
                path.append(JSON[path].array.count)
            }
            else  {
                
                path.append(JSON[path].array.count - 1)
            }
        }
        
        return path
    }
    
    /**
     获取当前节点路径
     */
    public func getCurrentPath() -> [Any] {
        
        var path: [Any] = []
        
        for i in 0..<keys.count {
            
            if i == keys.count - 1 {
                
            }
            else  {
                
                path.append(JSONXMLKEY.elements.string)
                path.append(JSON[path].array.count - 1)
            }
        }
        
        return path
    }
}

// 在 build phases -> Link Binary With Libraries中，点击 + 添加 libxml2.2.tbd
// 在 build setting -> Header Search Paths里添加 ${SDK_DIR}/usr/include/libxml2
// 使用时 添加 import libxml2

// MARK: - HTML文档

import libxml2

public class HTMLDocument {
    
    // MARK: Parameter
    
    /// 编码
    var encoding: String.Encoding = .utf8
    /// XML文档
    var xmlDocument: xmlDocPtr?
    
    // MARK: init
    
    public init(_ data: Data, encoding: String.Encoding = .utf8) {
        
        self.encoding = encoding
        
        var byte = [Int8].init(repeating: 0x0, count: data.count)
        (data as NSData).getBytes(&byte, length: byte.count)
        
        let encoding_CFStringEncoding = CFStringConvertNSStringEncodingToEncoding(String.Encoding.utf8.rawValue)
        
        if let encoding_CFString = CFStringConvertEncodingToIANACharSetName(encoding_CFStringEncoding) {
            
            let encoding = (encoding_CFString as NSString).utf8String
            
            let url = [Int8].init(repeating: 0x0, count: 0)
            
            self.xmlDocument = htmlReadMemory(byte, Int32(byte.count), url, encoding, Int32(HTML_PARSE_NOWARNING.rawValue | HTML_PARSE_NOERROR.rawValue))
            
            if self.xmlDocument != nil {
                
                self.addStringsCacheToDoc()
            }
            else {
                
                print("创建 xmlDocument 失败")
            }
        }
        else {
            
            print("编码错误")
        }
    }
    
    convenience public init(_ html: String, encoding: String.Encoding = .utf8) {
        
        self.init(html.data(using: encoding) ?? Data.init(), encoding: encoding)
    }
    
    /**
     添加字符串缓存到文档
     */
    public func addStringsCacheToDoc() {
        
        var valueCallBacks = kCFTypeDictionaryValueCallBacks
        
        let index: CFIndex = 0
        
        var keyCallBacks = CFDictionaryKeyCallBacks.init(version: 0, retain: { (allocator, str) -> UnsafeRawPointer? in
            
            if let str_UnsafePointer_xmlChar = str?.assumingMemoryBound(to: xmlChar.self) {
                
                let str_UnsafeMutablePointer_xmlChar = xmlStrdup(str_UnsafePointer_xmlChar)
                
                return UnsafeRawPointer.init(str_UnsafeMutablePointer_xmlChar)
            }
            
            return nil
            
        }, release: { (allocator, str) in
            
            let str_UnsafeMutableRawPointer = UnsafeMutableRawPointer.init(mutating: str)
            
            xmlFree(str_UnsafeMutableRawPointer)
            
        }, copyDescription: { (str) -> Unmanaged<CFString>? in
            
            var cfStr = CFStringCreateWithCString(kCFAllocatorDefault, str?.assumingMemoryBound(to: Int8.self), CFStringBuiltInEncodings.UTF8.rawValue)
            
            return Unmanaged<CFString>.fromOpaque(&cfStr)
            
        }, equal: { (str1, str2) -> DarwinBoolean in
            
            if str1 == str2 {
                
                return true
            }
            
            if let str1_UnsafePointer_xmlChar = str1?.assumingMemoryBound(to: xmlChar.self),
                let str2_UnsafePointer_xmlChar = str2?.assumingMemoryBound(to: xmlChar.self) {
                
                let result = xmlStrcmp(str1_UnsafePointer_xmlChar, str2_UnsafePointer_xmlChar)
                
                return (result == 0 ? true : false)
            }
            
            return false
            
        }) { (str) -> CFHashCode in
            
            var hash: CFHashCode = 5381
            
            if let chars = str?.assumingMemoryBound(to: CChar.self), let data = String.init(cString: chars).data(using: .utf8) {
                
                
                
                for i in data {
                    
                    if i == 0 {
                        
                        break
                    }
                    else {
                        
                        hash = ((hash << 5) + hash) + CFHashCode(i);
                    }
                }
            }
            
            return hash
        }
        
        var private_CFMutableDictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, index, &keyCallBacks, &valueCallBacks)
        
        self.xmlDocument?.pointee._private = UnsafeMutableRawPointer.init(mutating: &private_CFMutableDictionary)
    }
    
    /**
     XML数据
     */
    public func xmlData() -> Data {
        
        var data = Data()
        
        if self.xmlDocument != nil {
            
            var buffer: UnsafeMutablePointer<xmlChar>? = nil
            var bufferSize: Int32 = 0
            
            xmlDocDumpMemory(self.xmlDocument, &buffer, &bufferSize)
            
            if buffer != nil {
                
                data = Data.init(bytes: buffer!, count: Int(bufferSize))
                
                xmlFree(buffer)
                
                return data
            }
        }
        
        return Data()
    }
    
    /**
     XML字符串
     */
    public func xmlString() -> String {
        
        return String.init(data: self.xmlData(), encoding: .utf8) ?? ""
    }
}
