/*---------------------------------
 
 - Readit -
 
 created by FV iMAGINATION ©2016
 All Rights reserved
 
 -----------------------------------*/

import UIKit
import GoogleMobileAds
import AudioToolbox


class MiniBrowser: UIViewController,
UIWebViewDelegate,
GADBannerViewDelegate
{

    /* Views */
    @IBOutlet weak var webView: UIWebView!
    
    
    
    //Ad banners properties
    var adMobBannerView = GADBannerView()
    
    
    
    /* Variables */
    var urlString = ""
    
    
    

override func viewDidLoad() {
        super.viewDidLoad()

    // Sert Title
    self.title = "Loading..."
    
    // Load website
    showHUD()
    let url = URL(string: urlString)
    webView.loadRequest(URLRequest(url: url!))
    
    // CONSOLE LOGS:
    print("URL STRING: \(urlString)")

    
    // Initialize a BACK BarButton Item
    let butt = UIButton(type: .custom)
    butt.adjustsImageWhenHighlighted = false
    butt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
    butt.setBackgroundImage(UIImage(named: "backButt"), for: .normal)
    butt.addTarget(self, action: #selector(backButt(_:)), for: .touchUpInside)
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: butt)
    
    
    
    // Init ad banners
    initAdMobBanner()
    
}


    
// MARK: - WEBVIEW DELEGATE TO GET THE ARTICLE'S TITLE
func webViewDidFinishLoad(_ webView: UIWebView) {
    hideHUD()
    self.title = webView.stringByEvaluatingJavaScript(from: "document.title")
}
    
    
    
    
    
// MARK: - TOOLBAR BUTTONS
@IBAction func toolbarButtons(_ sender: AnyObject) {
    let butt = sender as! UIBarButtonItem
    
    switch butt.tag {
    
    // Go back
    case 0:
        webView.goBack()
    
    // Go next
    case 1:
        webView.goForward()
    
    // Refresh page
    case 2:
        webView.reload()
        
    // Share page
    case 3:
        let messageStr  = "Check this out: \(urlString) - from #\(APP_NAME)"
        let img = UIImage(named: "logo")
        let shareItems = [messageStr, img!] as [Any]
        
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.copyToPasteboard, UIActivityType.postToVimeo]
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            // iPad
            let popOver = UIPopoverController(contentViewController: activityViewController)
            popOver.present(from: CGRect.zero, in: self.view, permittedArrowDirections: UIPopoverArrowDirection(), animated: true)
        } else {
            // iPhone
            present(activityViewController, animated: true, completion: nil)
        }
        
        
    default:break }
    
}
    
    

    
    
// MARK: - BACK BUTTON
func backButt(_ sender: UIButton) {
    _ = navigationController?.popViewController(animated: true)
}

    
    
    
    

// MARK: - ADMOB BANNER METHODS
func initAdMobBanner() {
        adMobBannerView.adSize =  GADAdSizeFromCGSize(CGSize(width: 320, height: 50))
        adMobBannerView.frame = CGRect(x: 0, y: self.view.frame.size.height, width: 320, height: 50)
        adMobBannerView.adUnitID = ADMOB_BANNER_UNIT_ID
        adMobBannerView.rootViewController = self
        adMobBannerView.delegate = self
        view.addSubview(adMobBannerView)
        let request = GADRequest()
        adMobBannerView.load(request)
    }
    
    
    // Hide the banner
    func hideBanner(_ banner: UIView) {
        UIView.beginAnimations("hideBanner", context: nil)
        
        banner.frame = CGRect(x: 0, y: self.view.frame.size.height, width: banner.frame.size.width, height: banner.frame.size.height)
        UIView.commitAnimations()
        banner.isHidden = true
        
    }
    
    // Show the banner
    func showBanner(_ banner: UIView) {
        UIView.beginAnimations("showBanner", context: nil)
        
        // Move the banner on the bottom of the screen
        banner.frame = CGRect(x: 0, y: self.view.frame.size.height - banner.frame.size.height - 48,
            width: banner.frame.size.width, height: banner.frame.size.height);
        banner.center.x = view.center.x
        
        UIView.commitAnimations()
        banner.isHidden = false
        
    }
    
    // AdMob banner available
    func adViewDidReceiveAd(_ view: GADBannerView) {
        print("AdMob loaded!")
        showBanner(adMobBannerView)
    }
    
    // NO AdMob banner available
    func adView(_ view: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("AdMob Can't load ads right now, they'll be available later \n\(error)")
        hideBanner(adMobBannerView)
    }
    

    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
