/*---------------------------------
 
 - Readit -
 
 created by FV iMAGINATION ©2016
 All Rights reserved
 
 -----------------------------------*/


import UIKit
import Parse
import MessageUI




// MARK: - CUSTOM NEWS CELL
class NewsCell: UITableViewCell {
    
    /* Views */
    @IBOutlet weak var upVoteOutlet: UIButton!
    @IBOutlet weak var downVoteOutlet: UIButton!
    @IBOutlet weak var votesLabel: UILabel!
    @IBOutlet weak var newsTitleLabel: UILabel!
    @IBOutlet weak var submittedByOutlet: UIButton!
    @IBOutlet weak var commentsOutlet: UIButton!
    @IBOutlet weak var categoryOutlet: UIButton!
    @IBOutlet weak var shareOutlet: UIButton!
    @IBOutlet weak var saveOutlet: UIButton!
    @IBOutlet weak var reportOutlet: UIButton!
    @IBOutlet weak var postDateLabel: UILabel!
    
    
    /* Variables */
    var upVoted = Bool()
    var downVoted = Bool()
}









// MARK: - HOME CONTROLLER
class Home: UIViewController,
UIAlertViewDelegate,
UITableViewDelegate,
UITableViewDataSource,
MFMailComposeViewControllerDelegate,
UITextFieldDelegate
{

    /* Views */
    @IBOutlet weak var newsTableView: UITableView!
    @IBOutlet weak var categoriesScrollView: UIScrollView!
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTxt: UITextField!
    
    @IBOutlet weak var sortView: UIView!
    
    
    
    /* Variables */
    var newsArray = [PFObject]()
    var categoriesArray = [PFObject]()
    var savedNews = [PFObject]()
    var votesArray = [PFObject]()
    
    var categoryStr = ""
    var userID = ""
    var searchText = ""
    var searchViewiSVisible = false
    var sortViewIsVisible = false
    var sortByDate = true
    var sortByVotes = false
    
    
    
    
    
    
    
override func viewWillAppear(_ animated: Bool) {

    // Hide views
    searchView.frame.origin.y = -searchView.frame.size.height
    searchViewiSVisible = false
    sortView.frame.origin.y = -sortView.frame.size.height
    sortViewIsVisible = false
    
    // Call query News
    callQueryNews()
}
    
override func viewDidLoad() {
        super.viewDidLoad()
    
    // Layouts
    newsTableView.contentInset = UIEdgeInsetsMake(-50, 0, 0, 0)
    

}

    
    
// MARK: - CALL QUERY TO NEWS
func callQueryNews() {
    if categoryStr != ""       { queryNews(categoryStr)
    } else if userID != ""     { queryNews(userID)
    } else if searchText != "" { queryNews(searchText)
    } else if categoryStr == ""  && userID == ""  && searchText == "" { queryNews("") }
    
    // CONSOLE LOGS:
    print("\n\nSORT BY DATE: \(sortByDate)")
    print("SORT BY VOTES: \(sortByVotes)")
    print("CATEGORY: \(categoryStr)")
    print("USER ID: \(userID)")
    print("SEARCH TEXT: \(searchText)\n\n")
}

    
    
    
// MARK: - QUERY NEWS
func queryNews(_ text:String) {
    newsArray.removeAll()
    showHUD()
    
    let query = PFQuery(className: NEWS_CLASS_NAME)
    query.limit = 100
    query.includeKey(USER_CLASS_NAME)
    query.whereKey(NEWS_IS_REPORTED, equalTo: false)
    
    // Query by Category
    if categoryStr != "" { query.whereKey(NEWS_CATEGORY, equalTo: text)
    } else { self.title = "Latest" }

    // Query by User
    if userID != "" { query.whereKey(NEWS_USER_POINTER, equalTo: PFObject(withoutDataWithClassName: USER_CLASS_NAME, objectId: userID) )
    } else { self.title = "Latest" }
    
    // Query by Search text
    if searchText != "" {
        let keywords = searchText.components(separatedBy: " ") as [String]
        query.whereKey(NEWS_TITLE_LOWERCASE, contains: keywords[0].lowercased())
    } else { self.title = "Latest" }
    
    // Sort by Date or Votes (by Date is the default ordering when view will appear)
    if sortByDate { query.order(byDescending: "createdAt")
    } else if sortByVotes { query.order(byDescending: NEWS_VOTES) }
    
    
    // Query block
    query.findObjectsInBackground { (objects, error)-> Void in
        if error == nil {
            self.newsArray = objects!
            self.newsTableView.reloadData()
            self.hideHUD()
            self.queryCategories()
        
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }}
}
    
    
    
    
// MARK: - QUERY CATEGORIES
func queryCategories() {
    categoriesArray.removeAll()

    let query = PFQuery(className: CATEGORIES_CLASS_NAME)
    query.findObjectsInBackground { (objects, error)-> Void in
        if error == nil {
            self.categoriesArray = objects!
            self.showCategories()
        } else {
            self.simpleAlert("\(error!.localizedDescription)")

    }}
}
    
// SHOW CATEGORIES INTO THE TOP SCROLLVIEW
func showCategories() {
    // Variables for setting the Font Buttons
    var xCoord: CGFloat = 0
    let yCoord: CGFloat = 0
    let buttonWidth:CGFloat = 80
    let buttonHeight: CGFloat = 44
    let gap: CGFloat = 0
    
    // Counter for items
    var itemCount = 0
    
    // Loop for creating buttons -----------------
    for i in 0..<categoriesArray.count {
        itemCount = i

        var catClass = PFObject(className: CATEGORIES_CLASS_NAME)
        catClass = categoriesArray[itemCount]
        
        // Create a Button
        let myButt = UIButton(type: UIButtonType.custom)
        myButt.frame = CGRect(x: xCoord, y: yCoord, width: buttonWidth, height: buttonHeight)
        myButt.tag = itemCount
        myButt.showsTouchWhenHighlighted = true
        myButt.setTitle("\(catClass[CATEGORIES_CATEGORY]!)", for: .normal)
        myButt.titleLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 13)
        myButt.setTitleColor(UIColor.white, for: .normal)
        myButt.addTarget(self, action: #selector(categoryButt(_:)), for: .touchUpInside)
        
        // Add Buttons & Labels based on xCood
        xCoord +=  buttonWidth + gap
        categoriesScrollView.addSubview(myButt)
    } // END LOOP --------------------------
    
    
    // Place Buttons into the ScrollView
    categoriesScrollView.contentSize = CGSize(width: buttonWidth * CGFloat(itemCount+1), height: yCoord)
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
    
    var newsClass = PFObject(className: NEWS_CLASS_NAME)
    newsClass = self.newsArray[(indexPath as NSIndexPath).row]
    
    // Get userPointer
    let userPointer = newsClass[NEWS_USER_POINTER] as! PFUser
    userPointer.fetchIfNeededInBackground { (user, error) in
        if error == nil {
            // Show news
            let aUrl = URL(string: "\(newsClass[NEWS_URL]!)")
            var domainStr = aUrl!.host
            if domainStr?.range(of: "www.") != nil {
                domainStr = domainStr!.replacingOccurrences(of: "www.", with: "")
            }
            cell.newsTitleLabel.text = "\(newsClass[NEWS_TITLE]!) (\(domainStr!))"
            cell.newsTitleLabel.layer.cornerRadius = 8
           
            cell.submittedByOutlet.setTitle("by \(userPointer.username!)", for: .normal)
            cell.commentsOutlet.setTitle("\(newsClass[NEWS_COMMENTS]!)", for: .normal)
            cell.categoryOutlet.setTitle("\(newsClass[NEWS_CATEGORY]!)", for: .normal)
            let postDate = newsClass.createdAt!
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            cell.postDateLabel.text = dateFormatter.string(from: postDate)
            
            
    
            // Assing tags to the buttons (for later use)
            
            cell.submittedByOutlet.tag = (indexPath as NSIndexPath).row
            cell.categoryOutlet.tag = (indexPath as NSIndexPath).row
            cell.commentsOutlet.tag = (indexPath as NSIndexPath).row
            cell.shareOutlet.tag = (indexPath as NSIndexPath).row
            cell.saveOutlet.tag = (indexPath as NSIndexPath).row
            cell.reportOutlet.tag = (indexPath as NSIndexPath).row
        }
    }
    
    
return cell
}
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 144
}
    
    
// MARK: -  CELL HAS BEEN TAPPED -> SHOW NEWS VIA WEB VIEW
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var newsClass = PFObject(className: NEWS_CLASS_NAME)
        newsClass = newsArray[(indexPath as NSIndexPath).row]
        let urlStr = "\(newsClass[NEWS_URL]!)"
        
        let mbVC = storyboard?.instantiateViewController(withIdentifier: "MiniBrowser") as! MiniBrowser
        mbVC.urlString = urlStr
        navigationController?.pushViewController(mbVC, animated: true)
}
    
    
    
    
// MARK: UP-VOTE BUTTON
@IBAction func upVoteButt(_ sender: AnyObject) {
    // USER IS LOGGED IN
    if PFUser.current() != nil {
            
        let butt = sender as! UIButton
        let indexP = IndexPath(row: butt.tag, section: 0)
        let cell = newsTableView.cellForRow(at: indexP) as! NewsCell
        var newsClass = PFObject(className: NEWS_CLASS_NAME)
        newsClass = newsArray[butt.tag]
        //let currentVotes = newsClass[NEWS_VOTES] as! Int
        
        
        // Query Votes
        votesArray.removeAll()
        let query = PFQuery(className: VOTES_CLASS_NAME)
        query.whereKey(VOTES_USER_POINTER, equalTo: PFUser.current()!)
        query.whereKey(VOTES_NEWS_POINTER, equalTo: newsClass)
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil {
                self.votesArray = objects!
                print("VOTES ARRAY: \(self.votesArray)")
                
                var votesClass = PFObject(className: VOTES_CLASS_NAME)
                
                if self.votesArray.count > 0 {
                  votesClass = self.votesArray[0]
                  
                    // Get userPointer
                    let userPointer = votesClass[VOTES_USER_POINTER] as! PFUser
                    userPointer.fetchIfNeededInBackground(block: { (user, error) in
                        
                        // Get newsPointer
                        let newsPointer = votesClass[VOTES_NEWS_POINTER] as! PFObject
                        newsPointer.fetchIfNeededInBackground(block: { (news, error) in
                            // Upvote!
                            if votesClass[VOTES_UPVOTED] == nil  || votesClass[VOTES_UPVOTED] as! Bool == false  {
                                newsClass.incrementKey(NEWS_VOTES)
                                let voteInt = Int(cell.votesLabel.text!)! + 1
                                cell.votesLabel.text = "\(voteInt)"
                                newsClass.saveInBackground()
                                
                                votesClass[VOTES_USER_POINTER] = PFUser.current()
                                votesClass[VOTES_NEWS_POINTER] = newsClass
                                votesClass[VOTES_UPVOTED] = true
                                votesClass[VOTES_DOWNVOTED] = false
                                votesClass.saveInBackground()
                                
                            // Cannot upvote!
                            } else if votesClass[VOTES_UPVOTED] as! Bool == true {
                                self.simpleAlert("You've already upvoted this news!")
                            }
                        })
                        
                    })
                   
                
                    
                } else {
                    newsClass.incrementKey(NEWS_VOTES)
                    let voteInt = Int(cell.votesLabel.text!)! + 1
                    cell.votesLabel.text = "\(voteInt)"
                    newsClass.saveInBackground()
                    
                    votesClass[VOTES_USER_POINTER] = PFUser.current()
                    votesClass[VOTES_NEWS_POINTER] = newsClass
                    votesClass[VOTES_UPVOTED] = true
                    votesClass[VOTES_DOWNVOTED] = false
                    votesClass.saveInBackground()
                }
                
                
            // Error in query
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
        }}


        
        
        
    // USER IS NOT LOGGED IN/REGISTERED
    } else {
        let alert = UIAlertView(title: APP_NAME,
            message: "You must Login/Sign Up to Vote",
            delegate: self,
            cancelButtonTitle: "Cancel",
            otherButtonTitles: "Login")
        alert.show()
    }
}
    


    
// MARK: DOWN-VOTE BUTTON
@IBAction func downVoteButt(_ sender: AnyObject) {
    // USER IS LOGGED IN
    if PFUser.current() != nil {
            
            let butt = sender as! UIButton
            let indexP = IndexPath(row: butt.tag, section: 0)
            let cell = newsTableView.cellForRow(at: indexP) as! NewsCell
            var newsClass = PFObject(className: NEWS_CLASS_NAME)
            newsClass = newsArray[butt.tag]
            let currentVotes = newsClass[NEWS_VOTES] as! Int

        // Query Votes
        votesArray.removeAll()
        let query = PFQuery(className: VOTES_CLASS_NAME)
        query.whereKey(VOTES_USER_POINTER, equalTo: PFUser.current()!)
        query.whereKey(VOTES_NEWS_POINTER, equalTo: newsClass)
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil {
                self.votesArray = objects!
                print("VOTES ARRAY: \(self.votesArray)")
                
                var votesClass = PFObject(className: VOTES_CLASS_NAME)
                
                if self.votesArray.count > 0 {
                    votesClass = self.votesArray[0]
                    
                    let userPointer = votesClass[VOTES_USER_POINTER] as! PFUser
                    userPointer.fetchIfNeededInBackground(block: { (user, error) in
                        // Get newsPointer
                        let newsPointer = votesClass[VOTES_NEWS_POINTER] as! PFObject
                        newsPointer.fetchIfNeededInBackground(block: { (news, error) in
                            if error == nil {
                                // Downvote!
                                if votesClass[VOTES_DOWNVOTED] == nil  || votesClass[VOTES_DOWNVOTED] as! Bool == false  {
                                    let updatedVotes = currentVotes - 1
                                    newsClass[NEWS_VOTES] = updatedVotes
                                    cell.votesLabel.text = "\(updatedVotes)"
                                    newsClass.saveInBackground()
                                    
                                    votesClass[VOTES_USER_POINTER] = PFUser.current()
                                    votesClass[VOTES_NEWS_POINTER] = newsClass
                                    votesClass[VOTES_DOWNVOTED] = true
                                    votesClass[VOTES_UPVOTED] = false
                                    votesClass.saveInBackground()
                                    
                                // Cannot downvote!
                                } else if votesClass[VOTES_DOWNVOTED] as! Bool == true {
                                    self.simpleAlert("You've already downvoted this news!")
                                }
                            }
                            
                        })
                        
                    })
                    
                    
                    
                } else {
                    let updatedVotes = currentVotes - 1
                    newsClass[NEWS_VOTES] = updatedVotes
                    cell.votesLabel.text = "\(updatedVotes)"
                    newsClass.saveInBackground()
                    
                    votesClass[VOTES_USER_POINTER] = PFUser.current()
                    votesClass[VOTES_NEWS_POINTER] = newsClass
                    votesClass[VOTES_DOWNVOTED] = true
                    votesClass[VOTES_UPVOTED] = false
                    votesClass.saveInBackground()
                }
                
                
            // Error in query
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
        }}

        

        
        
            
    // USER IS NOT LOGGED IN/REGISTERED
    } else {
        let alert = UIAlertView(title: APP_NAME,
            message: "You must Login/Sign Up to Vote",
            delegate: self,
            cancelButtonTitle: "Cancel",
            otherButtonTitles: "Login")
        alert.show()
    }
}
    

    
    
    
// MARK: - CATEGORY BUTTON
func categoryButt(_ sender:UIButton) {
    let butt = sender as UIButton
    userID = ""
    searchText = ""
    categoryStr = butt.titleLabel!.text!
    callQueryNews()
    self.title = "Latest in \(categoryStr)"
}
    
    
    
    
// MARK: - SUBMITTED BY BUTTON
@IBAction func submittedByButt(_ sender: AnyObject) {
    let butt = sender as! UIButton
    var newsClass = PFObject(className: NEWS_CLASS_NAME)
    newsClass = newsArray[butt.tag]
    let aUser = newsClass[NEWS_USER_POINTER] as? PFUser
    userID = aUser!.objectId!
    categoryStr = ""
    searchText = ""
    callQueryNews()
    
    self.title = "Latest by \(aUser!.username!)"
}
    

    
// THE CATEGORY BUTTON IN THE CELL
@IBAction func catsButt(_ sender: AnyObject) {
   let butt = sender as! UIButton
    userID = ""
    searchText = ""
    categoryStr = butt.titleLabel!.text!
    callQueryNews()
}
    
    
    
// COMMENTS BUTTON
@IBAction func commentsButt(_ sender: AnyObject) {
    let butt = sender as! UIButton
    var newsClass = PFObject(className: NEWS_CLASS_NAME)
    newsClass = newsArray[butt.tag]
    
    let commVC = storyboard?.instantiateViewController(withIdentifier: "Comments") as! Comments
    commVC.newsObject = newsClass
    navigationController?.pushViewController(commVC, animated: true)
    
}
    
    
    
// MARK: - SHARE BUTTON
@IBAction func shareButt(_ sender: AnyObject) {
    let butt = sender as! UIButton
    var newsClass = PFObject(className: NEWS_CLASS_NAME)
    newsClass = newsArray[butt.tag]
    
    let messageStr  = "\(newsClass[NEWS_TITLE]!) - from #\(APP_NAME)"
    let img = UIImage(named: "h1")!
    
    let shareItems = [messageStr, img] as [Any]
    
    let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
    activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.postToWeibo, UIActivityType.copyToPasteboard, UIActivityType.addToReadingList, UIActivityType.postToVimeo]
    
    if UIDevice.current.userInterfaceIdiom == .pad {
        // iPad
        let popOver = UIPopoverController(contentViewController: activityViewController)
        popOver.present(from: .zero, in: view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
    } else {
        // iPhone
        present(activityViewController, animated: true, completion: nil)
    }
}
    
    
    
    
// MARK: - SAVE NEWS BUTTON
@IBAction func saveButt(_ sender: AnyObject) {
    let butt = sender as! UIButton
    
    // YOU ARE LOGGED IN
    if PFUser.current() != nil {
        var newsPointer = PFObject(className: NEWS_CLASS_NAME)
        newsPointer = newsArray[butt.tag]
    
        let savedClass = PFObject(className: SAVED_CLASS_NAME)
        let userToSave = newsPointer[NEWS_USER_POINTER] as! PFUser

        // Save data
        savedClass[SAVED_USER_POINTER] = userToSave
        savedClass[SAVED_NEWS_POINTER] = newsPointer
        savedClass[SAVED_SAVING_USER] = PFUser.current()
    
        
        // YOU CAN SAVE NEWS POSTED BY OTHER USERS THAN YOU
        if PFUser.current()!.username != userToSave.username {

          // Saving block
          savedClass.saveInBackground { (success, error) -> Void in
            if error == nil {
                self.simpleAlert("You've saved this news")
            
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
           }}
            
            
            
        // CAN'T SAVE YOUR OWN NEWS!
        } else {
            simpleAlert("You can't save your own News, just check them out in your Account!")
        }
        
        
        
    // YOU'RE NOT LOGGED IN
    } else if PFUser.current() == nil {
        let alert = UIAlertView(title: APP_NAME,
            message: "You must Login/Sign Up to save News!",
            delegate: self,
            cancelButtonTitle: "Cancel",
            otherButtonTitles: "Login")
        alert.show()
    }
}
    
    
    
    
    

// MARK: - REPORT INAPPROPRIATE CONTENTS BUTTON
@IBAction func reportButt(_ sender: AnyObject) {
    let butt = sender as! UIButton
    let indexP = IndexPath(row: butt.tag, section: 0)
    var newsClass = PFObject(className: NEWS_CLASS_NAME)
    newsClass = newsArray[butt.tag]

    
    let alert = UIAlertController(title: APP_NAME,
            message: "Report this news as inappropriate",
            preferredStyle: .alert)
        
        
    let report = UIAlertAction(title: "Report as inappropriate", style: .default, handler: { (action) -> Void in
        
        self.showHUD()
        newsClass[NEWS_IS_REPORTED] = true
        newsClass.saveInBackground(block: { (succ, error) in
            if error == nil {
                self.simpleAlert("Thanks for reporting this comment. We'll check it out within 24h.")
                self.newsArray.remove(at: butt.tag)
                self.newsTableView.deleteRows(at: [indexP], with: .fade)
                self.hideHUD()
        }})
    })
        
    // Cancel button
    let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        
        
    alert.addAction(report)
    alert.addAction(cancel)
    self.present(alert, animated: true, completion: nil)
}
    
    
    
    
    
    
    
    
// MARK: - ********  NAVIGATION BAR BUTTONS  ***********
    
//   MARK: - SEARCH BUTTON
@IBAction func searchButt(_ sender: AnyObject) {
    searchViewiSVisible = !searchViewiSVisible
    
    if searchViewiSVisible { showSearchView()
    } else {  hideSearchView()  }
}

// MARK: - SHOW/HIDE SEARCH VIEW
func showSearchView() {
    sortViewIsVisible = false
    hideSortView()
    
    UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
            self.searchView.frame.origin.y = 64
        }, completion: { (finished: Bool) in
            self.searchTxt.becomeFirstResponder()
    })
}
func hideSearchView() {
    searchViewiSVisible = false
    UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
        self.searchView.frame.origin.y = -self.searchView.frame.size.height
    }, completion: { (finished: Bool) in
        self.searchTxt.text = ""
        self.searchTxt.resignFirstResponder()
    })
}
    
// MARK: - TEXTFIELD DELEGATES
func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    categoryStr = ""
    userID = ""
    searchText = searchTxt.text!
    // Call query
    callQueryNews()
    
    hideSearchView()
    
return true
}
    
    
    
// MARK: - USER BUTTON
@IBAction func userButt(_ sender: AnyObject) {
    if PFUser.current() != nil {
        let accVC = storyboard?.instantiateViewController(withIdentifier: "Account") as! Account
        navigationController?.pushViewController(accVC, animated: true)
    } else {
        let loginVC = storyboard?.instantiateViewController(withIdentifier: "Login") as! Login
        present(loginVC, animated: true, completion: nil)
    }
}
    
    
    
    
    
// MARK: - ADD LINK BUTTON
@IBAction func addLinkButt(_ sender: AnyObject) {
    
    // USER IS LOGGED IN/REGISTERED -> GO TO POST LINK CONTROLLER
    if PFUser.current() != nil {
        categoryStr = ""
        userID = ""
        searchText = ""
        let plVC = storyboard?.instantiateViewController(withIdentifier: "PostLink") as! PostLink
        navigationController?.pushViewController(plVC, animated: true)
            
            
    // USER IS NOT LOGGED IN/REGISTERED
    } else {
        let alert = UIAlertView(title: APP_NAME,
            message: "You must Login/Sign Up to add Links",
            delegate: self,
            cancelButtonTitle: "Cancel",
            otherButtonTitles: "Login")
        alert.show()
    }
}
// AlertView delegate
func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
    if alertView.buttonTitle(at: buttonIndex) == "Login" {
        let loginVC = storyboard?.instantiateViewController(withIdentifier: "Login") as! Login
        present(loginVC, animated: true, completion: nil)
    }
}
    
    
    
    
// MARK: - SORT BY BUTTON
@IBAction func sortByButt(_ sender: AnyObject) {
    sortViewIsVisible = !sortViewIsVisible
    if sortViewIsVisible { showSortView()
    } else { hideSortView()  }
}
    
// MARK: - SHOW/HIDE SORT VIEW
func showSortView() {
    hideSearchView()
    searchViewiSVisible = false
    
    UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
        self.sortView.frame.origin.y = 64
    }, completion: { (finished: Bool) in })
}
func hideSortView() {
    sortViewIsVisible = false
    UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: {
        self.sortView.frame.origin.y = -self.sortView.frame.size.height
    }, completion: { (finished: Bool) in })
}
    
    

// MARK: - SORT BY DATE BUTTON
@IBAction func sortDateButt(_ sender: AnyObject) {
    sortByVotes = false
    sortByDate = true
    hideSortView()
   
    // Call query
    callQueryNews()
}

    
// MARK: - SORT BY VOTES BUTTON
@IBAction func sortVotesButt(_ sender: AnyObject) {
    sortByVotes = true
    sortByDate = false
    hideSortView()
    
    // Call query
    callQueryNews()
}
    

// SHOW LATEST NEWS BUTTON
@IBAction func showLatestNewsButt(_ sender: AnyObject) {
    sortByVotes = false
    sortByDate = true
    categoryStr = ""
    userID = ""
    searchText = ""
    hideSortView()
    
    callQueryNews()
}
    

    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}





