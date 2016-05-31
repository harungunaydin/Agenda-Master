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
    let usernameTextField: UITextField = UITextField()
    let passwordTextField: UITextField = UITextField()
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        dispatch_async(dispatch_get_main_queue() , {
            self.view.endEditing(true)
            self.loginButtonDidTapped()
        })
        
        return false
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        dispatch_async(dispatch_get_main_queue() , {
            textField.placeholder = nil
        })
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        dispatch_async(dispatch_get_main_queue() , {
            textField.placeholder = textField.hash == self.usernameTextFieldHash ? "username" : "password"
        })
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        dispatch_async(dispatch_get_main_queue() , {
            self.view.endEditing(true)
        })
    }
    
    func login() {
        
        let url:NSURL = NSURL(string: "http://clockblocked.us/~brian/resources/php/ios_get_tasks.php?username=" + usernameTextField.text! + "&password=" + passwordTextField.text! + "&ios_getcode=bb7427431a38")!
        
        let urlSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        let myQuery = urlSession.dataTaskWithURL(url, completionHandler: {
            data, response, error -> Void in
            
            if error != nil {
                self.displayAlert("Error", message: "Please check you internet connection")
            } else {
                
                if let content = data {
                    do {
                        _ = try NSJSONSerialization.JSONObjectWithData(content, options: NSJSONReadingOptions.MutableContainers)
                        
                        NSUserDefaults.standardUserDefaults().setObject(self.usernameTextField.text, forKey: "Agenda_Master_username")
                        NSUserDefaults.standardUserDefaults().setObject(self.passwordTextField.text, forKey: "Agenda_Master_password")
                        NSUserDefaults.standardUserDefaults().setObject(true, forKey: "isSignedInAgendaMaster")
                        
                        AuthorizationsViewController().pullEvents()
                        
                        self.displayAlert("Success", message: "You have succesfully linked your calendar")
                        
                        
                        
                    } catch {
                        self.displayAlert("Error", message: "The username and password you entered do not match")
                    }
                    
                    
                }
                
            }
            
        })
        
        myQuery.resume()
        
    }
    
    func loginButtonDidTapped() {
        
        if usernameTextField.text == nil || passwordTextField.text == nil ||  usernameTextField.text == "" || passwordTextField.text == "" {
            self.displayAlert("Error" , message: "Please fill out both fields")
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
        
            let topx: CGFloat = 72
            let topy: CGFloat = 340
            let height: CGFloat = 35
            let width: CGFloat = 230
        
            self.usernameTextField.frame = CGRectMake(topx,topy,width,height)
            self.usernameTextField.placeholder = "username"
            self.usernameTextField.backgroundColor = UIColor.clearColor()
            self.usernameTextField.autocorrectionType = UITextAutocorrectionType.No
            self.usernameTextField.setBottomBorder(UIColor.darkGrayColor())
            self.usernameTextFieldHash = self.usernameTextField.hash
        
            self.passwordTextField.frame = CGRectMake(topx,topy+40,width,height)
            self.passwordTextField.placeholder = "password"
            self.passwordTextField.backgroundColor = UIColor.clearColor()
            self.passwordTextField.secureTextEntry = true
            self.passwordTextField.setBottomBorder(UIColor.darkGrayColor())
            self.passwordTextFieldHash = self.passwordTextField.hash
        
            self.usernameTextField.delegate = self
            self.passwordTextField.delegate = self
        
            let loginButton = ZFRippleButton(type: .Custom)
        
            loginButton.frame = CGRectMake(topx, topy+130, width, height+5)
            loginButton.layer.cornerRadius = 18
            loginButton.setTitle("LOGIN", forState: .Normal)
            loginButton.backgroundColor = UIColor.redColor()
            loginButton.addTarget(self, action: #selector(self.loginButtonDidTapped), forControlEvents: UIControlEvents.TouchUpInside)
        
            let orText = UITextView(frame: CGRectMake(topx, topy+175, width, height))
        
            orText.text = "OR"
            orText.textAlignment = NSTextAlignment.Center
            orText.alpha = 0.7
            orText.backgroundColor = UIColor.clearColor()
        
            let registerButton  = ZFRippleButton(type: .Custom)
        
            registerButton.frame = CGRectMake(topx, topy+210, width, height+5)
            registerButton.layer.cornerRadius = 18
            registerButton.setTitle("REGISTER" , forState:  .Normal)
            registerButton.backgroundColor = UIColor.redColor()
            registerButton.addTarget(self, action: #selector(self.registerButtonDidTapped), forControlEvents: UIControlEvents.TouchUpInside)
        
            self.view.addSubview(self.usernameTextField)
            self.view.addSubview(self.passwordTextField)
            self.view.addSubview(loginButton)
            self.view.addSubview(orText)
            self.view.addSubview(registerButton)
            
        })
    }
    
    //This is different than other displayAlerts in the project
    func displayAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction((UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
          
            dispatch_async(dispatch_get_main_queue(), {
                
                // First dismiss the Alert then LoginViewController
                self.dismissViewControllerAnimated(true, completion: nil)
                self.navigationController!.popViewControllerAnimated(true)
                
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
