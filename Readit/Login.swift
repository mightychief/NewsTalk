/*---------------------------------
 
 - Readit -
 
 created by FV iMAGINATION ©2016
 All Rights reserved
 
 -----------------------------------*/


import UIKit
import Parse


class Login: UIViewController,
    UITextFieldDelegate,
    UIAlertViewDelegate
{
    
    /* Views */
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    
    
   
    
    
override func viewWillAppear(_ animated: Bool) {
    if PFUser.current() != nil {  dismiss(animated: false, completion: nil) }
}
override func viewDidLoad() {
        super.viewDidLoad()
    
    
    // Setup layouts
    containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width, height: 550)
    
    // SET COLOR OF PLACEHOLDERS
    let color = UIColor.white
    usernameTxt.attributedPlaceholder = NSAttributedString(string: "username", attributes: [NSForegroundColorAttributeName: color])
    passwordTxt.attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSForegroundColorAttributeName: color])
}
    
   
// MARK: - LOGIN BUTTON
@IBAction func loginButt(_ sender: AnyObject) {
    dismissKeyboard()
    showHUD()
        
    PFUser.logInWithUsername(inBackground: usernameTxt.text!, password:passwordTxt.text!) { (user, error) -> Void in
        // Login successfull
        if user != nil {
            self.dismiss(animated: true, completion: nil)
            self.hideHUD()
                
        // Login failed. Try again or SignUp
        } else {
            let alert = UIAlertView(title: APP_NAME,
                message: "\(error!.localizedDescription)",
                delegate: self,
                cancelButtonTitle: "Retry",
                otherButtonTitles: "Sign Up")
            alert.show()
            self.hideHUD()
    } }
}
// AlertView delegate
func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
    if alertView.buttonTitle(at: buttonIndex) == "Sign Up" {
        signupButt(self)
    }
    if alertView.buttonTitle(at: buttonIndex) == "Reset Password" {
        PFUser.requestPasswordResetForEmail(inBackground: "\(alertView.textField(at: 0)!.text!)")
        showNotifAlert()
    }
}
    
    
// MARK: - SIGNUP BUTTON
@IBAction func signupButt(_ sender: AnyObject) {
    let signupVC = self.storyboard?.instantiateViewController(withIdentifier: "SignUp") as! SignUp
    present(signupVC, animated: true, completion: nil)
}
    
    
    
// MARK: - TEXTFIELD DELEGATES
func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == usernameTxt  {  passwordTxt.becomeFirstResponder() }
    if textField == passwordTxt  {  passwordTxt.resignFirstResponder() }
return true
}
    
    
// MARK: - TAP TO DISMISS KEYBOARD
@IBAction func tapToDismissKeyboard(_ sender: UITapGestureRecognizer) {
    dismissKeyboard()
}
func dismissKeyboard() {
    usernameTxt.resignFirstResponder()
    passwordTxt.resignFirstResponder()
}

// MARK: - CLOSE BUTTON
@IBAction func closeButt(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
}
    
// MARK: - FORGOT PASSWORD BUTTON
@IBAction func forgotPasswButt(_ sender: AnyObject) {
    let alert = UIAlertView(title: APP_NAME,
        message: "Type your email address you used to register.",
        delegate: self,
        cancelButtonTitle: "Cancel",
        otherButtonTitles: "Reset Password")
    alert.alertViewStyle = UIAlertViewStyle.plainTextInput
    alert.show()
}
    
// MARK: - NOTIFICATION ALERT FOR PASSWORD RESET
func showNotifAlert() {
    simpleAlert("You will receive an email shortly with a link to reset your password")
}
    
    

    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
