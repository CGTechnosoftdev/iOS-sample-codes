//
//  VTGalleryVC.swift
//  VirTry
//
//  Created by Puneet Rao on 14/12/16.
//  Copyright © 2016 Geeks. All rights reserved.
//

import UIKit
import WebKit



class VTGalleryVC: VTViewControllerBaseClass {
    
    // MARK: IBOutlets
    
    /* This corresponds to the Top view below the navigation bar */
    @IBOutlet weak var viewTop: UIView!
    /* This corresponds to the Login view */
    @IBOutlet weak var viewLogin: UIView!
    /* This corresponds to the Blur view convering the screen */
    @IBOutlet weak var viewBlur: UIView!
    /* This corresponds to the button which closes the Login popup */
    @IBOutlet weak var btnLoginClose: UIButton!
    /* This corresponds to the navigation bar title */
    @IBOutlet weak var lblViewTitle: UILabel!
    /* This corresponds to Gradient Image at the top */
    @IBOutlet weak var imgGradient: UIImageView!
    /* This corresponds to web view which loads the images grid */
    @IBOutlet weak var webview: UIWebView!
    
    
    
    // MARK: Variable Declaration
    var arrGallery: NSMutableArray = []
    var currentPage: Int = 1
    var pageCount: Double = 0.0
    var isAPIRunning: Bool = false


    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Initial Setup
        viewLogin.isHidden = true
        btnLoginClose.isHidden = true
        
        //Localization
        lblViewTitle.text = NSLocalizedString("title_gallery", comment: "")
        
        //Gradient ImageView
        self.imgGradient.isHidden = true
        
        //UserData if available
        if(PersistentManager.isKeyAvailableInDefaults(defaultsKey: KEY.UDUSER)) {
            let userDataDict:NSDictionary = PersistentManager.getDictForKeyFromDefault(defaultsKey: KEY.UDUSER)
            strAccessToken = userDataDict.value(forKey: KEY.ACCESS_TOKEN) as! String
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        URLCache.shared.removeAllCachedResponses()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        //Incase user has logged-in
        NotificationCenter.default.addObserver(self, selector:  #selector(VTMainVC.methodUserHasSignIn), name: NSNotification.Name(rawValue: "NCUserHasSignIn"), object: nil)
        
    
        //Loading the webview with tweet web page
        webview = UIWebView(frame: webview.frame)
        webview.delegate = self
        let htmlFile = Bundle.main.path(forResource: "tweet", ofType: "html")
        do {
            let html = try String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
            webview.loadHTMLString(html, baseURL: nil)
        } catch {
            print(error)
        }
        
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "NCUserHasSignIn"), object: nil)
        
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
        lblViewTitle.font = UIFont(name: "ArialRoundedMTBold", size: 20 * kScreenSizeRatioForFontSize)
    }
    
    
    
    // MARK: Helper Methods

    func delay(time: Double, closure:@escaping ()->())
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: {
            closure()
        })
    }

    // MARK: IBActions

    @IBAction func backBtnClkd(_ sender: UIButton) {
        if(webview.canGoBack) {
            webview.goBack()
        }else{
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func closeLoginViewBtnClkd(_ sender: UIButton)
    {
        viewLogin.isHidden = true
        btnLoginClose.isHidden = true

    }
    

    
}



extension VTGalleryVC: UIWebViewDelegate {
    func webViewDidStartLoad(_ webView: UIWebView) {
        print("Start")
        APIManager.sharedInstance.showHUD(title: "")
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("Finish")
        APIManager.sharedInstance.hideHUD()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print("Error")
        APIManager.sharedInstance.hideHUD()
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        print("Loading")
        return true
    }

}

