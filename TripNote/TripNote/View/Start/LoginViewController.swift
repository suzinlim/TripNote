//
//  LoginViewController.swift
//  TripNote
//
//  Created by 임수진 on 6/12/24.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextField()
        configureView()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    private func setTextField() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
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
        guard let tabBarVC = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController else { return }
        tabBarVC.modalPresentationStyle = .fullScreen
        self.present(tabBarVC, animated: true)
    }
    
    private func checkCompletedButtonActivation() {
        // 텍스트 필드가 비어있는지 확인
        let emailTextFieldEmpty = emailTextField.text?.isEmpty ?? true
        let passwordTextFieldEmpty = passwordTextField.text?.isEmpty ?? true
        
        // 텍스트 필드 입력 여부에 따라 버튼 활성화 여부 결정
        let allTextFieldsFilled = !emailTextFieldEmpty && !passwordTextFieldEmpty
        
        // 모든 조건이 충족되었을 때 로그인 버튼 활성화
        if allTextFieldsFilled {
            loginButton.isUserInteractionEnabled = true
        } else {
            loginButton.isUserInteractionEnabled = false
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        checkCompletedButtonActivation()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // 백 스페이스 실행 가능하도록 함
        if let char = string.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if (isBackSpace == -92) {
                return true
            }
        }
        return true
    }
}

