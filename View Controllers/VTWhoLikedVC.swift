//
//  VTWhoLikedVC.swift
//  VirTry
//
//  Created by Puneet Rao on 24/12/16.
//  Copyright © 2016 Geeks. All rights reserved.
//

import UIKit

class VTWhoLikedVC: VTViewControllerBaseClass, UITableViewDelegate, UITableViewDataSource {
    
    /* This corresponds to the table view showing the users */
    @IBOutlet weak var whoLikedTableView: UITableView!
    /* This corresponds title in the navigation bar */
    @IBOutlet weak var lblViewTitle: UILabel!
    
    /* This corresponds to the array which holds the user list */
    var arrWhoLiked: NSMutableArray = []
    /* This corresponds to the access token */
    var strAccessToken: String  = ""
    /* This corresponds to the selected gallery id */
    var strGalleryId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Title Label
        lblViewTitle.text = NSLocalizedString("title_wholike", comment: "")
        
        
        //UserData if available
        if(PersistentManager.isKeyAvailableInDefaults(defaultsKey: KEY.UDUSER))
        {
            let userDataDict:NSDictionary = PersistentManager.getDictForKeyFromDefault(defaultsKey: KEY.UDUSER)
            strAccessToken = userDataDict.value(forKey: KEY.ACCESS_TOKEN) as! String
        }
        
        //Hit the who liked API to fetch users
        hitWhoLikedAPI(strGalleryId: strGalleryId)

        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //Setting up fonts for Title label
        lblViewTitle.font = UIFont(name: "ArialRoundedMTBold", size: 21 * kScreenSizeRatioForFontSize)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        URLCache.shared.removeAllCachedResponses()
    }

    
    func hitWhoLikedAPI(strGalleryId: String)
    {
        //Hit Who Liked API
        
        if(!APIManager.sharedInstance.hasConnectivity())
        {
            UIUtil.showToast(strMessage: NSLocalizedString("no_internet_message", comment: "Message for no internet"))
        }
        else
        {
            //Parameters
            arrWhoLiked = []
            var param: [String : Any] = [:]
            param[KEY.ACCESS_TOKEN] = strAccessToken
            param[KEY.GALLERY_ID] = strGalleryId
            param[KEY.LANGUAGE] = PersistentManager.valueforKeyInDefaults(defaultsKey: KEY.LANGUAGE)
            
            print(param)
            
            //API
            APIManager.sharedInstance.postRequest(urlString: API.GALLERYWHOLIKED, loaderString: "", paramDict: param, showHud: true, target: self, completionHandler: { (result, error) in
                if (error == nil)
                {
                    print(result!)
                    let status = (result!.value(forKey: "status") as! NSNumber)
                    
                    switch(status)
                    {
                    case 0:
                        UIUtil.alertView(title: NSLocalizedString("error", comment: ""), body: (result!.value(forKey: "message") as! String))
                        
                        break
                    case 1:
                        APIManager.sharedInstance.handleWhoLikedAPIData(responseFromAPIDict: result!, view: self, arr: self.arrWhoLiked)
                        print(self.arrWhoLiked.count)
                        DispatchQueue.main.async {
                            self.whoLikedTableView.reloadData()
                        }
                        break
                    default:
                        
                        break
                        
                    }
                    
                    
                    
                    
                }else{
                    print(error?.description as Any)
                    UIUtil.showToast(strMessage: NSLocalizedString("msg_loading_failed", comment: ""))
                }
            })
            
        }
    }
    
    
    
    
    // MARK: - Table View DataSource and Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (self.view.layer.frame.height / 667) * 58
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrWhoLiked.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Cell
        let cellWhoLiked = tableView.dequeueReusableCell(withIdentifier: "WhoLikedCell") as! WhoLikedCell
        
        let objWhoLiked = arrWhoLiked[indexPath.row] as! WhoLikedModelClass
        
        //Showing data on the cell
        cellWhoLiked.lblusername.font = UIFont(name: "ArialRoundedMTBold", size: 17 * kScreenSizeRatioForFontSize)
        
        cellWhoLiked.lblusername.text = objWhoLiked.strUserName
        
        delay(time: 0.02, closure: {
            UIUtil.setCornerRadius(view: cellWhoLiked.imgViewUser, divideBy: 2)

        })
        
        cellWhoLiked.imgViewUser.kf.setImage(with: URL(string: objWhoLiked.strUserImgUrl))
        
        
        return cellWhoLiked
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Moving to user profile screen
        let storyboardMyProfile = UIStoryboard(name: "MyProfile", bundle: nil)
        let objWhoLiked = arrWhoLiked[indexPath.row] as! WhoLikedModelClass
        let userInfoVC: VTUserProfileVC = storyboardMyProfile.instantiateViewController(withIdentifier: "VTUserProfileVC") as! VTUserProfileVC
        userInfoVC.strAccessToken = strAccessToken
        userInfoVC.strUserId = objWhoLiked.strUserId
        self.navigationController?.pushViewController(userInfoVC, animated: true)
        
    }
    

    
    
    @IBAction func backBtnClkd(_ sender: UIButton)
    {
        _ = self.navigationController?.popViewController(animated: true)
    }
    

}
