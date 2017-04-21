/*---------------------------------
 
 - Readit -
 
 created by FV iMAGINATION ©2016
 All Rights reserved
 
 -----------------------------------*/


import UIKit
import Parse
import Firebase


class PostLink: UIViewController,
UITextFieldDelegate
{

    /* Views */
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var categoriesScrollView: UIScrollView!
    @IBOutlet weak var titleTxt: UITextField!
    @IBOutlet weak var urlTxt: UITextField!
    @IBOutlet weak var categoryLabel: UILabel!
    
    
    
    /* Variables */
    var categoriesArray = [PFObject]()
    var categoryStr = ""
    
    
    
    
override func viewDidLoad() {
        super.viewDidLoad()

    // Layouts
    self.title = "Post"

    containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width, height: 600)
    categoryStr = ""
    
    
    // Set placeholders layout
    let color = UIColor.white
    titleTxt.attributedPlaceholder = NSAttributedString(string: "type a Title", attributes: [NSForegroundColorAttributeName: color])
    urlTxt.attributedPlaceholder = NSAttributedString(string: "paste or type a URL (with http:// as prefix)", attributes: [NSForegroundColorAttributeName: color])

    
    // Initialize a BACK BarButton Item
    let butt = UIButton(type: .custom)
    butt.adjustsImageWhenHighlighted = false
    butt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
    butt.setBackgroundImage(UIImage(named: "backButt"), for: .normal)
    butt.addTarget(self, action: #selector(backButt(_:)), for: .touchUpInside)
    navigationItem.leftBarButtonItem = UIBarButtonItem(customView: butt)
    
    // Call query
    queryCategories()
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
            let myButt = UIButton(type: .custom)
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
    categoriesScrollView.contentSize = CGSize(width: buttonWidth * CGFloat(itemCount+2), height: yCoord)
}
    
    
    
// MARK: - CATEGORY BUTTON
func categoryButt(_ sender:UIButton) {
    let butt = sender as UIButton
    categoryStr = butt.titleLabel!.text!
    categoryLabel.text = categoryStr
}
    
    
    
    
// MARK: - POST LINK BUTTON
@IBAction func postLinkButt(_ sender: AnyObject) {
    showHUD()
    titleTxt.resignFirstResponder()
    urlTxt.resignFirstResponder()
    FIRAnalytics.logEvent(withName: "postlink_button", parameters: nil)
    
    let newsClass = PFObject(className: NEWS_CLASS_NAME)
    let currentUser = PFUser.current()!
    
    newsClass[NEWS_TITLE] = titleTxt.text
    newsClass[NEWS_TITLE_LOWERCASE] = titleTxt.text!.lowercased()
    newsClass[NEWS_USER_POINTER] = currentUser
    newsClass[NEWS_URL] = urlTxt.text
    newsClass[NEWS_CATEGORY] = categoryStr
    newsClass[NEWS_COMMENTS] = 0
    newsClass[NEWS_VOTES] = 0
    newsClass[NEWS_IS_REPORTED] = false
    
    
    // CAN POST LINK
    if titleTxt.text != ""  &&  (urlTxt.text!.hasPrefix("http://") || urlTxt.text!.hasPrefix("https://") )   && categoryStr != "" {
      newsClass.saveInBackground { (success, error) -> Void in
        if error == nil {
            self.categoryStr = ""
            self.hideHUD()
            _ = self.navigationController?.popViewController(animated: true)
        } else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }}
        
        
    // CANNOT POST YOUR LINK -> MISSING INFO
    } else {
        self.simpleAlert("You must insert a Title, a URL with 'http://' or 'https://' as prefix and choose a Category")
        hideHUD()
    }
}
    
    
    

// MARK: - TEXT FIELD DELEGATE
func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == titleTxt  { urlTxt.becomeFirstResponder() }
    if textField == urlTxt    { urlTxt.resignFirstResponder() }
    
return true
}

    
// MARK: - BACK BUTTON
func backButt(_ sender:UIButton) {
    _ = navigationController?.popViewController(animated: true)
}

    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
