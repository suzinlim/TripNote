//
//  DiaryViewController.swift
//  TripNote
//
//  Created by 임수진 on 6/9/24.
//

import UIKit

class DiaryViewController: UIViewController {
    @IBOutlet weak var diaryTableView: UITableView!
    @IBOutlet weak var diaryButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        registerTableViewCell()
        configureView()
    }
    
    private func setTableView() {
        diaryTableView.delegate = self
        diaryTableView.dataSource = self
        diaryTableView.showsVerticalScrollIndicator = false
    }
    
    private func registerTableViewCell() {
        let itemNib = UINib(nibName: "DiaryTableViewCell", bundle: nil)
        diaryTableView.register(itemNib, forCellReuseIdentifier: DiaryTableViewCell.cellIdentifier)
    }
    
    private func configureView() {
        diaryButton.layer.cornerRadius = 15
        diaryButton.clipsToBounds = true
        diaryButton.layer.shadowColor = UIColor.black.cgColor
        diaryButton.layer.shadowOpacity = 0.25
        diaryButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        diaryButton.layer.shadowRadius = 4
        diaryButton.layer.masksToBounds = false
    }
    
    @IBAction func diaryButtonTapped(_ sender: UIButton) {
        guard let addDiaryVC = self.storyboard?.instantiateViewController(withIdentifier: "addDiaryViewController") as? AddDiaryViewController else { return }
        addDiaryVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(addDiaryVC, animated: true)
    }
}

extension DiaryViewController: UITableViewDelegate {
    
}

extension DiaryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DiaryTableViewCell.cellIdentifier, for: indexPath) as! DiaryTableViewCell
        cell.selectionStyle = .none
        addShadow(to: cell)
        
        return cell
    }
    
    // 각 행의 높이
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
    private func addShadow(to cell: UITableViewCell) {
        cell.contentView.layer.cornerRadius = 8
        cell.contentView.layer.masksToBounds = true
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.1
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowRadius = 4
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
    }
}
