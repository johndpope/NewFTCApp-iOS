//
//  DataViewController.swift
//  Page
//
//  Created by Oliver Zhang on 2017/6/9.
//  Copyright © 2017年 Oliver Zhang. All rights reserved.
//

import UIKit

class DataViewController: UICollectionViewController {
    fileprivate let reuseIdentifier = "ItemCell"
    
    //fileprivate let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    let columnNum: CGFloat = 1 //use number of columns instead of a static maximum cell width
    var cellWidth: CGFloat = 0
    
    
    fileprivate var fetches = ContentFetchResults(
        apiUrl: "",
        fetchResults: [ContentSection]()
    )
    fileprivate let contentAPI = ContentFetch()
    
    // MARK: - Once The dataObject is changed, UI should be updated
    var dataObject = [String: String]()
    var pageTitle: String = ""
    
    var pageContent = [String: Any]() {
        didSet {
            updateUI()
        }
    }
    
    
    
    private func getAPI(_ urlString: String) {
        // 1
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
                print("Found \(results.fetchResults.count) matching \(results.apiUrl)")
                //self.fetches.insert(results, at: 0)
                self.fetches = results
                
                
                // 4
                self.collectionView?.reloadData()
            }
        }
    }
    
    
    
    
    
    private func updateUI() {
        //print (pageContent)
    }
    
    private func requestNewContent() {
        // MARK: - Request Data from Server
        if let api = dataObject["api"] {
            // TODO: Display a spinner
            
            getAPI(api)
        } else {
            //TODO: Show a warning if there's no api to get
            
        }
        
        // TODO: Check if there's a local version of data
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
        // self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // MARK: - Get Content
        view.backgroundColor = UIColor(hex: AppNavigation.sharedInstance.defaultContentBackgroundColor)
        
        
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            
            //flowLayout.minimumLineSpacing = 30
            //flowLayout.sectionInset = sectionInsets
            //let spaceBetweenCells = flowLayout.minimumInteritemSpacing * (columnNum - 1)
            //let totalCellAvailableWidth = (collectionView?.frame.size.width)! - flowLayout.sectionInset.left - flowLayout.sectionInset.right - spaceBetweenCells
            let totalCellAvailableWidth = collectionView?.frame.size.width
            
            cellWidth = totalCellAvailableWidth! / columnNum
            
            print ("cell width is \(cellWidth)")
            //            if #available(iOS 10.0, *) {
            //                flowLayout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
            //            } else {
            //                flowLayout.estimatedItemSize = CGSize(width: 200, height: 200)
            //            }
        }
        
        
        if #available(iOS 10.0, *) {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(refreshControlDidFire(sender:)), for: .valueChanged)
            collectionView?.refreshControl = refreshControl
        }
        
        
        
        
        
        // MARK: - Get Content Data for the Page
        requestNewContent()
        
    }
    
    
    func refreshControlDidFire(sender:AnyObject) {
        print ("pull to refresh fired")
        // TODO: Handle Pull to Refresh
        requestNewContent()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return fetches.fetchResults.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return fetches.fetchResults[section].items.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        cell.backgroundColor = UIColor(hex: AppNavigation.sharedInstance.defaultContentBackgroundColor)
        
        // Configure the cell
        
        switch reuseIdentifier {
        case "ItemCell":
            if let cell = cell as? ItemCell {
                cell.cellWidth = cellWidth
                cell.itemCell = fetches.fetchResults[indexPath.section].items[indexPath.row]
                return cell
            }
        default: break
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */
    
}


// MARK: - Private
//private extension DataViewController {
//    func itemForIndexPath(indexPath: IndexPath) -> ContentItem {
//        return fetches[(indexPath as NSIndexPath).section].fetchResults[(indexPath as IndexPath).row]
//    }
//}



fileprivate let itemsPerRow: CGFloat = 3
fileprivate let sectionInsetsForPad = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)

extension DataViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        print ("sizeFor Item At called")
        let paddingSpace = sectionInsetsForPad.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        let heightPerItem: CGFloat
        heightPerItem = widthPerItem * 0.618
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsetsForPad
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsetsForPad.left
    }
}
