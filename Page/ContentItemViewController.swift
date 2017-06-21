//
//  ContentItemViewController.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/19.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class ContentItemViewController: UIViewController {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var dataObject: ContentItem?
    var pageTitle: String = ""
    var themeColor: String?
    fileprivate let contentAPI = ContentFetch()
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var toolBar: UIToolbar!

    override func viewDidLoad() {
        super.viewDidLoad()
        getDetailInfo()
        initStyle()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        initText()
        
    }
    
    func getDetailInfo() {
        let urlString = "https://m.ftimg.net/index.php/jsapi/get_story_more_info/001073043?20170521235700"
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        view.addSubview(activityIndicator)
        activityIndicator.frame = view.bounds
        activityIndicator.startAnimating()
        contentAPI.fetchContentForUrl(urlString) {
            results, error in
            
            activityIndicator.removeFromSuperview()
            
            if let error = error {
                // 2
                print("Error searching : \(error)")
                return
            }
            
            if let results = results {
                // 3
                //print("Found \(results.fetchResults.count) matching \(results.apiUrl)")
                // MARK: - Insert Ads into the fetch results
                
                //print("After inserting ads. now there are \(resultsWithAds.fetchResults.count) matching \(results.apiUrl)")
                //self.fetches = resultsWithAds
                
                
                // 4
                // self.collectionView?.reloadData()
            }
        }
    }
    
    func initStyle() {
        textView.backgroundColor = UIColor(hex: AppNavigation.sharedInstance.defaultContentBackgroundColor)
        toolBar.backgroundColor = UIColor(hex: AppNavigation.sharedInstance.defaultTabBackgroundColor)
        toolBar.barTintColor = UIColor(hex: AppNavigation.sharedInstance.defaultTabBackgroundColor)
        toolBar.isTranslucent = false
        //toolBar.barStyle = .black
        
        
    }
    
    func initText() {
        let finalText = NSMutableAttributedString()
    
        // MARK: headline
        let headlineStyle = NSMutableParagraphStyle()
        headlineStyle.paragraphSpacing = 12.0
        let headlineString = dataObject?.headline ?? ""
        let headline = NSAttributedString(string: "\(headlineString)\n", attributes: [NSParagraphStyleAttributeName: headlineStyle])
        
        
        // MARK: body
        let bodyStyle = NSMutableParagraphStyle()
        bodyStyle.paragraphSpacing = 12.0
        let bodyString = dataObject?.lead ?? ""
        let body = NSAttributedString(string: bodyString, attributes: [NSParagraphStyleAttributeName: bodyStyle])
        
        // MARK: the final text
        finalText.append(headline)
        finalText.append(body)
        
        textView.attributedText = finalText
        
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        
        // MARK: - a workaround for the myterious scroll view bug
        textView.isScrollEnabled = false
        textView.isScrollEnabled = true
        textView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
    }
    
    
}
