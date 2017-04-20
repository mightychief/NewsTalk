/*---------------------------------
 
 - Readit -
 
 created by FV iMAGINATION ©2016
 All Rights reserved
 
 -----------------------------------*/

import UIKit
import Parse
import GoogleMobileAds
import AudioToolbox


class Account: UIViewController,
UIAlertViewDelegate,
UITableViewDelegate,
UITableViewDataSource,
GADBannerViewDelegate
{

    /* Views */
    @IBOutlet weak var newsTableView: UITableView!
    @IBOutlet weak var segControl: UISegmentedControl!
    
    //Ad banners properties
    var adMobBannerView = GADBannerView()
    
    
    
    
    /* Variables */
    var newsArray = [PFObject]()
    
    
    

override func viewDidLoad() {
        super.viewDidLoad()

    // Layouts
    segControl.selectedSegmentIndex = 0
    newsTableView.contentInset = UIEdgeInsetsMake(-50, 0, 0, 0)
    self.title = "\(PFUser.current()!.username!)"
    
    
    // Initialize a LOGOUT BarButton Item (If you're the Current User)
    let butt = UIButton(type: .custom)
    butt.adjustsImageWhenHighlighted = false
    butt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
    butt.setBackgroundImage(UIImage(named: "logoutButt"), for: .normal)
    butt.addTarget(self, action: #selector(logoutButt(_:)), for: .touchUpInside)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: butt)
    
    // Initialize a BACK BarButton Item
    let backbutt = UIButton(type: .custom)
    backbutt.adjustsImageWhenHighlighted = false
    backbutt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
    backbutt.setBackgroundImage(UIImage(named: "backButt"), for: .normal)
    backbutt.addTarget(self, action: #selector(backButton), for: .touchUpInside)
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backbutt)
    
    
    // Init ad banners
    initAdMobBanner()
    
    
    // Call query
    queryMyNews()
}

 
// MARK: - QUERY MY NEWS
func queryMyNews() {
    newsArray.removeAll()
    showHUD()
        
    let query = PFQuery(className: NEWS_CLASS_NAME)
    query.whereKey(NEWS_USER_POINTER, equalTo: PFUser.current()! )
    query.includeKey(USER_CLASS_NAME)
    query.findObjectsInBackground { (objects, error) -> Void in
        if error == nil {
            self.newsArray = objects!
            self.newsTableView.reloadData()
            self.hideHUD()
            
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }}
}
    
 
    
// MARK: - QUERY SAVED NEWS
func querySavedNews() {
    newsArray.removeAll()
    showHUD()
        
    let query = PFQuery(className: SAVED_CLASS_NAME)
    query.whereKey(SAVED_SAVING_USER, equalTo: PFUser.current()!)
    query.includeKey(NEWS_CLASS_NAME)
    query.findObjectsInBackground { (objects, error) -> Void in
        if error == nil {
            self.newsArray = objects!
            self.newsTableView.reloadData()
            self.hideHUD()
                
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }}
}
    
    
    
// MARK: - TABLEVIEW DELEGATES
func numberOfSections(in tableView: UITableView) -> Int {
    return 1
}
    
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return newsArray.count
}
    
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
    
    // SHOW MY NEWS
    if segControl.selectedSegmentIndex == 0 {
        var newsClass = PFObject(className: NEWS_CLASS_NAME)
        newsClass = newsArray[(indexPath as NSIndexPath).row]
        
        // Get userPointer
        let userPointer = newsClass[NEWS_USER_POINTER] as! PFUser
        userPointer.fetchIfNeededInBackground(block: { (user, error) in
            if error == nil {
                
                // Show User's news
                let aUrl = URL(string: "\(newsClass[NEWS_URL]!)")
                var domainStr = aUrl!.host
                if domainStr?.range(of: "www.") != nil {
                    domainStr = domainStr!.replacingOccurrences(of: "www.", with: "")
                }
                cell.newsTitleLabel.text = "\(newsClass[NEWS_TITLE]!) (\(domainStr!))"
                cell.newsTitleLabel.layer.cornerRadius = 8
                cell.commentsOutlet.setTitle("\(newsClass[NEWS_COMMENTS]!)", for: .normal)
                cell.categoryOutlet.setTitle("\(newsClass[NEWS_CATEGORY]!)", for: .normal)
                let postDate = newsClass.createdAt!
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyy"
                cell.postDateLabel.text = dateFormatter.string(from: postDate)
                
                // Assing tags to the buttons (for later use)
                cell.commentsOutlet.tag = (indexPath as NSIndexPath).row
                cell.shareOutlet.tag = (indexPath as NSIndexPath).row
            }
        })
        
        
        
    // SHOW SAVED NEWS
    } else {
        var savedClass = PFObject(className: SAVED_CLASS_NAME)
        savedClass = newsArray[(indexPath as NSIndexPath).row]
        
        // Get userPointer
        let userPointer = savedClass[SAVED_USER_POINTER] as! PFUser
        userPointer.fetchIfNeededInBackground(block: { (user, error) in
            // Get newsPointer
            let newsPointer = savedClass[SAVED_NEWS_POINTER] as! PFObject
            newsPointer.fetchIfNeededInBackground(block: { (news, error) in
                if error == nil {
                    // Show User's news
                    let aUrl = URL(string: "\(newsPointer[NEWS_URL]!)")
                    var domainStr = aUrl!.host
                    if domainStr?.range(of: "www.") != nil {
                        domainStr = domainStr!.replacingOccurrences(of: "www.", with: "")
                    }
                    cell.newsTitleLabel.text = "\(newsPointer[NEWS_TITLE]!) (\(domainStr!))"
                    cell.newsTitleLabel.layer.cornerRadius = 8
                    cell.commentsOutlet.setTitle("\(newsPointer[NEWS_COMMENTS]!)", for: .normal)
                    cell.categoryOutlet.setTitle("\(newsPointer[NEWS_CATEGORY]!) - by \(userPointer.username!)", for: .normal)
                    let postDate = newsPointer.createdAt!
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd/MM/yyy"
                    cell.postDateLabel.text = dateFormatter.string(from: postDate)
                    
                    // Assing tags to the buttons (for later use)
                    cell.commentsOutlet.tag = (indexPath as NSIndexPath).row
                    cell.shareOutlet.tag = (indexPath as NSIndexPath).row
                } else { self.simpleAlert("\(error!.localizedDescription)")
            }})
        
        })
        
    }
    
return cell
}
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 134
}
    
    
// MARK: -  CELL HAS BEEN TAPPED -> SHOW NEWS VIA WEB VIEW
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    var urlStr = ""
    
    if segControl.selectedSegmentIndex == 0 {
        var newsClass = PFObject(className: NEWS_CLASS_NAME)
        newsClass = newsArray[(indexPath as NSIndexPath).row]
        urlStr = "\(newsClass[NEWS_URL]!)"
        
        // Open MiniBrowser
        let mbVC = storyboard?.instantiateViewController(withIdentifier: "MiniBrowser") as! MiniBrowser
        mbVC.urlString = urlStr
        navigationController?.pushViewController(mbVC, animated: true)
        
    } else {
        var savedClass = PFObject(className: SAVED_CLASS_NAME)
        savedClass = newsArray[(indexPath as NSIndexPath).row]
        // Get newsPointer
        let newsPointer = savedClass[SAVED_NEWS_POINTER] as! PFObject
        newsPointer.fetchIfNeededInBackground(block: { (news, error) in
            urlStr = "\(newsPointer[NEWS_URL]!)"
            // Open MiniBrowser
            let mbVC = self.storyboard?.instantiateViewController(withIdentifier: "MiniBrowser") as! MiniBrowser
            mbVC.urlString = urlStr
            self.navigationController?.pushViewController(mbVC, animated: true)
        })
    }
    
}
    
    
    
// MARK: - DELETE NEWS BY SWIPING THE CELL LEFT
func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
}
func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == UITableViewCellEditingStyle.delete {
            
            var myNewsClass = PFObject(className: NEWS_CLASS_NAME)
            myNewsClass = newsArray[(indexPath as NSIndexPath).row]
            myNewsClass.deleteInBackground {(success, error) -> Void in
                if error == nil {
                    self.newsArray.remove(at: (indexPath as NSIndexPath).row)
                    tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                    
                } else {
                    self.simpleAlert("\(error!.localizedDescription)")
            }}
        
    }
        
}

    
    
    
    
// MARK: - SWITCH YOUR NEWS / SAVED NEWS
@IBAction func segControlChanged(_ sender: UISegmentedControl) {
    print("\(segControl.selectedSegmentIndex)")
    
    // SHOW MY NEWS
    if sender.selectedSegmentIndex == 0 {
        newsArray.removeAll()
        newsTableView.reloadData()
        queryMyNews()
        
    // SHOW SAVED NEWS
    } else {
        newsArray.removeAll()
        newsTableView.reloadData()
        querySavedNews()
    }
    
}
    
    
    
// COMMENTS BUTTON
@IBAction func commentsButt(_ sender: AnyObject) {
    let butt = sender as! UIButton
    
    if segControl.selectedSegmentIndex == 0 {
        var newsClass = PFObject(className: NEWS_CLASS_NAME)
        newsClass = newsArray[butt.tag]
        
        let commVC = storyboard?.instantiateViewController(withIdentifier: "Comments") as! Comments
        commVC.newsObject = newsClass
        navigationController?.pushViewController(commVC, animated: true)
        
    } else {
        var savedClass = PFObject(className: NEWS_CLASS_NAME)
        savedClass = newsArray[butt.tag]
        
        // Get newsPointer
        let newsPointer = savedClass[SAVED_NEWS_POINTER] as! PFObject
        newsPointer.fetchIfNeededInBackground(block: { (news, error) in
            if error == nil {
                let commVC = self.storyboard?.instantiateViewController(withIdentifier: "Comments") as! Comments
                commVC.newsObject = newsPointer
                self.navigationController?.pushViewController(commVC, animated: true)
            }
        })
    }
}
    
    
    
   
// MARK: - SHARE BUTTON
@IBAction func shareButt(_ sender: AnyObject) {
    let butt = sender as! UIButton
    var messageStr = ""
    var img = UIImage()
    
    // SHARE ONE OF YOUR NEWS
    if segControl.selectedSegmentIndex == 0 {
        var newsClass = PFObject(className: NEWS_CLASS_NAME)
        newsClass = newsArray[butt.tag]
    
        messageStr  = "\(newsClass[NEWS_TITLE]!) - from #\(APP_NAME)"
        img = UIImage(named: "h1")!
    
        
    // SHARE A SAVED NEWS
    } else {
        var savedClass = PFObject(className: SAVED_CLASS_NAME)
        savedClass = newsArray[butt.tag]
        let newsPointer = savedClass[SAVED_NEWS_POINTER] as! PFObject
        messageStr  = "\(newsPointer[NEWS_TITLE]!) - from #\(APP_NAME)"
        img = UIImage(named: "h1")!
    }
    
    
    let shareItems = [messageStr, img] as [Any]
    
    let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
    activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.postToWeibo, UIActivityType.copyToPasteboard, UIActivityType.addToReadingList, UIActivityType.postToVimeo]
    
    if UIDevice.current.userInterfaceIdiom == .pad {
        // iPad
        let popOver = UIPopoverController(contentViewController: activityViewController)
        popOver.present(from: CGRect.zero, in: self.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
    } else {
        // iPhone
        present(activityViewController, animated: true, completion: nil)
    }
}
    
    
    
// MARK: - BACK BUTTON
func backButton() {
    _ = navigationController?.popViewController(animated: true)
}
    
    
    
// MARK: - LOGOUT BUTTON
func logoutButt(_ sender:UIButton) {
    let alert = UIAlertView(title: APP_NAME,
    message: "Are you sure you want to logout?",
    delegate: self,
    cancelButtonTitle: "No",
    otherButtonTitles: "Yes")
    alert.show()
}
// AlertView delegate
func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
    if alertView.buttonTitle(at: buttonIndex) == "Yes" {
        PFUser.logOutInBackground { (error) -> Void in
            if error == nil {
               _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
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
        banner.frame = CGRect(x: 0, y: self.view.frame.size.height - banner.frame.size.height,
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



