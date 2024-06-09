//
//  TripNoteViewController.swift
//  TripNote
//
//  Created by 임수진 on 6/9/24.
//

import UIKit

class TripNoteViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setTableView()
        registerTableViewCell()
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
        
        let headerView = TripHeaderView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 180))
        tableView.tableHeaderView = headerView
    }
    
    private func registerTableViewCell() {
        let itemNib = UINib(nibName: "TripItemTableViewCell", bundle: nil)
        tableView.register(itemNib, forCellReuseIdentifier: TripItemTableViewCell.cellIdentifier)
    }
    
    @objc func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

extension TripNoteViewController: UITableViewDelegate {
    
}

extension TripNoteViewController: UITableViewDataSource {
    // 섹션 수
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    // 각 섹션의 행 수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    // 각 행에 대한 셀을 반환하는 메서드
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TripItemTableViewCell.cellIdentifier, for: indexPath) as! TripItemTableViewCell
        cell.selectionStyle = .none

        return cell
    }
    
    // 각 섹션의 헤더 제목
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Day \(section + 1)"
    }
    
    // 각 행의 높이
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 106
    }
    
    // 왼쪽으로 스와이프할 경우 편집 또는 삭제
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // -MARK: 삭제
        let deleteAction = UIContextualAction(style: .normal, title: "삭제") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            success(true)
        }
        deleteAction.backgroundColor = .systemRed

        // -MARK: 편집
        let editAction = UIContextualAction(style: .normal, title: "편집") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
            success(true)
        }
        editAction.backgroundColor = UIColor(named: "mainColor")

        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
}
