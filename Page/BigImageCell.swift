//
//  CoverCell.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/14.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

import UIKit

class BigImageCell: UICollectionViewCell {
    
    // MARK: - Style settings for this class
    let imageWidth = 408   // 16 * 52
    let imageHeight = 234  // 9 * 52
    

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headline: UILabel!
    @IBOutlet weak var lead: UILabel!
    @IBOutlet weak var containerViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var headlineLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var headlineTrailingConstraint: NSLayoutConstraint!
    
    // MARK: - Cell width set by collection view controller
    var cellWidth: CGFloat?
    var itemCell: ContentItem? {
        didSet {
            updateUI()
        }
    }
    
    
    // MARK: Use the data source to update UI for the cell. This is unique for different types of cell.
    func updateUI() {
        

        
        // MARK: - Update Styles and Layouts
        containerView.backgroundColor = UIColor(hex: Color.Content.background)
        headline.textColor = UIColor(hex: Color.Content.headline)
        headline.font = headline.font.bold()
        
        lead.textColor = UIColor(hex: Color.Content.lead)
        layoutMargins.left = 0
        layoutMargins.right = 0
        layoutMargins.top = 0
        layoutMargins.bottom = 0
        containerView.layoutMargins.left = 0
        containerView.layoutMargins.right = 0
        
        
        // MARK: - Use calculated cell width to diplay auto-sizing cells
        let cellMargins = layoutMargins.left + layoutMargins.right
        let containerViewMargins = containerView.layoutMargins.left + containerView.layoutMargins.right
        let headlineActualWidth: CGFloat?
        if let cellWidth = cellWidth {
            self.contentView.translatesAutoresizingMaskIntoConstraints = false
            let containerWidth = cellWidth - cellMargins - containerViewMargins
            containerViewWidthConstraint.constant = containerWidth
            let headlineLeading = headlineLeadingConstraint.constant
            let headlineTrailing = headlineTrailingConstraint.constant
            headlineActualWidth = containerWidth - headlineLeading - headlineTrailing
        } else {
            headlineActualWidth = nil
        }
        
        
        // MARK: - Update dispay of the cell
        let headlineString = itemCell?.headline.replacingOccurrences(of: "\\s*$", with: "", options: .regularExpression)
//        let headlineString: String?
//        headlineString = "南五环边上学梦：北京首所打工子弟"
        headline.text = headlineString
        
        // MARK: - Prevent widows in the second line
        if let headlineActualWidth = headlineActualWidth {
        if headline.hasWidowInSecondLine(headlineActualWidth) == true {
            headline.numberOfLines = 1
        }
        }
        
        lead.text = itemCell?.lead.replacingOccurrences(of: "\\s*$", with: "", options: .regularExpression)
        
        // MARK: - Load the image of the item
        imageView.backgroundColor = UIColor(hex: Color.Tab.background)
        if let loadedImage = itemCell?.coverImage {
            imageView.image = loadedImage
            //print ("image is already loaded, no need to download again. ")
        } else {
            itemCell?.loadImage(type:"cover", width: imageWidth, height: imageHeight, completion: { [weak self](cellContentItem, error) in
                self?.imageView.image = cellContentItem.coverImage
            })
            //print ("should load image here")
        }
        

        
    }
    
}