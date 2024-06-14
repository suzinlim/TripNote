//
//  LoginViewController.swift
//  TripNote
//
//  Created by 임수진 on 6/12/24.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var emailErrorLabel: UILabel!
    var passwordErrorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextFieldDelegate()
        setupErrorLabels()
        configureView()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    private func setTextFieldDelegate() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    private func setupErrorLabels() {
        // 이메일 에러 Label
        emailErrorLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = UIColor(named: "Color1")
            $0.isHidden = true
            $0.numberOfLines = 0
        }
        
        // 비밀번호 에러 Label
        passwordErrorLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = UIColor(named: "Color1")
            $0.isHidden = true
            $0.numberOfLines = 0
        }
        
        [emailErrorLabel, passwordErrorLabel].forEach { view.addSubview($0) }
        
        emailErrorLabel.snp.makeConstraints {
            $0.top.equalTo(emailTextField.snp.bottom).offset(4)
            $0.leading.equalTo(emailTextField)
            $0.trailing.equalTo(emailTextField)
        }
        
        passwordErrorLabel.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom).offset(4)
            $0.leading.equalTo(passwordTextField)
            $0.trailing.equalTo(passwordTextField)
        }
    }
    
    private func configureView() {
        // 뒤로가기 버튼
        let backbutton = UIBarButtonItem(image: UIImage(named: "back"), style: .done, target: self, action: #selector(backButtonTapped))
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.leftBarButtonItem = backbutton
        
        // 로그인 버튼
        loginButton.isUserInteractionEnabled = false
        loginButton.layer.cornerRadius = 10
    }
    
    @objc func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else { return }

        // Firebase 로그인
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("로그인 실패: \(error.localizedDescription)")
                self.showError(error: error)
            } else {
                print("로그인 성공")
                
                guard let tabBarVC = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController else { return }
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.rootViewController = tabBarVC
                    UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil, completion: nil)
                }
            }
        }
    }
    
    private func showError(error: Error) {
        let nsError = error as NSError
        switch nsError.code {
        case AuthErrorCode.invalidEmail.rawValue:
            emailErrorLabel.text = "유효하지 않은 이메일 주소입니다."
            emailErrorLabel.isHidden = false
            passwordErrorLabel.isHidden = true
        case AuthErrorCode.userNotFound.rawValue:
            emailErrorLabel.text = "존재하지 않는 계정입니다."
            emailErrorLabel.isHidden = false
            passwordErrorLabel.isHidden = true
        case AuthErrorCode.wrongPassword.rawValue:
            passwordErrorLabel.text = "잘못된 비밀번호입니다."
            passwordErrorLabel.isHidden = false
            emailErrorLabel.isHidden = true
        default:
            emailErrorLabel.isHidden = true
            passwordErrorLabel.text = "로그인에 실패했습니다. 다시 시도해주세요."
            passwordErrorLabel.isHidden = false
        }
    }

    
    private func checkCompletedButtonActivation() {
        // 텍스트 필드가 비어있는지 확인
        let emailFilled = !(emailTextField.text?.isEmpty ?? true)
        let passwordFilled = !(passwordTextField.text?.isEmpty ?? true)
        
        // 모든 조건이 충족되었을 때 로그인 버튼 활성화
        loginButton.isUserInteractionEnabled = emailFilled && passwordFilled
        loginButton.backgroundColor = loginButton.isUserInteractionEnabled ? UIColor(named: "mainColor") : UIColor.opaqueSeparator
    }
}

// -MARK: UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        checkCompletedButtonActivation()
    }
}
