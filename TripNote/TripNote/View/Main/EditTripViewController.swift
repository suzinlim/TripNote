//
//  EditTripViewController.swift
//  TripNote
//
//  Created by 임수진 on 6/15/24.
//

import UIKit

class EditTripViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var completedButton: UIButton!
    
    var trip: TripModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextFieldDelegate()
        configureView()
        populateTripInfo()
    }
    
    private func setTextFieldDelegate() {
        titleTextField.delegate = self
        locationTextField.delegate = self
    }
    
    private func configureView() {
        // 뒤로가기 버튼
        let backbutton = UIBarButtonItem(image: UIImage(named: "back"), style: .done, target: self, action: #selector(backButtonTapped))
        self.navigationItem.leftBarButtonItem = backbutton
        self.navigationItem.leftBarButtonItem?.tintColor = .black
        
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
        
        // 완료 버튼
        completedButton.layer.cornerRadius = 10
    }
    
    private func populateTripInfo() {
        guard let trip = trip else { return }
        titleTextField.text = trip.title
        locationTextField.text = trip.location
        startDatePicker.date = trip.startDate!
        endDatePicker.date = trip.endDate!
        startDateLabel.text = formatDate(trip.startDate!)
        endDateLabel.text = formatDate(trip.endDate!)
    }
    
    @objc private func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
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
                completedButton.isUserInteractionEnabled = true
                completedButton.backgroundColor = UIColor(named: "mainColor")
            } else {
                completedButton.isUserInteractionEnabled = false
                completedButton.backgroundColor = UIColor.opaqueSeparator
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy.MM.dd"
        return formatter.string(from: date)
    }
    
    @IBAction func completedButtonTapped(_ sender: UIButton) {
        guard let trip = trip else { return }
        
        if let updatedTitle = titleTextField.text,
           let updatedLocation = locationTextField.text {
            
            let updatedStartDate = startDatePicker.date
            let updatedEndDate = endDatePicker.date
            
            TripDataManager.shared.updateTrip(
                tripID: trip.id!,
                title: updatedTitle,
                startDate: updatedStartDate,
                endDate: updatedEndDate,
                location: updatedLocation)
            { [weak self] error in
                if let error = error {
                    print("여행 노트 수정 실패: \(error.localizedDescription)")
                } else {
                    // 수정 성공하면 이전 뷰 컨트롤러로 이동
                    DispatchQueue.main.async {
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    private func checkCompletedButtonActivation() {
        let titleFilled = !(titleTextField.text?.isEmpty ?? true)
        let startDateFilled = !(startDateLabel.text?.isEmpty ?? true)
        let endDateFilled = !(endDateLabel.text?.isEmpty ?? true)
        let locationFilled = !(locationTextField.text?.isEmpty ?? true)
        
        // 모든 조건이 충족되었을 때 로그인 버튼 활성화
        completedButton.isUserInteractionEnabled = 
        titleFilled && startDateFilled && endDateFilled && locationFilled
        completedButton.backgroundColor = completedButton.isUserInteractionEnabled ? UIColor(named: "mainColor") : UIColor.opaqueSeparator
    }
}

// -MARK: UITextFieldDelegate
extension EditTripViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        checkCompletedButtonActivation()
    }
}
