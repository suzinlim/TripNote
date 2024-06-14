//
//  AddScheduleViewController.swift
//  TripNote
//
//  Created by 임수진 on 6/14/24.
//

import UIKit

class AddScheduleViewController: UIViewController {
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var completedButton: UIButton!
    
    let textViewPlaceHolder = "메모를 입력하세요"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextViewDelegate()
        setTextFieldDelegate()
        configureView()
        checkCompletedButtonState()
    }
    
    private func setTextViewDelegate() {
        memoTextView.delegate = self
    }
    
    private func setTextFieldDelegate() {
        locationTextField.delegate = self
        locationTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func configureView() {
        // MARK: 네비게이션 바 설정
        // 뒤로 가기 버튼 안 보이게 함
        self.navigationItem.hidesBackButton = true
        
        // 상단바 title
        self.navigationItem.title = "일정 추가"
        
        // 취소 Button
        let cancelbutton = UIBarButtonItem(image: UIImage(named: "cancel"), style: .done, target: self, action: #selector(cancelButtonTapped))
        self.navigationItem.rightBarButtonItem = cancelbutton
        self.navigationItem.rightBarButtonItem?.tintColor = .black
        
        // 메모 TextView
        memoTextView.text = textViewPlaceHolder
        memoTextView.textColor = .opaqueSeparator
        memoTextView.layer.borderColor = UIColor.systemGray4.cgColor
        memoTextView.layer.borderWidth = 0.5
        memoTextView.layer.cornerRadius = 5
        
        // 완료 Button
        completedButton.isUserInteractionEnabled = false
        completedButton.layer.cornerRadius = 10
    }
    
    @objc private func cancelButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func completedButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        checkCompletedButtonState()
    }
    
    private func checkCompletedButtonState() {
        let isLocationTextFilled = !(locationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        let isMemoTextFilled = !(memoTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true) && memoTextView.text != textViewPlaceHolder
        
        completedButton.isUserInteractionEnabled = isLocationTextFilled && isMemoTextFilled
        completedButton.backgroundColor = isLocationTextFilled && isMemoTextFilled ? UIColor(named: "mainColor") : .opaqueSeparator
    }
}

extension AddScheduleViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == textViewPlaceHolder {
            textView.text = nil
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = textViewPlaceHolder
            textView.textColor = .opaqueSeparator
        }
        checkCompletedButtonState()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        checkCompletedButtonState()
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let inputString = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let oldString = textView.text, let newRange = Range(range, in: oldString) else { return true }
        let newString = oldString.replacingCharacters(in: newRange, with: inputString).trimmingCharacters(in: .whitespacesAndNewlines)

        let characterCount = newString.count
        guard characterCount <= 100 else { return false }

        return true
    }
}

extension AddScheduleViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        DispatchQueue.main.async {
            self.checkCompletedButtonState()
        }
        return true
    }
}
