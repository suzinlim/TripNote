//
//  SignUpViewController.swift
//  TripNote
//
//  Created by 임수진 on 6/12/24.
//

import UIKit

class SignUpViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var password2TextField: UITextField!
    @IBOutlet weak var completedButton: UIButton!
    @IBOutlet weak var emailCheckButton: UIButton!
    
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
        nickNameTextField.delegate = self
        passwordTextField.delegate = self
        password2TextField.delegate = self
    }
    
    private func configureView() {
        // 뒤로가기 버튼
        let backbutton = UIBarButtonItem(image: UIImage(named: "back"), style: .done, target: self, action: #selector(backButtonTapped))
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.leftBarButtonItem = backbutton
        
        // 이메일 중복 확인 버튼
        emailCheckButton.layer.cornerRadius = 6
        
        // 완료 버튼
        completedButton.isUserInteractionEnabled = false
        completedButton.layer.cornerRadius = 10
    }
    
    @objc func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        guard let startVC = self.storyboard?.instantiateViewController(withIdentifier: "startViewController") as? StartViewController else { return }
        self.navigationController?.pushViewController(startVC, animated: true)
    }
    
    // TODO: 이메일 중복 확인 검사
    @IBAction func checkButtonTapped(_ sender: UIButton) {
        
    }
    
    private func checkCompletedButtonActivation() {
        // 텍스트 필드가 비어있는지 확인
        let emailTextFieldEmpty = emailTextField.text?.isEmpty ?? true
        let nickNameTextFieldEmpty = nickNameTextField.text?.isEmpty ?? true
        let passwordTextFieldEmpty = passwordTextField.text?.isEmpty ?? true
        let password2TextFieldEmpty = password2TextField.text?.isEmpty ?? true
        
        // 텍스트 필드 입력 여부에 따라 다음으로 버튼 활성화 여부 결정
        let allTextFieldsFilled = !emailTextFieldEmpty && !nickNameTextFieldEmpty && !passwordTextFieldEmpty && !password2TextFieldEmpty
        
        // 모든 조건이 충족되었을 때 다음으로 버튼 활성화
        if allTextFieldsFilled {
            completedButton.isUserInteractionEnabled = true
        } else {
            completedButton.isUserInteractionEnabled = false
        }
    }
}

extension SignUpViewController: UITextFieldDelegate {
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
