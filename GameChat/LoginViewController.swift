//
//  ViewController.swift
//  GameChat
//
//  Created by ido talmor on 25/12/2017.
//  Copyright © 2017 idotalmor. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FBSDKLoginKit
import SDWebImage
import FirebaseStorage


class LoginViewController: UIViewController,FBSDKLoginButtonDelegate {
    
    //MARK: Constant
    
    let signUpSegue = "SignUp"
    let LoginToChatStoryboard = "LoginToChatStoryboard"
    var uEmail : String = ""
    var uPassword : String = ""
    
    //MARK: Outlets

    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBAction func loginFunc(_ sender: UIButton) {

        //check credentials input
        
        guard let mail = userEmail.text, mail != "" else {misAlert("Please provide an email")
            return}
        
        guard let password = userPassword.text, password != "" else {misAlert("Please provide a password")
            return}
        
        //try to login to Firebase
        
        Auth.auth().signIn(withEmail: mail, password: password) { (user, error) in
            
            if(error != nil){
            if let errorcode = AuthErrorCode(rawValue: error!._code){
                switch errorcode{
                case .accountExistsWithDifferentCredential :self.misAlert("There is another user with the same mail address")
                default : self.misAlert("We Couldn't Sign you in with these credentials")
                }
                }}
            
            //if user exist segue
            
            if (user != nil) {

                self.navigationController?.performSegue(withIdentifier: self.LoginToChatStoryboard, sender: nil)
            }
        }
    }
    
    func misAlert(_ msg:String){
        let alert = UIAlertController(title: "Login Failed", message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        userEmail.text = uEmail
        userPassword.text = uPassword
//        userEmail.text = "talmorid@gmail.com"
//        userPassword.text = "1122345678"
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let backgroundImg:UIImage = UIImage(named: "appbg")!
        let backgroundImgView = UIImageView(image: backgroundImg)
        self.view.insertSubview(backgroundImgView, at: 0)

        let d = UIApplication.shared.delegate as! AppDelegate
        if(d.IsFirstLaunch){

                UIView.animate(withDuration: 0.4, delay: 0.1,
                               options: .curveEaseIn,
                               animations: {
                                self.userEmail.center.x += self.view.bounds.width
                },
                               completion: nil
                )

                UIView.animate(withDuration: 0.4, delay: 0.4,
                               options: .curveEaseIn,
                               animations: {
                                self.userPassword.center.x += self.view.bounds.width
                },
                               completion: nil
                )
                UIView.animate(withDuration: 0.4, delay: 0.7,
                               options: .curveEaseIn,
                               animations: {
                                self.loginBtn.center.x += self.view.bounds.width
                },
                               completion: { finished in d.IsFirstLaunch = false}
                )
        }
        
        //facebook
        let fbLoginBtn = FBSDKLoginButton()
        fbLoginBtn.readPermissions = ["email", "public_profile"]
        let newCenter = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height - 60)
        fbLoginBtn.center = newCenter
        self.view.addSubview(fbLoginBtn)
        fbLoginBtn.delegate = self

        
    }

}

typealias Json = [String : Any]

//facebook handler

extension LoginViewController{
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        //if fb user logged out
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if(error != nil){
            self.misAlert("Login Using Facebook Has Failed")
            return
        }
        
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else {return}
        let credentials = FacebookAuthProvider.credential(withAccessToken:accessTokenString)
        Auth.auth().signIn(with: credentials) { (user, error) in
            
            if(error != nil){
                if let errorcode = AuthErrorCode(rawValue: error!._code){
                    switch errorcode{
                    case .accountExistsWithDifferentCredential :self.misAlert("There is another user with the same mail address")
                    default : self.misAlert("We Couldn't Sign you in with these credentials")
                    }
                }
                //logout user if couldn't signin to firebase using these credentials
                let loginManager = FBSDKLoginManager()
                loginManager.logOut()
                return
            }
            
            //if the user successfully logged in
            if(user != nil){
                let userReference = Database.database().reference(withPath: "Users/"+user!.uid+"/User")
                
                ///if user is not exists in our database - create the user database
                userReference.child("userId").observe(.value, with: { (datasnapshot) in
                    if !datasnapshot.exists() {
                        let user : Json = ["userId":user?.uid,"email":user?.email,"displayName":user?.displayName,"phoneNumber":user?.phoneNumber,"photoURL":user?.photoURL?.absoluteString]
                        userReference.setValue(user)}
                    
                })
                self.navigationController?.performSegue(withIdentifier: self.LoginToChatStoryboard, sender: nil)
                
            }
            
            
        }//Signin
        

    }//loginButton
    
}

