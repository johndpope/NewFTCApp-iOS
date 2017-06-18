//
//  RootViewController.swift
//  Page
//
//  Created by Oliver Zhang on 2017/5/8.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit
// MARK: - Channel View Controller is for Channel Pages with a horizontal navigation collection view at the top of the page
class ChannelViewController: PagesViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    
    //private var channelScroller: UICollectionView = UICollectionView()
    private let channelScrollerHeight: CGFloat = 40
    var pageData:[[String : String]] = []
    var channelScrollerView: UICollectionView?
    
    var currentChannelIndex: Int = 0 {
        didSet {
            if currentChannelIndex != oldValue {
                print ("page index changed to \(String(describing: currentChannelIndex))")
                channelScrollerView?.reloadData()
                // MARK: - add "view.layoutIfNeeded()" before implementing scrollToItem method
                view.layoutIfNeeded()
                channelScrollerView?.scrollToItem(
                    at: IndexPath(row: currentChannelIndex, section: 0),
                    at: .centeredHorizontally,
                    animated: true
                )
                print ("scrolled to item at index \(currentChannelIndex)")
                let currentViewController: DataViewController = self.modelController.viewControllerAtIndex(currentChannelIndex, storyboard: self.storyboard!)!
                let viewControllers = [currentViewController]
                let direction: UIPageViewControllerNavigationDirection
                if currentChannelIndex>oldValue {
                    direction = .forward
                } else {
                    direction = .reverse
                }
                self.pageViewController!.setViewControllers(viewControllers, direction: direction, animated: true, completion: {done in })
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
        let fullPageViewRect = self.view.bounds
        let pageViewRect = CGRect(x: 0, y: channelScrollerHeight, width: fullPageViewRect.width, height: fullPageViewRect.height - channelScrollerHeight)
        self.pageViewController!.view.frame = pageViewRect
        
        // MARK: - Add channelScroller
        let channelScrollerRect = CGRect(x: 0, y: 0, width: fullPageViewRect.width, height: channelScrollerHeight)
        let flowLayout = UICollectionViewFlowLayout()
        channelScrollerView = UICollectionView(frame: channelScrollerRect, collectionViewLayout: flowLayout)
        channelScrollerView?.register(UINib.init(nibName: "ChannelScrollerCell", bundle: nil), forCellWithReuseIdentifier: "ChannelScrollerCell")
        //collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "collectionCell")
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.estimatedItemSize = CGSize(width: 50, height: channelScrollerHeight)
        // flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        channelScrollerView?.delegate = self
        channelScrollerView?.dataSource = self
        channelScrollerView?.backgroundColor = UIColor.white
        channelScrollerView?.showsHorizontalScrollIndicator = false
        //channelScrollerView.backgroundColor = UIColor(hex: AppNavigation.sharedInstance.defaultTabBackgroundColor)
        if let channelScrollerView = channelScrollerView {
            self.view.addSubview(channelScrollerView)
        }
        
        // MARK: - Get Channels Data as the Data Source
        if let currentTabName = tabName,
            let p = AppNavigation.sharedInstance.getNavigationPropertyData(for: currentTabName, of: "Channels" ) {
            pageData = p
        }
        
        // MARK: - Observing notification about page panning end
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(pagePanningEnd(_:)),
            name: NSNotification.Name(rawValue: AppNavigation.sharedInstance.pagePanningEndNotification),
            object: nil
        )
    }
    
    deinit {
        // MARK: - Remove Panning End Observer
        NotificationCenter.default.removeObserver(
            self,
            name: Notification.Name(rawValue: AppNavigation.sharedInstance.pagePanningEndNotification),
            object: nil
        )
        print ("panning oberser removed")
    }
    
    func pagePanningEnd(_ notification: Notification) {
        if let object = notification.object as? (index: Array.Index, title: String) {
            if let index = object.index as? Int {
                print ("panning to \(object.title): \(index)")
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return pageData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChannelScrollerCell", for: indexPath as IndexPath)
        if let cell = cell as? ChannelScrollerCell {
            //cell.cellHeight.constant = channelScrollerHeight
            if indexPath.row == currentChannelIndex {
                cell.isSelected = true
            } else {
                cell.isSelected = false
            }
            cell.pageData = pageData[indexPath.row]
            return cell
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: channelScrollerHeight)
    }
    
    func jumptoPage(_ index : Int) {
        //        let vc: DataViewController = self.modelController.viewControllerAtIndex(index, storyboard: self.storyboard!)!
        //
        //        let direction : UIPageViewControllerNavigationDirection!
        //
        //        if currentChannelIndex < index {
        //            direction = UIPageViewControllerNavigationDirection.forward
        //        }
        //        else {
        //            direction = UIPageViewControllerNavigationDirection.reverse
        //        }
        //
        //        if (currentChannelIndex < index) {
        //            for i in (0..<index) {
        //                if (i == index) {
        //                    self.pageViewController!.setViewControllers([vc], direction: direction, animated: true, completion: nil)
        //                } else {
        //                    self.pageViewController!.setViewControllers([self.modelController.viewControllerAtIndex(i, storyboard: self.storyboard!)!], direction: direction, animated: false, completion: nil)
        //                }
        //            }
        //        } else {
        //            for i in (index...currentChannelIndex) {
        //                if i == index {
        //                    self.pageViewController!.setViewControllers([vc], direction: direction, animated: true, completion: nil)
        //                } else {
        //                    self.pageViewController!.setViewControllers([self.modelController.viewControllerAtIndex(i, storyboard: self.storyboard!)!], direction: direction, animated: false, completion: nil)
        //                }
        //            }
        //        }
        
        //let currentViewController = self.pageViewController!.viewControllers![index]
        
    }
    
}

extension ChannelViewController {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        currentChannelIndex = indexPath.row
        return false
    }
}
