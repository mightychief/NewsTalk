/*---------------------------------
 
 - Readit -
 
 created by FV iMAGINATION ©2016
 All Rights reserved
 
 -----------------------------------*/


import UIKit
import Parse
import MessageUI


// MARK: - CUSTOM COMMENT CELL
class CommentCell: UITableViewCell {
    /* Views */
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
}









// MARK: - COMMENTS CONTROLLER
class Comments: UIViewController,
UITableViewDelegate,
UITableViewDataSource,
UITextFieldDelegate,
UIAlertViewDelegate,
MFMailComposeViewControllerDelegate
{

    /* Views */
    @IBOutlet weak var commTableView: UITableView!
    
    @IBOutlet weak var fakeTxt: UITextField!
    var commentView = UIView()
    var commentTxt = UITextField()
    
    
    /* Variables */
    var newsObject = PFObject(className: NEWS_CLASS_NAME)
    var commArray = [PFObject]()
    
    
    
    

override func viewDidLoad() {
        super.viewDidLoad()

    self.title = "Comments"
    print("NEWS OBJ: \(newsObject)")

    // Initialize a BACK BarButton Item
    let backbutt = UIButton(type: .custom)
    backbutt.adjustsImageWhenHighlighted = false
    backbutt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
    backbutt.setBackgroundImage(UIImage(named: "backButt"), for: .normal)
    backbutt.addTarget(self, action: #selector(backButton), for: .touchUpInside)
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backbutt)
    
    
    
    // Input Accessory View for comments initialization --------------------------------
    fakeTxt.delegate = self
    fakeTxt.keyboardAppearance = .dark
    
    commentView = UIView(frame: CGRect(x: 0, y: view.frame.size.height - 90, width: view.frame.size.width, height: 44) )
    commentView.backgroundColor = UIColor(red: 78.0/255.0, green: 92.0/255.0, blue: 111.0/255.0, alpha: 1.0)
    commentView.autoresizingMask = UIViewAutoresizing.flexibleWidth
    commentTxt = UITextField(frame: CGRect(x: 0, y: 0, width: commentView.frame.size.width - 20, height: 32) )
    commentTxt.center = CGPoint(x: commentView.frame.size.width/2, y: commentView.frame.size.height/2)
    commentTxt.delegate = self
    commentTxt.autocapitalizationType = .none
    commentTxt.autoresizingMask = .flexibleWidth
    commentTxt.borderStyle = .roundedRect
    commentTxt.backgroundColor = UIColor.white
    commentTxt.font = UIFont(name: "HelveticaNeue-Thin", size: 13)
    commentTxt.textColor = UIColor.black
    commentTxt.returnKeyType = .send
    commentTxt.placeholder = "Post a comment"
    commentTxt.keyboardAppearance = .dark
    commentView.addSubview(commentTxt)
    
    fakeTxt.inputAccessoryView = commentView
    //-------------------------------------------------------------------------------------

    
    
    // Query all comments of this post
    queryComments()
    Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(queryComments), userInfo: nil, repeats: false)
}
 
    
    
// MARK: - QUERY COMMENTS
func queryComments() {
    showHUD()
    
    let query = PFQuery(className: COMMENTS_CLASS_NAME)
    query.whereKey(COMMENTS_NEWS_POINTER, equalTo: newsObject)
    query.whereKey(COMMENTS_IS_REPORTED, equalTo: false)
    query.includeKey(COMMENTS_USER_POINTER)
    query.order(byDescending: "createdAt")
    query.findObjectsInBackground { (objects, error)-> Void in
        if error == nil {
            self.commArray = objects!
            self.commTableView.reloadData()
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
    return commArray.count
}
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commCell", for: indexPath) as! CommentCell
    
    var commClass = PFObject(className: COMMENTS_CLASS_NAME)
    commClass = commArray[(indexPath as NSIndexPath).row]
    let userPointer = commClass[COMMENTS_USER_POINTER] as! PFUser
    
    // Get data
    cell.usernameLabel.text = "by \(userPointer[USER_USERNAME]!)"
    cell.commentLabel.text = "\(commClass[COMMENTS_TEXT]!)"
    let postDate = commClass.createdAt!
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM/dd/yyyy"
    cell.dateLabel.text = dateFormatter.string(from: postDate)
    
    
return cell
}
   
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 90
}
    
    

// MARK: - DELETE AND REPOERT A COMMENT BY SWIPING THE CELL LEFT
func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
}
 
func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
}

func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    
    var commClass = PFObject(className: COMMENTS_CLASS_NAME)
    commClass = commArray[indexPath.row]
    
    
    // REPORT COMMENT ACTION
    let reportAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Report" , handler: { (action:UITableViewRowAction, indexPath:IndexPath) -> Void in
        
        let alert = UIAlertController(title: APP_NAME,
            message: "Report this comment as inappropriate",
            preferredStyle: .alert)
        
        
        let report = UIAlertAction(title: "Report Comment", style: .default, handler: { (action) -> Void in
         
            commClass[COMMENTS_IS_REPORTED] = true
            commClass.saveInBackground(block: { (succ, error) in
                if error == nil {
                    self.simpleAlert("Thanks for reporting this comment. We'll check it out within 24h.")
                    self.commArray.remove(at: indexPath.row)
                    self.commTableView.deleteRows(at: [indexPath], with: .fade)
            }})
        })
        
        // Cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
    
        
        alert.addAction(report)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)

    })
    
    
    
        
    // DELETE COMMENT ACTION
    let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete" , handler: { (action:UITableViewRowAction, indexPath:IndexPath) -> Void in
        
        // Get User Pointer
        let userPointer = commClass[COMMENTS_USER_POINTER] as! PFUser
        userPointer.fetchIfNeededInBackground(block: { (user, error) in
            if error == nil {
                
                if PFUser.current()!.username == userPointer.username! {
                    self.showHUD()
                    
                    commClass.deleteInBackground {(success, error) -> Void in
                        if error == nil {
                            self.commArray.remove(at: indexPath.row)
                            self.commTableView.deleteRows(at: [indexPath], with: .fade)
                            
                            // Decrease comments amount
                            self.newsObject.incrementKey(NEWS_COMMENTS, byAmount: -1)
                            self.newsObject.saveInBackground()
                            
                            self.hideHUD()
                            
                        } else {
                            self.simpleAlert("\(error!.localizedDescription)")
                            self.hideHUD()
                    }}
                    
                    
                // CURRENT USER CANNOT DELETE OTHER USERS POSTS
                } else {
                    self.simpleAlert("You can't delete other users comments")
                }

                
            // error
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
        }}) // end userPointer
        
    })
    
        
    // Set colors of the actions
    reportAction.backgroundColor = UIColor.darkGray
    deleteAction.backgroundColor = UIColor.red
        
    return [reportAction, deleteAction]
}
  
    
    
    
    
    

// MARK: - POST A COMMENT -> HIT SEND ON KEYBOARD
func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
    // USER IS LOGGED IN, CAN POST COMMENTS -----------------------
    if PFUser.current() != nil {
            
        if commentTxt.text != "" {
            showHUD()
            let commClass = PFObject(className: COMMENTS_CLASS_NAME)
            let currentUser = PFUser.current()!
            
            commClass[COMMENTS_USER_POINTER] = currentUser
            commClass[COMMENTS_TEXT] = commentTxt.text
            commClass[COMMENTS_NEWS_POINTER] = newsObject
            commClass[COMMENTS_IS_REPORTED] = false
            
            newsObject.incrementKey(NEWS_COMMENTS)
            newsObject.saveInBackground(block: { (success, error) -> Void in
                if error == nil {
                    // Saving block
                    commClass.saveInBackground { (success, error) -> Void in
                        if error == nil {
                            // Comment posted, reload commTavleView
                            self.queryComments()
                            self.hideHUD()
                        } else {
                            self.simpleAlert("\(error!.localizedDescription)")
                            self.hideHUD()
                    }}
                }
            })
            
            
        
            
        // In case there's no text in the commentTxt
        } else {
            simpleAlert("You must type something :)")
        }
            
            
            
            
            
        // USER IS NOT LOGGED IN, CAN'T POST COMMENTS ---------------
        } else {
            let alert = UIAlertView(title: APP_NAME,
            message: "You must Login/Sign Up to add Links",
            delegate: self,
            cancelButtonTitle: "Cancel",
            otherButtonTitles: "Login")
            alert.show()
        }
        
    
        // Reset textFields
        commentTxt.text = ""
        commentTxt.resignFirstResponder()
        fakeTxt.text = ""
        fakeTxt.resignFirstResponder()
        
return true
}
    
// AlertView delegate
func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
    if alertView.buttonTitle(at: buttonIndex) == "Login" {
        let loginVC = storyboard?.instantiateViewController(withIdentifier: "Login") as! Login
        present(loginVC, animated: true, completion: nil)
    }
}
    
    
func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    fakeTxt.text = ""
    commentTxt.becomeFirstResponder()
        
return  true
}

    
    
// MARK: - BACK BUTTON
func backButton() {
    _ = navigationController?.popViewController(animated: true)
}
    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
}
}
