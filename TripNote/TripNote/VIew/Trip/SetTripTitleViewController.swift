//
//  SetTripTitleViewController.swift
//  TripNote
//
//  Created by 임수진 on 6/8/24.
//

import UIKit

class SetTripTitleViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet var exampleButtons: [UIButton]!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setExampleButtons()
    }
    
    private func configureView() {
        // 뒤로가기 버튼
        let backbutton = UIBarButtonItem(image: UIImage(named: "back"), style: .done, target: self, action: #selector(backButtonTapped))
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.leftBarButtonItem = backbutton
        
        // 여행 제목 텍스트 필드
        titleTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        // 다음으로 버튼
//        nextButton.isUserInteractionEnabled = false
        nextButton.layer.cornerRadius = 10
    }
    
    @objc func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    private func setExampleButtons() {
        for button in exampleButtons {
            button.layer.cornerRadius = 9
            button.addTarget(self, action: #selector(exampleButtonTapped), for: .touchUpInside)
        }
    }
    
    @objc func textFieldDidChange(_ sender: UITextField) {
        if let titleText = sender.text {
            if titleText.count > 0 {
                nextButton.isUserInteractionEnabled = true
                nextButton.backgroundColor = UIColor(named: "mainColor")
            } else {
                nextButton.isUserInteractionEnabled = false
                nextButton.backgroundColor = UIColor.opaqueSeparator
            }
        }
    }
    
    @objc func exampleButtonTapped(_ sender: UIButton) {
        titleTextField.text = sender.titleLabel?.text
        nextButton.isUserInteractionEnabled = true
        nextButton.backgroundColor = UIColor(named: "mainColor")
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        guard let setTripDateVC = self.storyboard?.instantiateViewController(withIdentifier: "setTripDateViewController") as? SetTripDateViewController else { return }
        self.navigationController?.pushViewController(setTripDateVC, animated: true)
    }
}
