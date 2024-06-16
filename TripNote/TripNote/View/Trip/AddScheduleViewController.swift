//
//  AddScheduleViewController.swift
//  TripNote
//
//  Created by 임수진 on 6/14/24.
//

import UIKit
import FirebaseFirestore

class AddScheduleViewController: UIViewController {
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var completedButton: UIButton!
    
    let textViewPlaceHolder = "메모를 입력하세요"
    
    var trip: TripModel?
    var selectedDate: Date?
    var schedule: ScheduleModel?
    var scheduleId: String?
    var editingSchedule: ScheduleModel?
    
    var scheduleAddedOrUpdated: ((ScheduleModel) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkCompletedButtonActivation()
        setTextViewDelegate()
        setTextFieldDelegate()
        configureView()
        checkCompletedButtonActivation()
        if let editingSchedule = editingSchedule {
            fetchData()
        }
    }
    
    private func setTextViewDelegate() {
        memoTextView.delegate = self
    }
    
    private func setTextFieldDelegate() {
        locationTextField.delegate = self
    }
    
    private func configureView() {
        // -MARK: 네비게이션 바 설정
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
        completedButton.layer.cornerRadius = 10
    }
    
    @objc private func cancelButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func completedButtonTapped(_ sender: UIButton) {
        let location = locationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let memo = memoTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !location.isEmpty, !memo.isEmpty, let selectedDate = selectedDate else { return }
        
        // Schedule 객체 생성
        var newSchedule = ScheduleModel(date: selectedDate, place: location, memo: memo)
        
        // Firebase에 데이터 저장
        saveToFirebase(schedule: newSchedule)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    private func checkCompletedButtonActivation() {
        let isLocationTextFilled = !(locationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        let isMemoTextFilled = !(memoTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true) && memoTextView.text != textViewPlaceHolder
        
        completedButton.isUserInteractionEnabled = isLocationTextFilled && isMemoTextFilled
        completedButton.backgroundColor = isLocationTextFilled && isMemoTextFilled ? UIColor(named: "mainColor") : .opaqueSeparator
    }
    
    private func fetchData() {
        if let editingSchedule = editingSchedule {
            locationTextField.text = editingSchedule.place
            memoTextView.text = editingSchedule.memo
            memoTextView.textColor = .black
        }
    }
    
    private func saveToFirebase(schedule: ScheduleModel) {
        guard let tripId = trip?.id else { return }
        
        let db = Firestore.firestore()
        var scheduleRef: DocumentReference
        
        if let scheduleId = scheduleId {
            // 기존 일정 수정인 경우
            scheduleRef = db.collection("trips").document(tripId).collection("schedules").document(scheduleId)
        } else {
            // 새로운 일정 추가인 경우
            scheduleRef = db.collection("trips").document(tripId).collection("schedules").document()
            scheduleId = scheduleRef.documentID
        }
        
        var data: [String: Any] = [
            "place": schedule.place,
            "memo": schedule.memo,
            "date": Timestamp(date: schedule.date),
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        scheduleRef.setData(data) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                print("일정 추가 실패: \(error)")
            } else {
                if self.scheduleId == nil {
                    self.scheduleId = scheduleRef.documentID
                    print("일정 추가: \(scheduleRef.documentID)")
                } else {
                    print("일정 수정: \(self.scheduleId!)")
                }
            }
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

// -MARK: UITextViewDelegate
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
        checkCompletedButtonActivation()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        checkCompletedButtonActivation()
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

// -MARK: UITextFieldDelegate
extension AddScheduleViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        DispatchQueue.main.async {
            self.checkCompletedButtonActivation()
        }
        return true
    }
}
