//
//  RegisterController.swift
//  Outbreak
//
//  Created by Ramon Geronimo on 3/28/20.
//  Copyright © 2020 Ramon Geronimo. All rights reserved.
//

import LBTATools
import Alamofire
import JGProgressHUD

class RegisterController: LBTAFormController {
    // MARK: UI ELEMENTS
    
   let yellowColor = UIColor.init(red: 286/255.0, green: 206/255.0, blue: 86/255.0, alpha: 1)
   let darkColor = UIColor.init(red: 71/255.0, green: 71/255.0, blue: 79/255.0, alpha: 1)
   
   let logoImageView = UIImageView(image: #imageLiteral(resourceName: "virus"), contentMode: .scaleAspectFit)
   let logoLabel = UILabel(text: "OUTBREAK", font: .systemFont(ofSize: 50, weight: .heavy), textColor: .black, numberOfLines: 0)
    
    let fullNameTextField = IndentedTextField(placeholder: "Full Name", padding: 24, cornerRadius: 25)
    let emailTextField = IndentedTextField(placeholder: "Email", padding: 24, cornerRadius: 25)
    let passwordTextField = IndentedTextField(placeholder: "Password", padding: 24, cornerRadius: 25, isSecureTextEntry: true)
    lazy var signUpButton = UIButton(title: "Sign Up", titleColor: darkColor, font: .boldSystemFont(ofSize: 18), backgroundColor: yellowColor, target: self, action: #selector(handleSignup))
    
    let errorLabel = UILabel(text: "Something went wrong during sign up, please try again later.", font: .systemFont(ofSize: 14), textColor: .red, textAlignment: .center, numberOfLines: 0)
    
    lazy var goBackButton = UIButton(title: "Go back to login.", titleColor: .black, font: .systemFont(ofSize: 16), target: self, action: #selector(goToRegister))
    
    @objc fileprivate func goToRegister() {
        navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSignup()
        return true
    }
    
    @objc fileprivate func handleSignup() {
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Registering"
        hud.show(in: view)
        
        guard let fullName = fullNameTextField.text else { return }
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        Service.shared.signUp(fullName: fullName, emailAddress: email, password: password) { (res) in
            
            hud.dismiss(animated: true)
            
            switch res {
            case .failure(let err):
                print("Failed to sign up:", err)
                self.errorLabel.isHidden = false
            case .success:
                print("Successfully signed up")
                self.dismiss(animated: true)
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = darkColor
        logoImageView.layer.cornerRadius = 16
        logoImageView.backgroundColor = .black
        logoImageView.contentMode = .scaleAspectFill
        logoLabel.textColor = yellowColor
        logoLabel.textAlignment = .center
        
        errorLabel.isHidden = true
        emailTextField.autocapitalizationType = .none
        [fullNameTextField, emailTextField, passwordTextField].forEach{$0.backgroundColor = .white}
        signUpButton.layer.cornerRadius = 25
        setupTextColor(fullName: fullNameTextField, email: emailTextField, password: passwordTextField)
        
        let formView = UIView()
        formView.stack(
            formView.stack(formView.stack(logoImageView.withSize(.init(width: view.frame.width, height: view.frame.width)), logoLabel.withWidth(view.frame.width), spacing: 20, alignment: .center).padLeft(12).padRight(12), alignment: .center),
//            UIView().withHeight(12),
            fullNameTextField.withHeight(50),
            emailTextField.withHeight(50),
            passwordTextField.withHeight(50),
            errorLabel,
            signUpButton.withHeight(50),
            goBackButton,
//            UIView().withHeight(80),
            spacing: 16).withMargins(.init(top: view.frame.width, left: 32, bottom: 0, right: 32))
        
        formContainerStackView.addArrangedSubview(formView)
        
        UIView.animate(withDuration: 0.10) {
            let centerOffsetX = (self.scrollView.contentSize.width - self.scrollView.frame.size.width) / 2
            let centerOffsetY = (self.scrollView.contentSize.height - self.scrollView.frame.size.height) / 2
            let centerPoint = CGPoint(x: centerOffsetX, y: centerOffsetY)
            
            self.scrollView.setContentOffset(centerPoint, animated: true)
           
        }
        
      
    }
    
    
    
    
    fileprivate func setupTextColor(fullName: UITextField, email: UITextField, password: UITextField) {
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .light {
                //Light mode
                email.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
                email.textColor = .black
                
                password.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
                password.textColor = .black
                
                fullName.attributedPlaceholder = NSAttributedString(string: "Full Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
                fullName.textColor = .black
            } else {
                //DARK
                email.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
                email.textColor = .black
                
                password.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
                password.textColor = .black
                
                fullName.attributedPlaceholder = NSAttributedString(string: "Full Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
                fullName.textColor = .black
            }
        } else {
            // Fallback on earlier versions
            email.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
            email.textColor = .black
            
            password.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
            password.textColor = .black
            
            fullName.attributedPlaceholder = NSAttributedString(string: "Full Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
            fullName.textColor = .black
        }
    }
}
