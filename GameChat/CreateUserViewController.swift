//
//  CreateUserViewController.swift
//  GameChat
//
//  Created by ido on 14/01/2018.
//  Copyright © 2018 idotalmor. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import Firebase

class CreateUserViewController: UIViewController {
    
    //MARK: Variables
    let LoginToChatStoryboard = "LoginToChatStoryboard"
    let resetSegue = "CreateToReset"
    var counter:Int = 0{
        didSet{
            if(counter>=2){
                //if user is created and signin, and picture was handled
                self.navigationController?.performSegue(withIdentifier: self.LoginToChatStoryboard, sender: nil)
        }
        }}
    var userName:String?
    var userEmail:String?
    var userPassword:String?
    var userPhoneNumber:String = ""
    var profileImg:UIImage?
    var userReference : DatabaseReference?
    
    var backgroundImgView:UIImageView?
    var myTimer: Timer?
    
    
    //MARK: Outlets
    
    @IBOutlet weak var profileImgView: UIImageView!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Create bg image and add to main view at index 0
        let backgroundImg:UIImage = UIImage(named: "createuserbg")!
        backgroundImgView = UIImageView(image: backgroundImg)
        self.view.insertSubview(backgroundImgView!, at: 0)
        
        self.profileImgView.layer.cornerRadius = self.profileImgView.frame.size.width / 2;
        self.profileImgView.clipsToBounds = true;
        if(profileImg != nil){
            profileImgView.image = profileImg}
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //Moving bg image to animation starting position
        self.backgroundImgView?.frame.origin.x = -(self.backgroundImgView?.frame.origin.x)! - (self.backgroundImgView?.bounds.width)! + self.view.bounds.width

        //Start animate bg image
        UIView.animate(withDuration: 60, delay: 0, options: [.repeat,.curveLinear], animations: {
            self.backgroundImgView?.frame.origin.x = 0
        }, completion: nil)
        
        //3 sec to complete progressbar if there is no picture to upload
        if (profileImg == nil){
            myTimer = Timer.scheduledTimer(timeInterval: 0.3, target:self, selector: #selector(self.updateProgress), userInfo: nil, repeats: true)
        }
        
        //start creating Firebase User
        Auth.auth().createUser(withEmail: self.userEmail!, password: self.userPassword!) { (user, err) in
            
            //error handling
            if err != nil{
                if let errorcode = AuthErrorCode(rawValue: err!._code){
                    switch errorcode {
                    case .weakPassword: self.errAlert(Title: "Signup Failed",Massage: "Please provide a stronger password",Handler:self.backToSignup)
                    case .emailAlreadyInUse:self.samemailAlert()
                    default : self.errAlert(Title: "Signup Failed", Massage: "There was some problems during signup process",Handler:self.backToSignup)
                    }
                }
            }
            
            //If a new user has been created successfully
            if (user != nil){
                //signin user
                Auth.auth().signIn(withEmail: self.userEmail!, password: self.userPassword!, completion: { (sUser, err) in
                    
                    if (err != nil){
                        self.errAlert(Title: "Sorry, but we're having trouble signing you in", Massage: "Please try again later", Handler: self.backToSignin)
                    }
                    
                    //if user signin properly
                    if(sUser != nil){
                        self.userReference = Database.database().reference(withPath: "Users/"+sUser!.uid+"/User")
                        //Start Uploading profile image if needed
                        if(self.profileImg != nil){
                            self.uploadImg(user: sUser)
                        }
                        self.updateUserName()

                        //make User json in database
                        let user : Json = ["userId":sUser?.uid,"email":self.userEmail,"displayName":self.userName,"phoneNumber":self.userPhoneNumber]
                        //create in db user
                        
                        self.userReference!.updateChildValues(user)
                        self.counter += 1
                        
                    }
                    
                })
            }
            
        }
    }//viewDidAppear
    
    //update progress func when no picture need to be uploaded
    @objc func updateProgress(){
        self.progressBar.progress += 0.1
        if(self.progressBar.progress >= 1){
            counter += 1
            myTimer?.invalidate()
        }
    }
    

    func uploadImg(user:User?){
        guard let data = UIImageJPEGRepresentation(self.profileImg!, 1) else{return}
        let storageRef = Storage.storage().reference()
        let photoref = storageRef.child("users/"+(user?.uid)!+"/Profile.jpg")
        
        //upload img and update user photoURL property
        let uploadTask = photoref.putData(data, metadata: nil) { (metadata, err) in
            
            if(err != nil){
                //error while trying to upload
                self.errAlert(Title: "we encountered a problem while updating your profile picture", Massage: "Please try again later", Handler: nil)
                return}
            
            //Check for metadata - matadata contains details such as pic size content-type and download url
            guard let md = metadata else {return}
            
            //after uploading img we need to add the img link to user profile
            guard let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() else{return}
            changeRequest.photoURL = md.downloadURL()
            changeRequest.commitChanges(completion: { (error) in
                
                //if error has occurred while trying to add photoURL property
                if (error != nil){
                    self.errAlert(Title: "we encountered a problem while updating your profile picture", Massage: "Please try again later", Handler: nil)
                    return
                }
            })
            
            //add the link to user object in database
            self.userReference?.updateChildValues(["photoURL":(md.downloadURL()?.absoluteString)])
            
        }
        
        //observing uploading img
        uploadTask.observe(.progress) { (snapshot) in
            let percentComplete = Double(snapshot.progress!.completedUnitCount)
                / Double(snapshot.progress!.totalUnitCount)
            self.progressBar.progress = Float(percentComplete)
        }
        //is upload success counter +1
        uploadTask.observe(.success) { (snapshot) in
            self.counter += 1
        }
        uploadTask.observe(.failure) { (snapshot) in
            self.errAlert(Title: "we encountered a problem while updating your profile picture", Massage: "Please try again later", Handler: nil)
            self.counter += 1
        }
    }
    
    func updateUserName(){
        guard let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest() else{return}
        changeRequest.displayName = self.userName
        changeRequest.commitChanges(completion: { (err) in
            //error while trying to update user name
            if(err != nil){
                self.errAlert(Title: "we encountered a problem while updating your user name", Massage: "Please try again later", Handler: nil)}
        })
    }
    
    func errAlert(Title ttl : String ,Massage msg : String ,Handler:((_ alert: UIAlertAction?)->Void)?){
        let alert = UIAlertController(title: ttl, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: Handler)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func samemailAlert(){
        let alert = UIAlertController(title: "Signup Failed", message: "The email you provided is already in use.", preferredStyle: .alert)
        let signupaction = UIAlertAction(title: "Go Back", style: .default, handler: self.backToSignup)
        let loginaction = UIAlertAction(title: "Login", style: .default, handler: self.backToSignin)
        let forgotpasswordaction = UIAlertAction(title: "Forget Password?", style: .default, handler: self.forgetPasswordSegue)

        alert.addAction(signupaction)
        alert.addAction(loginaction)
        alert.addAction(forgotpasswordaction)
        present(alert, animated: true, completion: nil)
    }
    
    func backToSignup(alert: UIAlertAction!){
        myTimer?.invalidate()
        //performSegue(withIdentifier: self.backToSignUpSegue, sender: self)
        self.navigationController?.popViewController(animated: true)
    }
    
    func backToSignin(alert: UIAlertAction!){
        myTimer?.invalidate()
        //pop to first viewcontroller in stack(login viewcontroller) and transfer data
        if let rootVC = navigationController?.viewControllers.first as? LoginViewController {
            rootVC.uEmail = self.userEmail!
            rootVC.uPassword = self.userPassword!
        }
        navigationController?.popToRootViewController(animated: true)
    }
    
    func forgetPasswordSegue(alert: UIAlertAction!){
        myTimer?.invalidate()
        performSegue(withIdentifier: self.resetSegue, sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if(segue.identifier == self.resetSegue){
            guard let dest = segue.destination as? ResetPasswordViewController else {return}
            dest.email = self.userEmail!
        }
    }
}





