//
//  DiaryViewController.swift
//  TripNote
//
//  Created by 임수진 on 6/9/24.
//

import UIKit
import FirebaseFirestore

class DiaryViewController: UIViewController {
    @IBOutlet weak var diaryTableView: UITableView!
    @IBOutlet weak var diaryButton: UIButton!
    
    var diaries: [DiaryModel] = []
    var firestore = Firestore.firestore()
    var diaryListener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        registerTableViewCell()
        configureView()
        fetchData()
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
        diaryButton.layer.cornerRadius = 10
        diaryButton.clipsToBounds = true
        diaryButton.layer.shadowColor = UIColor.black.cgColor
        diaryButton.layer.shadowOpacity = 0.25
        diaryButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        diaryButton.layer.shadowRadius = 4
        diaryButton.layer.masksToBounds = false
    }
    
    private func fetchData() {
        let diariesCollection = firestore.collection("diaries")
        
        diaryListener = diariesCollection.addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else { return }
            
            self.diaries = documents.compactMap { document in
                let data = document.data()
                let userId = data["userId"] as? String ?? ""
                let text = data["text"] as? String ?? ""
                let timestamp = data["timestamp"] as? Timestamp ?? Timestamp()
                let imageUrls = data["imageUrls"] as? [String] ?? []
                
                return DiaryModel(userId: userId, text: text, timestamp: timestamp.dateValue(), imageUrls: imageUrls)
            }
            self.diaryTableView.reloadData()
        }
    }
    
    @IBAction func diaryButtonTapped(_ sender: UIButton) {
        guard let addDiaryVC = self.storyboard?.instantiateViewController(withIdentifier: "addDiaryViewController") as? AddDiaryViewController else { return }
        addDiaryVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(addDiaryVC, animated: true)
    }
}

extension DiaryViewController: UITableViewDelegate {
    
}

// MARK: - UITableViewDataSource
extension DiaryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diaries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DiaryTableViewCell.cellIdentifier, for: indexPath) as! DiaryTableViewCell
        
        let diary = diaries[indexPath.row]
        cell.configure(with: diary)
        
        
        return cell
    }
    
    // 각 행의 높이
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500
    }
}
