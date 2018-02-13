//
//  SignupViewController.swift
//  GameChat
//
//  Created by ido talmor on 26/12/2017.
//  Copyright © 2017 idotalmor. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

class SignupViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIGestureRecognizerDelegate {

    //Mark: constant
    var userName:String = ""
    var userEmail:String = ""
    var userPassword:String = ""
    var userPhoneNumber:String = ""
    var profileImg:UIImage?

    let createusersegue:String = "CreateUser"
    
    //MARK: Outlets
    
    @IBOutlet weak var profileImgView: UIImageView!
    
    @IBOutlet weak var signName: UITextField!
    
    @IBOutlet weak var signEmail: UITextField!
    
    @IBOutlet weak var signPhoneNumber: UITextField!
    
    @IBOutlet weak var signPassword: UITextField!
    

    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        profileImg = image
        profileImgView.image = profileImg
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let dest = segue.destination as? CreateUserViewController else {return}
        dest.userName = self.userName
        dest.userEmail = self.userEmail
        dest.userPassword = self.userPassword
        dest.userPhoneNumber = self.userPhoneNumber

        if (profileImg != nil){
            dest.profileImg = self.profileImg
        }

    }
    
    @IBAction func signunFunc(_ sender: UIButton) {
    
        //check user input textfields
        guard let name = signName.text, name != "" else{misAlert("Please provide a userame")
            return
        }
        guard let email = signEmail.text, email != "" else{misAlert("Please provide an email")
            return
        }

        guard let password = signPassword.text, password != "" else {misAlert("Please provide a password")
            return
        }

        self.userName = name
        self.userEmail = email
        self.userPassword = password
        if(signPhoneNumber.text != nil){
            self.userPhoneNumber = signPhoneNumber.text!
        }

        performSegue(withIdentifier: "CreateUser", sender: self)

    }
    
    func misAlert(_ string : String){
        let alert = UIAlertController(title: "Signup Failed", message: string, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.isTranslucent = false;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let backgroundImg:UIImage = UIImage(named: "appbg")!
        let backgroundImgView = UIImageView(image: backgroundImg)
        self.view.insertSubview(backgroundImgView, at: 0)
        
        let UITapRecognizer = UITapGestureRecognizer(target: self, action:#selector(addImg(UITapRecognizer:)))
        UITapRecognizer.delegate = self
        self.profileImgView.addGestureRecognizer(UITapRecognizer)
        self.profileImgView.isUserInteractionEnabled = true
        
        self.profileImgView.layer.cornerRadius = self.profileImgView.frame.size.width / 2;
        self.profileImgView.clipsToBounds = true;
        
    }
    
    @objc func addImg(UITapRecognizer: UITapGestureRecognizer){
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = .photoLibrary
        present(controller, animated: true, completion: nil)
    }

}
