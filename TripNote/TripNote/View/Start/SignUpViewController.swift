//
//  SignUpViewController.swift
//  TripNote
//
//  Created by 임수진 on 6/12/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var password2TextField: UITextField!
    @IBOutlet weak var completedButton: UIButton!
    @IBOutlet weak var emailCheckButton: UIButton!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var password2Label: UILabel!
    
    
    var emailErrorLabel: UILabel!
    var nickNameErrorLabel: UILabel!
    var passwordErrorLabel: UILabel!
    var password2ErrorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupErrorLabels()
        setTextFieldDelegate()
        configureView()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func setupErrorLabels() {
        // 이메일 에러 Label
        emailErrorLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = UIColor(named: "Color1")
            $0.isHidden = true
        }
        
        // 닉네임 에러 Label
        nickNameErrorLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = UIColor(named: "Color1")
            $0.isHidden = true
        }
        
        // 비밀번호 에러 Label
        passwordErrorLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = UIColor(named: "Color1")
            $0.isHidden = true
            $0.numberOfLines = 0
        }
        
        // 비밀번호 확인 에러 Label
        password2ErrorLabel = UILabel().then {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = UIColor(named: "Color1")
            $0.isHidden = true
        }
        
        [emailErrorLabel,
         nickNameErrorLabel,
         passwordErrorLabel,
         password2ErrorLabel].forEach { view.addSubview($0) }
        
        emailErrorLabel.snp.makeConstraints {
            $0.top.equalTo(emailTextField.snp.bottom).offset(4)
            $0.leading.equalTo(emailTextField.snp.leading)
        }
        
        nickNameErrorLabel.snp.makeConstraints {
            $0.top.equalTo(nickNameTextField.snp.bottom).offset(4)
            $0.leading.equalTo(nickNameTextField.snp.leading)
        }
        
        passwordErrorLabel.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom).offset(4)
            $0.leading.equalTo(passwordTextField.snp.leading)
        }
        
        password2ErrorLabel.snp.makeConstraints {
            $0.top.equalTo(password2TextField.snp.bottom).offset(4)
            $0.leading.equalTo(password2TextField.snp.leading)
        }
    }
    
    private func setTextFieldDelegate() {
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
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let password2 = password2TextField.text, !password2.isEmpty,
              let nickName = nickNameTextField.text, !nickName.isEmpty else { return }
        
        // 이메일 형식 유효성 검사
        guard isValidEmail(email) else {
            showErrorLabel(emailErrorLabel, withMessage: "올바른 이메일 형식이 아닙니다.")
            return
        }
        
        // 닉네임 글자 수 제한 검사
        guard nickName.count <= 8 else {
            showErrorLabel(nickNameErrorLabel, withMessage: "닉네임은 최대 8자까지 입력할 수 있습니다.")
            return
        }
        
        // 비밀번호 형식 유효성 검사
        guard isValidPassword(password) else {
            showErrorLabel(passwordErrorLabel, withMessage: "비밀번호는 영문과 숫자를 포함 최소 8자 이상이어야 합니다.")
            return
        }
        
        // 비밀번호 일치 여부 확인
        guard password == password2 else {
            showErrorLabel(password2ErrorLabel, withMessage: "비밀번호가 일치하지 않습니다.")
            return
        }
        
        // Firebase 회원가입
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("회원가입 실패: \(error.localizedDescription)")
            } else {
                print("회원가입 성공")

                guard let uid = authResult?.user.uid else {
                    print("UID를 가져올 수 없습니다.")
                    return
                }

                // Firestore에 사용자 정보 저장
                let db = Firestore.firestore()
                let userData = [
                    "email": email,
                    "nickname": nickName
                ]

                db.collection("users").document(uid).setData(userData) { error in
                    if let error = error {
                        print("Firestore에 사용자 정보 저장 실패: \(error.localizedDescription)")
                    } else {
                        print("Firestore에 사용자 정보 저장 성공")

                        // 회원가입 완료 후 시작화면으로 이동
                        DispatchQueue.main.async {
                            guard let startVC = self.storyboard?.instantiateViewController(withIdentifier: "startViewController") as? StartViewController else { return }
                            startVC.navigationItem.hidesBackButton = true
                            self.navigationController?.pushViewController(startVC, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    func showErrorLabel(_ label: UILabel, withMessage message: String) {
        label.text = message
        label.isHidden = false
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    func isValidPassword(_ password: String) -> Bool {
        // 영문 숫자 조합, 최소 8자
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
    
    // TODO: 이메일 중복 확인 검사
    @IBAction func checkButtonTapped(_ sender: UIButton) {
        print("안할수도")
    }
    
    private func checkCompletedButtonActivation() {
        // 텍스트 필드가 비어있는지 확인
        let emailFilled = !(emailTextField.text?.isEmpty ?? true)
        let nickNameFilled = !(nickNameTextField.text?.isEmpty ?? true)
        let passwordFilled = !(passwordTextField.text?.isEmpty ?? true)
        let password2Filled = !(password2TextField.text?.isEmpty ?? true)
        
        // 모든 조건이 충족되었을 때 완료 버튼 활성화
        completedButton.isUserInteractionEnabled = emailFilled && nickNameFilled && passwordFilled && password2Filled
        completedButton.backgroundColor = completedButton.isUserInteractionEnabled ? UIColor(named: "mainColor") : UIColor.opaqueSeparator
    }
}

// -MARK: UITextFieldDelegate
extension SignUpViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        switch textField {
        case emailTextField:
            emailErrorLabel.isHidden = true
        case nickNameTextField:
            nickNameErrorLabel.isHidden = true
        case passwordTextField:
            passwordErrorLabel.isHidden = true
        case password2TextField:
            password2ErrorLabel.isHidden = true
        default:
            break
        }
        checkCompletedButtonActivation()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            nickNameTextField.becomeFirstResponder()
        case nickNameTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            password2TextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}
