//
//  AddDiaryViewController.swift
//  TripNote
//
//  Created by 임수진 on 6/11/24.
//

import UIKit

class AddDiaryViewController: UIViewController {
    @IBOutlet weak var diaryTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setKeyboard()
    }
    
    private func configureView() {
        // 뒤로가기 버튼
        let backbutton = UIBarButtonItem(image: UIImage(named: "back"), style: .done, target: self, action: #selector(backButtonTapped))
        
        // 완료 버튼
        let completedbutton = UIBarButtonItem(image: UIImage(named: "check"), style: .done, target: self, action: #selector(completedButtonTapped))
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.leftBarButtonItem = backbutton
        self.navigationItem.rightBarButtonItem = completedbutton
        
        // 일기 TextView
        diaryTextView.isFirstResponder
    }
    
    private func setKeyboard() {
//        diaryTextView.isFirstResponder = true
    }
    
    @objc func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func completedButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}
