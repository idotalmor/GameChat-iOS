//
//  ResetPasswordViewController.swift
//  GameChat
//
//  Created by ido talmor on 03/02/2018.
//  Copyright © 2018 idotalmor. All rights reserved.
//

import UIKit
import FirebaseAuth

class ResetPasswordViewController: UIViewController {
    
    var email : String = ""

    @IBOutlet weak var resetEmail: UITextField!
    
    
    @IBAction func ResetPassword(_ sender: UIButton) {
        guard let email = resetEmail.text, email != "" else{
            errAlert(Title: "Password Reset Failed", Massage: "Please provide an email",Handler: nil)
            return
        }
        Auth.auth().sendPasswordReset(withEmail: email) { (err) in
            
            if(err != nil){
                self.errAlert(Title: "Password Reset Failed", Massage: "Please try again",Handler: nil)
                return
            }
            
            self.errAlert(Title: "Success!", Massage: "Check Your MailBox!", Handler: self.Success)
       }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
        resetEmail.text = email
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundImg:UIImage = UIImage(named: "appbg")!
        let backgroundImgView = UIImageView(image: backgroundImg)
        self.view.insertSubview(backgroundImgView, at: 0)
        
        self.navigationItem.hidesBackButton = true
       self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(backtoroot(button:)))

    }
    
    
    func errAlert(Title ttl : String ,Massage msg : String ,Handler:((_ alert: UIAlertAction?)->Void)?){
        let alert = UIAlertController(title: ttl, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: Handler)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func backtoroot(button : UIBarButtonItem){
        navigationController?.popToRootViewController(animated: true)}

    func Success(alert: UIAlertAction!){
        //move to root viewcontroller with passing data
        if let rootVC = navigationController?.viewControllers.first as? LoginViewController {
            rootVC.uEmail = self.email
        }
        navigationController?.popToRootViewController(animated: true)
    }

}


