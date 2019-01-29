//
//  VTHorizontalScrollVC.swift
//  VirTry
//
//  Created by Puneet Rao on 10/02/17.
//  Copyright © 2017 Geeks. All rights reserved.
//

import UIKit
//import UPCarouselFlowLayout

class VTHorizontalScrollVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    /* This corresponds to the collection view showing the products */
    @IBOutlet weak var collectionView: UICollectionView!
    
    /* This array holds the models */
    var arrModels: NSMutableArray = []
    

    
    /* This corresponds to the current selected model */
    fileprivate var currentPage: Int = 0 {
        didSet {
            if(currentPage < self.arrModels.count) {
                let prodObj = arrModels[self.currentPage] as! ProductModelClass
                //            //            print(prodObj.strUrlKey)
                (self.parent as! VTMainVC).strProductIdForInfo = prodObj.intProductId
            }
            
        }
    }
    
    /* This corresponds to the page size */
    fileprivate var pageSize: CGSize {
        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
        var pageSize = layout.itemSize
        if layout.scrollDirection == .horizontal {
            pageSize.width += layout.minimumLineSpacing
        } else {
            pageSize.height += layout.minimumLineSpacing
        }
        return pageSize
    }
    
    /* This corresponds API related variables */
    var intCurrentPage: Int = 1
    var intTotalPages: Double = 0.0
    var isAPIRunning: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setting the collection view layout
        let layout = UPCarouselFlowLayout()
        layout.itemSize = CGSize(width: width, height: width)
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(self.collectionView.frame.debugDescription)
    }
    
    //This methods initializes the model array and shows the models on collection view
    func methodInitializeModels(arr: NSMutableArray)
    {
        self.arrModels = arr
        self.collectionView.reloadData()
    }
    
    
    
    
    // MARK: Collection View DataSource and Delegates
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //Gallery Cell
        let galleryCell = collectionView.dequeueReusableCell(withReuseIdentifier: "horCell", for: indexPath) as! HorScrollCell

        //Product Object
        let prodObj = arrModels[indexPath.row] as! ProductModelClass

        //Showing product image
        galleryCell.imgVideoView.kf.indicatorType = .activity
        galleryCell.imgVideoView.kf.setImage(with: URL(string: prodObj.imgUrlProduct))
        galleryCell.imgVideoView.layer.cornerRadius = galleryCell.imgVideoView.frame.size.height / 2
        galleryCell.imgVideoView.clipsToBounds = true
        
        return galleryCell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        //Product Object
        let prodObj = arrModels[indexPath.row] as! ProductModelClass
        //Setting the global product id
        strSelectedProductId = prodObj.intProductId
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        
        //Getting the current visible page
        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
        let pageSide = (layout.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
        let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
        currentPage = Int(floor((offset - pageSide / 2) / pageSide) + 1)
        
        //Hit API for loading more products
        if(isFilterFromSearch || isFilterFromGrid) {
            if(isAPIRunning)
            {
                return
            }
            
            if(!APIManager.sharedInstance.hasConnectivity())
            {
                UIUtil.showToast(strMessage: NSLocalizedString("no_internet_message", comment: "Message for no internet"))
                return
            }
            
            if(isFilterFromSearch) {
                
                if(searchPersistanceModel.currentPage! >= Int(searchPersistanceModel.pageCount!)) {
                    return
                }
                
                searchPersistanceModel.currentPage = searchPersistanceModel.currentPage! + 1
                (self.parent as! VTMainVC).hit3DModelAPI(pageNo: searchPersistanceModel.currentPage!, completionHandler: { (success) in
                    self.isAPIRunning = false
                    if(success)
                    {
                        self.arrModels = (self.parent as! VTMainVC).arrModels
                        print(self.arrModels.count)
                        self.collectionView.reloadData()
                        searchPersistanceModel.arrProducts = self.arrModels
                    }else{
                        searchPersistanceModel.currentPage = searchPersistanceModel.currentPage! - 1
                    }
                    
                })
            }else{
                
                if(((self.parent as! VTMainVC).children[6] as! VTModelGridVC).currentPage >= Int(((self.parent as! VTMainVC).children[6] as! VTModelGridVC).pageCount))
                {
                    return
                }
                
                
                ((self.parent as! VTMainVC).children[6] as! VTModelGridVC).currentPage = ((self.parent as! VTMainVC).children[6] as! VTModelGridVC).currentPage + 1
                
                (self.parent as! VTMainVC).hit3DModelAPI(pageNo: ((self.parent as! VTMainVC).children[6] as! VTModelGridVC).currentPage, completionHandler: { (success) in
                    self.isAPIRunning = false
                    if(success)
                    {
                        self.arrModels = (self.parent as! VTMainVC).arrModels
                        print(self.arrModels.count)
                        self.collectionView.reloadData()
                        ((self.parent as! VTMainVC).children[6] as! VTModelGridVC).arrModels = self.arrModels
                    }else{
                        ((self.parent as! VTMainVC).children[6] as! VTModelGridVC).currentPage = ((self.parent as! VTMainVC).children[6] as! VTModelGridVC).currentPage - 1
                    }
                    
                })
            }
            
            return
        }

    }
    
}

