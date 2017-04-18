/*---------------------------------
 
 - Readit -
 
 created by FV iMAGINATION ©2016
 All Rights reserved
 
 -----------------------------------*/

import UIKit
import Parse

class SignUp: UIViewController,
UITextFieldDelegate
{
    
    /* Views */
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    @IBOutlet var emailTxt: UITextField!
    
    

    
    
override func viewDidLoad() {
        super.viewDidLoad()
        
    // Setup layout views
    containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width, height: 300)
    
    // SET COLOR OF PLACEHOLDERS
    let color = UIColor.white
    usernameTxt.attributedPlaceholder = NSAttributedString(string: "choose a username", attributes: [NSForegroundColorAttributeName: color])
    passwordTxt.attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSForegroundColorAttributeName: color])
    emailTxt.attributedPlaceholder = NSAttributedString(string: "your email address", attributes: [NSForegroundColorAttributeName: color])
}
    
    
// MARK: - TAP TO DISMISS KEYBOARD
@IBAction func tapToDismissKeyboard(_ sender: UITapGestureRecognizer) {
   dismissKeyboard()
}
func dismissKeyboard() {
    usernameTxt.resignFirstResponder()
    passwordTxt.resignFirstResponder()
    emailTxt.resignFirstResponder()
}
    
// MARK: - SIGNUP BUTTON
@IBAction func signupButt(_ sender: AnyObject) {

    if usernameTxt.text == "" || passwordTxt.text == "" || emailTxt.text == "" {
        simpleAlert("You must fill all the fields to sign up!")
    } else {
        
        dismissKeyboard()
    	showHUD()

        let userForSignUp = PFUser()
        userForSignUp.username = usernameTxt.text!.lowercased()
        userForSignUp.password = passwordTxt.text
        userForSignUp.email = emailTxt.text
    
        userForSignUp.signUpInBackground { (succeeded, error) -> Void in
            // SUCCESSFULL SIGN UP
            if error == nil {
                self.dismiss(animated: false, completion: nil)
                self.hideHUD()
        
            // ERROR ON SIGN UP
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
        }}
    
    }
}
    
    
    
// MARK: -  TEXTFIELD DELEGATE
func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == usernameTxt {  passwordTxt.becomeFirstResponder()  }
    if textField == passwordTxt {  emailTxt.becomeFirstResponder()     }
    if textField == emailTxt    {  emailTxt.resignFirstResponder()     }
return true
}
    
    
    
// MARK: - BACK BUTTON
@IBAction func backButt(_ sender: AnyObject) {
    dismiss(animated: true, completion: nil)
}
    
    

// MARK: - TERMS OF USE BUTTON
@IBAction func touButt(_ sender: AnyObject) {
    let touVC = self.storyboard?.instantiateViewController(withIdentifier: "TermsOfUse") as! TermsOfUse
    present(touVC, animated: true, completion: nil)
}
    
    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
