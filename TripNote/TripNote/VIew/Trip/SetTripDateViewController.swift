//
//  SetTripDateViewController.swift
//  TripNote
//
//  Created by 임수진 on 6/8/24.
//

import UIKit
import SnapKit
import Then

class SetTripDateViewController: UIViewController {
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    private func configureView() {
        self.modalPresentationStyle = .currentContext
        
        // 뒤로가기 버튼
        let backbutton = UIBarButtonItem(image: UIImage(named: "back"), style: .done, target: self, action: #selector(backButtonTapped))
        self.navigationItem.leftBarButtonItem = backbutton
        
        // 시작, 종료 날짜 Label
        startDateLabel.layer.cornerRadius = 9
        startDateLabel.layer.masksToBounds = true

        endDateLabel.layer.cornerRadius = 9
        endDateLabel.layer.masksToBounds = true
        
        // 시작, 종료 DatePicker
        startDatePicker.addTarget(self, action: #selector(startDateChanged), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(endDateChanged), for: .valueChanged)
        
        // 시작 날짜 이후로만 선택 가능
        endDatePicker.minimumDate = startDatePicker.date
        
        // 다음으로 버튼
        nextButton.isUserInteractionEnabled = false
        nextButton.layer.cornerRadius = 10
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc func startDateChanged() {
        let selectedDate = startDatePicker.date
        let formattedDate = formatDate(selectedDate)
        startDateLabel.text = formattedDate
        endDatePicker.minimumDate = selectedDate
    }

    @objc func endDateChanged() {
        let selectedDate = endDatePicker.date
        let formattedDate = formatDate(selectedDate)
        endDateLabel.text = formattedDate
        
        if let startDate = startDateLabel.text, let endDate = endDateLabel.text {
            if !startDate.isEmpty, !endDate.isEmpty {
                nextButton.isUserInteractionEnabled = true
                nextButton.backgroundColor = UIColor(named: "mainColor")
            } else {
                nextButton.isUserInteractionEnabled = false
                nextButton.backgroundColor = UIColor.opaqueSeparator
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy.MM.dd"
        return formatter.string(from: date)
    }

    @IBAction func nextButtonTapped(_ sender: UIButton) {
        guard let setTripAreaVC = self.storyboard?.instantiateViewController(withIdentifier: "setTripAreaViewController") as? SetTripAreaViewController else { return }
        self.navigationController?.pushViewController(setTripAreaVC, animated: true)
    }
}
