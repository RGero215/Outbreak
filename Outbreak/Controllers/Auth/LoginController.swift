//
//  LoginController.swift
//  Outbreak
//
//  Created by Ramon Geronimo on 3/28/20.
//  Copyright © 2020 Ramon Geronimo. All rights reserved.
//

import LBTATools
import Alamofire
import JGProgressHUD

class LoginController: LBTAFormController {
    // MARK: UI Elements
    
    let yellowColor = UIColor.init(red: 286/255.0, green: 206/255.0, blue: 86/255.0, alpha: 1)
    let darkColor = UIColor.init(red: 71/255.0, green: 71/255.0, blue: 79/255.0, alpha: 1)
    
    let logoImageView = UIImageView(image: #imageLiteral(resourceName: "virus"), contentMode: .scaleAspectFit)
    let logoLabel = UILabel(text: "OUTBREAK", font: .systemFont(ofSize: 50, weight: .heavy), textColor: .black, numberOfLines: 0)
    
    let emailTextField = IndentedTextField(placeholder: "Email", padding: 24, cornerRadius: 25, keyboardType: .emailAddress)
    let passwordTextField = IndentedTextField(placeholder: "Password", padding: 24, cornerRadius: 25)
    lazy var loginButton = UIButton(title: "Login", titleColor: darkColor, font: .boldSystemFont(ofSize: 18), backgroundColor: yellowColor, target: self, action: #selector(handleLogin))
    
    let errorLabel = UILabel(text: "Your login credentials were incorrect, please try again.", font: .systemFont(ofSize: 14), textColor: .red, textAlignment: .center, numberOfLines: 0)
    
    lazy var goToRegisterButton = UIButton(title: "Need an account? Go to register.", titleColor: .black, font: .systemFont(ofSize: 16), target: self, action: #selector(goToRegister))
    
    @objc fileprivate func goToRegister() {
        let controller = RegisterController(alignment: .center)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc fileprivate func handleLogin() {
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Logging in"
        hud.show(in: view)
        
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        errorLabel.isHidden = true
        
        Service.shared.login(email: email, password: password) { (res) in
            hud.dismiss(animated: true)
            
            switch res {
            case .failure(let err):
                print("Failed to sign up:", err)
                self.errorLabel.isHidden = false
            case .success:
                print("Successfully signed in")
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
        
        
        emailTextField.autocapitalizationType = .none
        emailTextField.backgroundColor = .white
        passwordTextField.backgroundColor = .white
        passwordTextField.isSecureTextEntry = true
        setupTextColor(email: emailTextField, password: passwordTextField)
        loginButton.layer.cornerRadius = 25
        navigationController?.navigationBar.isHidden = true
        errorLabel.isHidden = true
        
        let formView = UIView()
        formView.stack(
            formView.stack(formView.stack(logoImageView.withSize(.init(width: view.frame.width, height: view.frame.width)), logoLabel.withWidth(view.frame.width), spacing: 40, alignment: .center).padLeft(12).padRight(12), alignment: .center),
            UIView().withHeight(12),
            emailTextField.withHeight(50),
            passwordTextField.withHeight(50),
            loginButton.withHeight(50),
            errorLabel,
            goToRegisterButton,
            UIView().withHeight(80),
            spacing: 16).withMargins(.init(top: 30, left: 32, bottom: 0, right: 32))
        
        formContainerStackView.padBottom(-24)
        formContainerStackView.addArrangedSubview(formView)
    }
    
    fileprivate func setupTextColor(email: UITextField, password: UITextField) {
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .light {
                //Light mode
                email.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
                email.textColor = .black
                
                password.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
                password.textColor = .black
            } else {
                //DARK
                email.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
                email.textColor = .black
                
                password.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
                password.textColor = .black
            }
        } else {
            // Fallback on earlier versions
            email.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
            email.textColor = .black
            
            password.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
            password.textColor = .black
        }
    }
}
