//
//  TripNoteViewController.swift
//  TripNote
//
//  Created by 임수진 on 6/9/24.
//

import UIKit
import FirebaseFirestore

class TripNoteViewController: UIViewController, NotEnteredTripItemTableViewCellDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var trip: TripModel?
    var sections: [Date] = []
    var schedules: [ScheduleModel] = []
    var schedulesListener: ListenerRegistration? // Firestore에서 일정 변경을 실시간으로 감지하는 리스너
    
    deinit {
        schedulesListener?.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setTableView()
        loadSections()
        loadSchedules()
    }
    
    private func configureView() {
        // 뒤로가기 버튼
        let backbutton = UIBarButtonItem(image: UIImage(named: "back"), style: .done, target: self, action: #selector(backButtonTapped))
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.leftBarButtonItem = backbutton
    }
    
    private func setTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        
        // tableView HeaderView 설정
        let headerView = TripHeaderView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 180))
        tableView.tableHeaderView = headerView
        headerView.configure(with: trip!)
        
        registerCells()
    }
    
    private func registerCells() {
        let itemNib = UINib(nibName: "TripItemTableViewCell", bundle: nil)
        tableView.register(itemNib, forCellReuseIdentifier: TripItemTableViewCell.cellIdentifier)
        
        let notEntereditemNib = UINib(nibName: "NotEnteredTripItemTableViewCell", bundle: nil)
        tableView.register(notEntereditemNib, forCellReuseIdentifier: NotEnteredTripItemTableViewCell.cellIdentifier)
    }
    
    @objc func backButtonTapped(_ sender: UIButton) {
        if let rootViewController = navigationController?.viewControllers.first {
            navigationController?.popToViewController(rootViewController, animated: true)
        }
    }
    
    private func loadSections() {
        guard let startDate = trip?.startDate, let endDate = trip?.endDate else { return }
        
        sections = []
        var currentDate = startDate
        let calendar = Calendar.current
        
        // 시작 날짜부터 종료 날짜까지 while 문 돌면서 date 추가해 날짜 목록 설정
        while currentDate <= endDate {
            sections.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        tableView.reloadData()
    }
    
    private func loadSchedules() {
        guard let tripId = trip?.id else { return }
        
        // 기존 리스너 제거
        schedulesListener?.remove()
        
        let db = Firestore.firestore()
        schedulesListener = db.collection("trips")
            .document(tripId)
            .collection("schedules")
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("document 불러오기 실패: \(error)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("document 존재하지 않음")
                    return
                }
                
                // Firestore에서 가져온 각 queryDocumentSnapshot을 ScheduleModel로 변환
                self.schedules = documents.compactMap { queryDocumentSnapshot -> ScheduleModel? in
                    let data = queryDocumentSnapshot.data()
                    let place = data["place"] as? String
                    let placeAddress = data["placeAddress"] as? String
                    let memo = data["memo"] as? String
                    let timestamp = data["date"] as? Timestamp
                    let date = timestamp?.dateValue()
                    let createdAt = data["createdAt"] as? Timestamp
                
                    return ScheduleModel(id: queryDocumentSnapshot.documentID, date: date!, place: place!, placeAddress: placeAddress!, memo: memo!)
                }
                self.tableView.reloadData()
            }
    }

    private func handleScheduleAddedOrUpdated(_ schedule: ScheduleModel) {
        // schedules에 해당 일정이 존재하는지 확인
        if let index = schedules.firstIndex(where: { $0.id == schedule.id }) {
            // 존재한다면 수정한 일정 업데이트
            schedules[index] = schedule
        } else {
            // 존재하지 않다면 새 일정 추가
            schedules.append(schedule)
        }
        schedules.sort(by: { $0.date < $1.date })
        tableView.reloadData()
    }
    
    private func handleScheduleDeletedUIUpdate(_ scheduleId: String) {
        schedules.removeAll(where: { $0.id == scheduleId })
        tableView.reloadData()
    }
    
    private func handleScheduleDeleted(_ scheduleId: String) {
        let alert = UIAlertController(title: "일정 삭제", message: "이 일정을 삭제하시겠습니까?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] action in
            self?.deleteSchedule(scheduleId)
        }
        alert.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension TripNoteViewController: UITableViewDataSource {
    
    // 섹션 수
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if schedules.isEmpty {
            return 1 // 일정이 없는 경우 1개의 NotEnteredTripItemTableViewCell 리턴
        } else {
            let sectionDate = sections[section]
            let count = schedules.filter { $0.date == sectionDate }.count
            return count + 1 // 일정 개수만큼의 TripItemTableViewCell에 1개의 NotEnteredTripItemTableViewCell 더해서 반환
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if schedules.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: NotEnteredTripItemTableViewCell.cellIdentifier, for: indexPath) as! NotEnteredTripItemTableViewCell
            guard let trip = trip else { fatalError() }
            cell.configure(with: trip, at: indexPath)
            cell.delegate = self
            return cell
            
        } else {
            let sectionDate = sections[indexPath.section]
            let sectionSchedules = schedules.filter { $0.date == sectionDate }
            
            if indexPath.row < sectionSchedules.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: TripItemTableViewCell.cellIdentifier, for: indexPath) as! TripItemTableViewCell
                let schedule = sectionSchedules[indexPath.row]
                cell.configure(with: schedule, at: indexPath)
                return cell
                
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: NotEnteredTripItemTableViewCell.cellIdentifier, for: indexPath) as! NotEnteredTripItemTableViewCell
                guard let trip = trip else { fatalError() }
                cell.configure(with: trip, at: indexPath)
                cell.delegate = self
                return cell
            }
        }
    }
    
    // 각 섹션의 헤더 제목
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Day \(section + 1)"
    }
    
    // 각 행의 높이
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if schedules.isEmpty {
            // 일정이 없는 경우 NotEnteredTripItemTableViewCell 높이 리턴
            return 100
        } else {
            // 일정이 있는 경우
            let sectionDate = sections[indexPath.section]
            let schedulesInSection = schedules.filter { $0.date == sectionDate }
            
            if indexPath.row == schedulesInSection.count {
                // 각 섹션의 마지막 행에는 NotEnteredTripItemTableViewCell 높이 리턴
                return 100
            } else {
                // 이외의 경우 TripItemTableViewCell 높이 리턴
                return 150
            }
        }
    }
    
    // 왼쪽으로 스와이프할 경우 편집 또는 삭제
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // 일정 삭제
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { (action, view, completion) in
            let sectionDate = self.sections[indexPath.section]
            let sectionSchedules = self.schedules.filter { $0.date == sectionDate }
            
            guard indexPath.row < sectionSchedules.count else { return }
            let scheduleToDelete = sectionSchedules[indexPath.row]
            
            guard let scheduleId = scheduleToDelete.id else { return }
            self.handleScheduleDeleted(scheduleId)
            
            completion(true)
        }
        
        // 일정 수정
        let editAction = UIContextualAction(style: .normal, title: "편집") { (action, view, completion) in
            let sectionDate = self.sections[indexPath.section]
            let sectionSchedules = self.schedules.filter { $0.date == sectionDate }
            
            guard indexPath.row < sectionSchedules.count else { return }
            let scheduleToEdit = sectionSchedules[indexPath.row]
            
            self.editSchedule(at: indexPath)
            completion(true)
        }
        editAction.backgroundColor = UIColor(named: "mainColor")

        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
    private func deleteSchedule(_ scheduleId: String) {
        guard let tripId = trip?.id else { return }
        
        let db = Firestore.firestore()
        let scheduleRef = db.collection("trips").document(tripId).collection("schedules").document(scheduleId)
        
        scheduleRef.getDocument { (document, error) in
            if let error = error { return }
            
            guard let document = document else {
                print("일정이 존재하지 않음")
                return
            }
            
            if document.exists {
                scheduleRef.delete { [weak self] (error) in
                    guard let self = self else { return }
                    if let error = error {
                        print("일정 삭제 실패: \(error)")
                    } else {
                        print("일정 삭제 성공")
                        
                        // 스케줄 삭제 후 UI 반영
                        self.handleScheduleDeletedUIUpdate(scheduleId)
                    }
                }
            } else {
                print("일정이 존재하지 않음")
            }
        }
    }

    private func editSchedule(at indexPath: IndexPath) {
        let sectionDate = sections[indexPath.section]
        let sectionSchedules = schedules.filter { $0.date == sectionDate }
        
        guard indexPath.row < sectionSchedules.count else { return }
        let scheduleToEdit = sectionSchedules[indexPath.row]
        
        guard let scheduleId = scheduleToEdit.id else { return }
        guard let addScheduleVC = storyboard?.instantiateViewController(withIdentifier: "addScheduleViewController") as? AddScheduleViewController else { return }
        
        addScheduleVC.trip = self.trip
        addScheduleVC.selectedDate = scheduleToEdit.date
        addScheduleVC.editingSchedule = scheduleToEdit
        addScheduleVC.scheduleId = scheduleId
        
        addScheduleVC.scheduleAddedOrUpdated = { [weak self] schedule in
            guard let self = self else { return }
            self.handleScheduleAddedOrUpdated(schedule)
        }
        
        let navigationController = UINavigationController(rootViewController: addScheduleVC)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true)
    }
}

// MARK: - UITableViewDelegate
extension TripNoteViewController: UITableViewDelegate {
    func addScheduleTapped(cell: NotEnteredTripItemTableViewCell, tripId: String) {
        if let indexPath = tableView.indexPath(for: cell) {
            guard let addScheduleVC = storyboard?.instantiateViewController(withIdentifier: "addScheduleViewController") as? AddScheduleViewController else { return }
            
            addScheduleVC.trip = trip
            addScheduleVC.selectedDate = sections[indexPath.section] // 선택된 섹션의 날짜 전달
            addScheduleVC.scheduleAddedOrUpdated = { [weak self] schedule in
                guard let self = self else { return }
                self.handleScheduleAddedOrUpdated(schedule)
            }
            
            let navigationController = UINavigationController(rootViewController: addScheduleVC)
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true)
        }
    }
}
