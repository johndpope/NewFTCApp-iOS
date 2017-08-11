//
//  File.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/6.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import Foundation
struct AppNavigation {
    
    // MARK: - Use singleton pattern to pass speech data between view controllers.
    static let sharedInstance = AppNavigation()
    //https://m.ftimg.net/
    //https://danla2f5eudt1.cloudfront.net/
    
    private static let appMap = [
        "News": [
            "title": "FT中文网",
            "title-image":"FTC-Header",
            "navColor": "#333333",
            "navBackGroundColor": "#f7e9d8",
            "isNavLightContent": false,
            "Channels": [
                ["title": "首页",
                 "api":"https://m.ftimg.net/index.php/jsapi/home",
                 "url":"http://www.ftchinese.com/",
                 "screenName":"homepage",
                 "Insert Content": "home"
                ],
                ["title": "中国",
                 "api":"https://m.ftimg.net/channel/china.html?type=json",
                 "url":"http://www.ftchinese.com/channel/china.html",
                 "compactLayout": "Simple Headline",
                 "regularLayout": "",
                 "screenName":"homepage/china"
                ],
                ["title": "全球",
                 "api":"https://m.ftimg.net/channel/world.html?type=json",
                 "url":"http://www.ftchinese.com/channel/world.html",
                 "screenName":"homepage/world"
                ],
                ["title": "金融市场",
                 "api":"https://m.ftimg.net/channel/markets.html?type=json",
                 "url":"http://www.ftchinese.com/channel/markets.html",
                 "screenName":"homepage/markets"
                ],
                ["title": "管理",
                 "api":"https://m.ftimg.net/channel/management.html?type=json",
                 "url":"http://www.ftchinese.com/channel/management.html",
                 "screenName":"homepage/management"
                ],
                ["title": "生活时尚",
                 "api":"https://m.ftimg.net/channel/lifestyle.html?type=json",
                 "url":"http://www.ftchinese.com/channel/lifestyle.html",
                 "screenName":"homepage/lifestyle"
                ],
                ["title": "专栏",
                 "api":"https://m.ftimg.net/channel/column.html?type=json",
                 "url":"http://www.ftchinese.com/channel/column.html",
                 "screenName":"homepage/column"
                ],
                ["title": "热门文章",
                 "api":"https://m.ftimg.net/channel/weekly.html?type=json",
                 "url":"http://www.ftchinese.com/channel/weekly.html",
                 "compactLayout": "Simple Headline",
                 "regularLayout": "",
                 "screenName":"homepage/mostpopular"
                ],
                ["title": "数据新闻",
                 "api":"https://m.ftimg.net/channel/datanews.html?type=json",
                 "url":"http://www.ftchinese.com/channel/datanews.html",
                 "screenName":"homepage/datanews"
                ],
                ["title": "FTCC",
                 "api":"https://m.ftimg.net/index.php/jsapi/publish/ftcc",
                 "compactLayout": "All Cover",
                 "regularLayout": "",
                 "url":"http://www.ftchinese.com/channel/datanews.html",
                 "screenName":"homepage/ftcc"
                ]
            ]
        ],
        "English": [
            "title": "每日英语",
            "navColor": "#FFFFFF",
            "navBackGroundColor": "#a84358",
            "isNavLightContent": true,
            "Channels": [
                ["title": "最新",
                 "api":"https://m.ftimg.net/index.php/jsapi/publish/test2",
                 "url":"http://www.ftchinese.com/channel/english.html",
                 "screenName":"english"
                ],
                ["title": "英语电台",
                 "api":"https://m.ftimg.net/channel/radio.html?type=json",
                 "url":"http://www.ftchinese.com/channel/radio.html",
                 "screenName":"english/radio"
                ],
                ["title": "双语阅读",
                 "api":"https://m.ftimg.net/channel/ce.html?type=json",
                 "url":"http://www.ftchinese.com/channel/ce.html",
                 "screenName":"english/read"
                ],
                ["title": "金融英语速读",
                 "api":"https://m.ftimg.net/channel/speedread.html?type=json",
                 "url":"http://www.ftchinese.com/channel/speedread.html",
                 "screenName":"english/speedread"
                ],
                ["title": "原声视频",
                 "api":"https://m.ftimg.net/channel/ev.html?type=json",
                 "url":"http://www.ftchinese.com/channel/ev.html",
                 "screenName":"english/video"
                ]
            ]
        ],
        "Academy": [
            "title": "FT商学院",
            "navColor": "#FFFFFF",
            "navBackGroundColor": "#057b93",
            "isNavLightContent": true,
            "Channels": [
                ["title": "最新",
                 "api":"https://m.ftimg.net/channel/mba.html?type=json",
                 "url":"http://www.ftchinese.com/channel/mba.html",
                 "screenName":"ftacademy"
                ],
                ["title": "热点观察",
                 "api":"https://m.ftimg.net/channel/mba.html?type=json",
                 "url":"http://www.ftchinese.com/channel/mba.html",
                 "screenName":"ftacademy/hottopic"
                ],
                ["title": "MBA训练营",
                 "api":"https://m.ftimg.net/channel/mbagym.html?type=json",
                 "url":"http://www.ftchinese.com/channel/mbagym.html",
                 "screenName":"ftacademy/mbagym"
                ],
                ["title": "互动小测",
                 "api":"https://m.ftimg.net/channel/mba.html?type=json",
                 "url":"http://www.ftchinese.com/channel/mba.html",
                 "screenName":"ftacademy/quiz"
                ],
                ["title": "深度阅读",
                 "api":"https://m.ftimg.net/channel/mba.html?type=json",
                 "url":"http://www.ftchinese.com/channel/mba.html",
                 "screenName":"ftacademy/read"
                ]
            ]
        ],
        "Video": [
            "title": "视频",
            "navColor": "#FFFFFF",
            "navBackGroundColor": "#008280",
            "isNavLightContent": true,
            "Channels": [
                ["title": "最新",
                 "api":"https://m.ftimg.net/channel/stream.html?type=json",
                 "url":"http://www.ftchinese.com/channel/stream.html",
                 "screenName":"video"
                ],
                ["title": "商业",
                 "api":"https://m.ftimg.net/channel/business.html?type=json",
                 "url":"http://www.ftchinese.com/channel/business.html",
                 "screenName":"ftacademy/business"
                ],
                ["title": "政经",
                 "api":"https://m.ftimg.net/channel/vpolitics.html?type=json",
                 "url":"http://www.ftchinese.com/channel/vpolitics.html",
                 "screenName":"ftacademy/politics"
                ],
                ["title": "有色眼镜",
                 "api":"https://m.ftimg.net/channel/videotinted.html?type=json",
                 "url":"http://www.ftchinese.com/channel/videotinted.html",
                 "screenName":"ftacademy/tinted"
                ]
            ]
        ],
        "MyFT": [
            "title": "我的FT",
            "navColor": "#FFFFFF",
            "navBackGroundColor": "#5a8caf",
            "isNavLightContent": true,
            "Channels": [
                ["title": "最新",
                 "api":"https://m.ftimg.net/users/mystories?type=json",
                 "url":"http://www.ftchinese.com/users/mystories",
                 "screenName":"myft"
                ],
                ["title": "阅读偏好",
                 "api":"https://m.ftimg.net/users/mytopics?type=json",
                 "url":"http://www.ftchinese.com/users/mytopics",
                 "screenName":"myft/preference"
                ],
                ["title": "订阅",
                 "api":"https://m.ftimg.net/users/favstorylist?type=json",
                 "url":"http://www.ftchinese.com/users/favstorylist",
                 "screenName":"myft/subscription"
                ],
                ["title": "账号",
                 "api":"https://m.ftimg.net/users/discover?type=json",
                 "url":"http://www.ftchinese.com/users/discover",
                 "screenName":"myft/account"
                ]
            ]
        ]
    ]
    
    
    public static func getNavigation(for tabName: String) -> [String]? {
        if let currentNavigation = appMap[tabName]?["Channels"] as? [String] {
            return currentNavigation
        }
        return nil
    }
    
    public static func getNavigationProperty(for tabName: String, of property: String) -> String? {
        if let p = appMap[tabName]?[property] as? String {
            return p
        }
        return nil
    }
    
    public static func isNavigationPropertyTrue(for tabName: String, of property: String) -> Bool {
        if let p = appMap[tabName]?[property] as? Bool {
            return p
        }
        return false
    }
    
    public static func getNavigationPropertyData(for tabName: String, of property: String) -> [[String: String]]? {
        if let p = appMap[tabName]?[property] as? [[String: String]] {
            return p
        }
        return nil
    }
    
    public static func getThemeColor(for tabName: String?) -> UIColor {
        let themeColor: UIColor
        if let tabName = tabName,
            let tabBackGroundColor = getNavigationProperty(for: tabName, of: "navBackGroundColor") {
            let isNavLightContent = isNavigationPropertyTrue(for: tabName, of: "isNavLightContent")
            if isNavLightContent == true {
                themeColor = UIColor(hex: tabBackGroundColor)
            } else {
                themeColor = UIColor(hex: Color.Tab.highlightedText)
            }
        } else {
            themeColor = UIColor(hex: Color.Tab.highlightedText)
        }
        return themeColor
    }

}