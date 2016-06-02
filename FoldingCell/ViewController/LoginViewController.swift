//
//  LoginViewController.swift
//  AgendaMaster
//
//  Created by Harun Gunaydin on 4/28/16.
//  Copyright © 2016 Harun Gunaydin. All rights reserved.
//

import UIKit
import ZFRippleButton

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    var usernameTextFieldHash: Int!
    var passwordTextFieldHash: Int!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: ZFRippleButton!
    @IBOutlet weak var registerButton: ZFRippleButton!
    
    @IBOutlet weak var orText: UILabel!
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        self.loginButtonDidTapped()
        
        return false
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.placeholder = nil
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.placeholder = textField.hash == self.usernameTextFieldHash ? "username" : "password"
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func login() {
        
        let url:NSURL = NSURL(string: "http://clockblocked.us/~brian/resources/php/ios_get_tasks.php?username=" + usernameTextField.text! + "&password=" + passwordTextField.text! + "&ios_getcode=bb7427431a38")!
        
        let urlSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        let myQuery = urlSession.dataTaskWithURL(url, completionHandler: {
            data, response, error -> Void in
            
            if error != nil {
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.displayAlert("Error", message: "Please check you internet connection" , pop: false )
                })
                
            } else {
                
                if let content = data {
                    do {
                        _ = try NSJSONSerialization.JSONObjectWithData(content, options: NSJSONReadingOptions.MutableContainers)
                        
                        NSUserDefaults.standardUserDefaults().setObject(self.usernameTextField.text, forKey: "Agenda_Master_username")
                        NSUserDefaults.standardUserDefaults().setObject(self.passwordTextField.text, forKey: "Agenda_Master_password")
                        NSUserDefaults.standardUserDefaults().setObject(true, forKey: "isSignedInAgendaMaster")
                        
                        AuthorizationsViewController().pullEvents()
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            self.displayAlert("Success", message: "You have succesfully linked your calendar" , pop: true )
                        })
                        
                        
                        
                        
                    } catch {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.displayAlert("Error", message: "The username and password you entered do not match" , pop: false)
                        })
                    }
                    
                    
                }
                
            }
            
        })
        
        myQuery.resume()
        
    }
    
    func loginButtonDidTapped() {
        
        if usernameTextField.text == nil || passwordTextField.text == nil ||  usernameTextField.text == "" || passwordTextField.text == "" {
            self.displayAlert("Error" , message: "Please fill out both fields" , pop: false)
        } else {
            self.login()
        }
        
    }
    
    func registerButtonDidTapped() {
        print("Implement registerButtonDidTapped")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dispatch_async(dispatch_get_main_queue(), {
        
            self.usernameTextField.bounds = CGRect(x: self.usernameTextField.bounds.minX, y: self.usernameTextField.bounds.minY, width: self.usernameTextField.bounds.width, height: self.usernameTextField.bounds.height + 5)
            self.usernameTextField.backgroundColor = UIColor.clearColor()
            self.usernameTextField.setBottomBorder(UIColor.darkGrayColor())
            self.usernameTextFieldHash = self.usernameTextField.hash
            
            self.passwordTextField.bounds = CGRect(x: self.passwordTextField.bounds.minX, y: self.passwordTextField.bounds.minY, width: self.passwordTextField.bounds.width, height: self.passwordTextField.bounds.height + 5)
            self.passwordTextField.backgroundColor = UIColor.clearColor()
            self.passwordTextField.setBottomBorder(UIColor.darkGrayColor())
            self.passwordTextFieldHash = self.passwordTextField.hash
        
            self.usernameTextField.delegate = self
            self.passwordTextField.delegate = self
        
            self.loginButton.layer.cornerRadius = 18
            self.loginButton.backgroundColor = UIColor.redColor()
            self.loginButton.addTarget(self, action: #selector(self.loginButtonDidTapped), forControlEvents: UIControlEvents.TouchUpInside)
            
            self.orText.backgroundColor = UIColor.clearColor()
        
            self.registerButton.layer.cornerRadius = 18
            self.registerButton.backgroundColor = UIColor.redColor()
            self.registerButton.addTarget(self, action: #selector(self.registerButtonDidTapped), forControlEvents: UIControlEvents.TouchUpInside)
            
        })
    }
    
    //This is different than other displayAlerts in the project
    func displayAlert(title: String, message: String, pop: Bool) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction((UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
          
            dispatch_async(dispatch_get_main_queue(), {
                
                // First dismiss the Alert then LoginViewController
                self.dismissViewControllerAnimated(true, completion: nil)
                if pop == true {
                    self.navigationController!.popViewControllerAnimated(true)
                }
                
            })
            
            
        })))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
