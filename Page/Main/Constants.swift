//
//  Style.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/22.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
import UIKit
struct Color {
    // Those nested structures are grouped mostly according to their functions
    struct Content {
        static let headline = "#000000"
        static let body = "#333333"
        static let lead = "#777777"
        static let border = "#e9decf"
        static let background = "#FFF1E0"
        static let tag = "#9E2F50"
        static let time = "#8b572a"
    }
    
    struct Tab {
        static let text = "#333333"
        static let normalText = "#555555"
        static let highlightedText = "#c0282e"
        static let border = "#d4c9bc"
        static let background = "#f7e9d8"
    }
    
    struct Button {
        static let tint = "#057b93"
    }
    
    struct Header {
        static let text = "#333333"
    }
    
    struct ChannelScroller {
        static let text = "#565656"
        static let highlightedText = "#c0282c"
        static let background = "#fff9f5"
        //static let background = "#e8dbcb"
        
        //static let background = "#FFFFFF"
        
    }
    
    struct Navigation {
        static let border = "#d5c6b3"
    }
    
    struct Ad {
        static let background = "#f6e9d8"
        static let sign = "#555555"
        static let signBackground = "#ecd4b4"
    }
    
}

struct FontSize {
    static let bodyExtraSize: CGFloat = 3.0
    static let padding: CGFloat = 14
}

// MARK: Different organization might use different way to construct API and urls
struct APIs {
    //private static let base = "https://m.ftimg.net/index.php/jsapi/"
    private static let domain = "https://d37m993yiqhccr.cloudfront.net/"
    private static let publicDomain = "http://app003.ftmailbox.com/"
    private static let webPageDomain = "http://www.ftchinese.com/"
    // MARK: the number of days you want to keep the cached files
    static let expireDay: TimeInterval = 7
    static let searchUrl = "http://app003.ftmailbox.com/search/"
    static func jsForSearch(_ keywords: String) -> String {
        return "search('\(keywords)');"
    }
    
    // MARK: the types of files that you want to clean from time to time
    static let expireFileTypes = ["json", "jpeg", "jpg", "png", "gif", "mp3", "mp4", "mov", "mpeg"]
    
    static func get(_ id: String, type: String) -> String {
        let urlString: String
        switch type {
        case "story": urlString = "\(domain)index.php/jsapi/get_story_more_info/\(id)"
        case "tag": urlString = "\(domain)\(type)/\(id)?type=json"
        case "follow":
            // TODO: Calculate the url string for follow
            let followTypes = Meta.map
            var parameterString = ""
            for followTypeArray in followTypes {
                if let followType = followTypeArray["key"] as? String {
                    let followKeywords = UserDefaults.standard.array(forKey: "follow \(followType)") as? [String] ?? [String]()
                    var keyStrings = ""
                    for (index, value) in followKeywords.enumerated() {
                        if index == 0 {
                            keyStrings += value
                        } else {
                            keyStrings += ",\(value)"
                        }
                    }
                    if keyStrings != "" {
                        parameterString += "&\(followType)=\(keyStrings)"
                    }
                }
            }
            parameterString = parameterString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? parameterString
            urlString = "\(domain)channel/china.html?type=json\(parameterString)"
            print ("follow request type: \(urlString)")
        default:
            urlString = "\(domain)index.php/jsapi/get_story_more_info/\(id)"
        }
        print ("api url is \(urlString)")
        return urlString
    }
    
    static func get(_ key: String, value: String) -> String {
        return "\(domain)channel/china.html?type=json&\(key)=\(value)"
    }
    
    static func getUrl(_ id: String, type: String) -> String {
        let urlString: String
        // MARK: Use different domains for different types of content
        switch type {
        // MARK: If there are http resources that you rely on in your page, don't use https as the url base
        case "video": urlString = "\(publicDomain)\(type)/\(id)?webview=ftcapp&002"
        case "interactive": urlString = "\(webPageDomain)\(type)/\(id)?webview=ftcapp&i=3&001"
        case "story": urlString = "\(publicDomain)/\(type)/\(id)?webview=ftcapp&full=y"
        case "photonews", "photo": urlString = "\(webPageDomain)photonews/\(id)?webview=ftcapp&i=3"
        case "register": urlString = "\(publicDomain)index.php/users/register?i=4&webview=ftcapp"
        default:
            urlString = "\(publicDomain)"
        }
        // print ("open in web view: \(urlString)")
        return urlString
    }
    
    
    
    static func newQueryForWebPage() -> URLQueryItem {
        return URLQueryItem(name: "webview", value: "ftcapp")
    }
}

struct ErrorMessages {
    struct NoInternet {
        static let en = "Dear reader, you are not connected to the Internet Now. Please connect and try again. "
        static let gb = "亲爱的读者，您现在没有连接互联网，也可能没有允许FT中文网连接互联网的权限，请检查连接和设置之后重试。"
        static let big5 = "親愛的讀者，您現在沒有連接互聯網，也可能沒有允許FT中文網連接互聯網的權限，請檢查連接和設置之後重試。"
    }
    struct Unknown {
        static let en = "Dear reader, you are not able to connect to our server now. Please try again later. "
        static let gb = "亲爱的读者，您现在无法连接FT中文网的服务器，请稍后重试。"
        static let big5 = "親愛的讀者，您現在無法連接FT中文網的服務器，請稍後重試。"
    }
}

struct Event {
    //    static func pagePanningEnd (for tab: String) -> String {
    //        let pagePanningEndName = "Page Panning End"
    //        return "\(pagePanningEndName) for \(tab)"
    //    }
    static let englishStatusChange = "English Status Change"
    static let languageSelected = "Language Selected in Story Page"
    static let languagePreferenceChanged = "Language Preference Changed By User Tap"
    static let newAdCreativeDownloaded = "New Ad Creative Downloaded"
    static func paidPostUpdate(for page: String) -> String {
        let paidPostUpdated = "Paid Post Update"
        return "\(paidPostUpdated) for \(page)"
    }
}

struct GA {
    static let trackingIds = ["UA-1608715-1", "UA-1608715-3"]
}

struct WeChat {
    // MARK: - wechat developer appid
    static let appId = "wxc1bc20ee7478536a"
    static let appSecret = "14999fe35546acc84ecdddab197ed0fd"
    static let accessTokenPrefix = "https://api.weixin.qq.com/sns/oauth2/access_token?"
    static let userInfoPrefix = "https://api.weixin.qq.com/sns/userinfo?"
}

struct Share {
    static let base = "http://www.ftchinese.com/"
    static let shareIconName = "ShareIcon.jpg"
    struct CampaignCode {
        static let wechat = "2G178002"
        static let actionsheet = "iosaction"
    }
}

struct Push {
    static let deviceTokenUrl = "https://noti.ftimg.net/iphone-collect.php"
}

struct AppGroup {
    static let name = "group.com.ft.ftchinese.mobile"
}

struct Key {
    static let languagePreference = "Language Preference"
    static let domainIndex = "Domain Index"
    static let searchHistory = "Search History"
}

// MARK: - Use a server side image service so that you can request images that are just large enough
struct ImageService {
    static func resize(_ imageUrl: String, width: Int, height: Int) -> String {
        return "https://www.ft.com/__origami/service/image/v2/images/raw/\(imageUrl)?source=ftchinese&width=\(width * 2)&height=\(height * 2)&fit=cover"
    }
}

struct LinkPattern {
    static let story = ["http[s]*://[a-z0-9A-Z]+.ft[chinesemailboxacademy]+.[comn]+/story/([0-9]+)"]
    static let interactive = ["http[s]*://[a-z0-9A-Z]+.ft[chinesemailboxacademy]+.[comn]+/interactive/([0-9]+)"]
    static let video = ["http[s]*://[a-z0-9A-Z]+.ft[chinesemailboxacademy]+.[comn]+/video/([0-9]+)"]
    static let photonews = ["http[s]*://[a-z0-9A-Z]+.ft[chinesemailboxacademy]+.[comn]+/photonews/([0-9]+)"]
    static let tag = ["http[s]*://[a-z0-9A-Z]+.ft[chinesemailboxacademy]+.[comn]+/tag/([^?]+)"]
    static let other = ["(http[s]*://[a-z0-9A-Z]+.ft[chinesemailboxacademy]+.[comn]+)"]
}

struct SupplementContent {
    static func insertContent(_ layout: String, to contentSections: [ContentSection]) -> [ContentSection] {
        var newContentSections = contentSections
        // MARK: It is possible that the JSON Format is broken. Check it here.
        if newContentSections.count < 1 {
            return newContentSections
        }
        switch layout {
        case "home":
            // MARK: Create link to the Microsoft AI chat bot
//            let xiaobingItem = ContentItem(id: "Id of the Chat Room", image: "http://i.ftimg.net/picture/0/000068460_piclink.jpg", headline: "微软的人工智能机器人小冰", lead: "微软小冰一直在探索新媒体领域的技术能力，试图通过实时对话和用户交流，实现新闻传播的效果", type: "ViewController", preferSponsorImage: "", tag: "AI", customLink: "", timeStamp: 0, section: 0, row: 0)
//            // MARK: Insert the chatbot post under paid post
//            if newContentSections.count > 0 && newContentSections[0].items.count > 2 {
//                newContentSections[0].items.insert(xiaobingItem, at:2)
//            }
            newContentSections = Content.updateSectionRowIndex(newContentSections)
            return newContentSections
        case "follows":
            let followTypes = Meta.map
            for followTypeArray in followTypes {
                if let followType = followTypeArray["key"] as? String
                {
                    var followKeywords = followTypeArray["meta"] as? [String: String] ?? [String: String]()
                    let followedKeywords = UserDefaults.standard.array(forKey: "follow \(followType)") as? [String] ?? [String]()
                    for key in followedKeywords {
                        if followKeywords[key] == nil {
                            followKeywords[key] = key
                        }
                    }
                    var items = [ContentItem]()
                    for (key, value) in followKeywords {
                        let item = ContentItem(
                            id: key,
                            image: "",
                            headline: value,
                            lead: "",
                            type: "follow",
                            preferSponsorImage: "",
                            tag: "",
                            customLink: "",
                            timeStamp: 0,
                            section: 0,
                            row: 0
                        )
                        item.followType = followType
                        items.append(item)
                    }
                    if items.count > 0 {
                        let newContentSection = ContentSection(
                            title: followTypeArray["name"] as? String ?? "",
                            items: items,
                            type: "List",
                            adid: nil
                        )
                        newContentSections.append(newContentSection)
                    }
                }
            }
            //print ("request type: \(newContentSections)")
            return newContentSections
        case "ipadhome":
            // MARK: - The first item in the first section should be marked as Cover
            newContentSections[0].items[0].isCover = true
            // MARK: - Break up the first section into two or more, depending on how you want to layout ads
            
            return newContentSections
        default:
            return newContentSections
        }
    }
}

struct Meta {
    static let map: [[String: Any]] = [
        ["key": "tag",
         "name": "标签"
        ],
        ["key": "topic",
         "name": "话题",
         "meta": [
            "markets": "金融市场",
            "management": "管理",
            "lifestyle": "生活时尚",
            "business": "商业"
            ]
        ],
        ["key": "area",
         "name": "地区",
         "meta": [
            "china": "中国",
            "us": "美国",
            "europe": "欧洲",
            "africa": "非洲"
            ]
        ],
        ["key": "industry",
         "name": "行业",
         "meta": [
            "technology": "科技",
            "media": "媒体"
            ]
        ],
        ["key": "author",
         "name": "作者"
        ],
        ["key": "column",
         "name": "栏目"
        ]
    ]
}


/*
 enum AppError : Error {
 case invalidResource(String, String)
 }
 */


//func setTimeout(_ delay:TimeInterval, block:@escaping ()->Void) -> Timer {
//    return Timer.scheduledTimer(timeInterval: delay, target: BlockOperation(block: block), selector: #selector(Operation.main), userInfo: nil, repeats: false)
//}
