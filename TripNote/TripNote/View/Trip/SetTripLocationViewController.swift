//
//  SetTripLocationViewController.swift
//  TripNote
//
//  Created by 임수진 on 6/12/24.
//

import UIKit

class SetTripLocationViewController: UIViewController {
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    private func configureView() {
        // 뒤로가기 버튼
        let backbutton = UIBarButtonItem(image: UIImage(named: "back"), style: .done, target: self, action: #selector(backButtonTapped))
        self.navigationItem.leftBarButtonItem = backbutton
        
        // 여행 지역 텍스트 필드
        locationTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        // 다음으로 버튼
//        nextButton.isUserInteractionEnabled = false
        nextButton.layer.cornerRadius = 10
    }
    
    @objc func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
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
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        if let location = locationTextField.text, !location.isEmpty {
            TripDataManager.shared.setTripLocation(location)
        }

        let bottomSheetViewController = BottomSheetViewController()
        bottomSheetViewController.modalPresentationStyle = .custom
        self.present(bottomSheetViewController, animated: true, completion: nil)
    }
}
