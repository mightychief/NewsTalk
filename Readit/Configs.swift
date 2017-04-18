/*---------------------------------
 
 - Readit -
 
 created by FV iMAGINATION ©2016
 All Rights reserved
 
 -----------------------------------*/

import Foundation
import UIKit



// REPLACE THE RED STRING BELOW WITH THE NEW NAME YOU'LL GIVE TO THIS APP
let APP_NAME = "NewsTalk"


// REPLACE THE RED STRING BELOW WITH THE EMAIL ADDRESS YOU'LL DEDICATE TO REPORTS OF INAPPROPRIATE CONTENTS
let REPORT_EMAIL_ADDRESS = "report@t7me.com"


// IMPORTANT: REPLACE THE RED STRING BELOW WITH THE UNIT ID YOU'VE GOT BY REGISTERING YOUR APP IN http://www.apps.admob.com
let ADMOB_BANNER_UNIT_ID = ""



// PARSE KEYS -> REPLACE THEM WITH YOUR OWN ONES FROM YOUR APP ON https://back4app.com
let PARSE_APP_KEY = "JVMlWik3wRKsGmvmz7sccqT876pyZdCY0UJQtVww"
let PARSE_CLIENT_KEY = "hXDaiuV9K3Qhb3q0nUzN20CLAuIPRGqxqCiRIMbI"




// HUD VIEW
var hudView = UIView()
var animImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))

extension UIViewController {
    func showHUD() {
        hudView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        hudView.backgroundColor = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 236.0/255.0, alpha: 1.0)
        
        let imagesArr = ["h1", "h2", "h3"]
        var images:[UIImage] = []
        for i in 0..<imagesArr.count {
            images.append(UIImage(named: imagesArr[i])!)
        }
        animImage.animationImages = images
        animImage.animationDuration = 0.3
        animImage.center = hudView.center
        hudView.addSubview(animImage)
        animImage.startAnimating()
        view.addSubview(hudView)
    }
    
    func hideHUD() {  hudView.removeFromSuperview()  }
    
    func simpleAlert(_ mess:String) {
        UIAlertView(title: APP_NAME, message: mess, delegate: nil, cancelButtonTitle: "OK").show()
    }
}








/******** DO NOT EDIT THE VARIABLES BELOW! ******/

let USER_CLASS_NAME = "_User"
let USER_USERNAME = "username"

let CATEGORIES_CLASS_NAME = "Categories"
let CATEGORIES_CATEGORY = "category"

let NEWS_CLASS_NAME = "News"
let NEWS_USER_POINTER = "userPointer"
let NEWS_TITLE = "title"
let NEWS_TITLE_LOWERCASE = "titleLowercase"
let NEWS_VOTES = "votes"
let NEWS_COMMENTS = "comments"
let NEWS_URL = "url"
let NEWS_CATEGORY = "category"
let NEWS_IS_REPORTED = "isReported"

let SAVED_CLASS_NAME = "Saved"
let SAVED_USER_POINTER = "userPointer"
let SAVED_SAVING_USER = "savingUser"
let SAVED_NEWS_POINTER = "newsPointer"

let COMMENTS_CLASS_NAME = "Comments"
let COMMENTS_TEXT = "text"
let COMMENTS_USER_POINTER = "userPointer"
let COMMENTS_NEWS_POINTER = "newsPointer"
let COMMENTS_IS_REPORTED = "isReported"

let VOTES_CLASS_NAME = "Votes"
let VOTES_USER_POINTER = "userPointer"
let VOTES_NEWS_POINTER = "newsPointer"
let VOTES_UPVOTED = "upvoted"
let VOTES_DOWNVOTED = "downvoted"










