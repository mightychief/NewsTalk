/*---------------------------------
 
 - Readit -
 
 created by FV iMAGINATION ©2016
 All Rights reserved
 
 -----------------------------------*/

import UIKit



class MiniBrowser: UIViewController,
UIWebViewDelegate
{

    /* Views */
    @IBOutlet weak var webView: UIWebView!
    

    
    
    
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

    
    
    

    

    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
