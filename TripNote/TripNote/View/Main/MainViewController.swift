//
//  MainViewController.swift
//  TripNote
//
//  Created by 임수진 on 6/6/24.
//

import UIKit
import Firebase

class MainViewController: UIViewController {
    @IBOutlet weak var tripCollectionView: UICollectionView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    var user: User?
    var trips: [TripModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserInfo()
        setupCollectionView()
        setupCollectionViewLayout()
        registerCollectionViewCell()
        fetchData()
        NotificationCenter.default.addObserver(self, selector: #selector(handleTripAddedNotification), name: Notification.Name("TripAddedNotification"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tripCollectionView.reloadData()
    }
    
    private func getUserInfo() {
        if let currentUser = Auth.auth().currentUser {
            let db = Firestore.firestore()
            let usersRef = db.collection("users").document(currentUser.uid)
            
            usersRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    if let nickname = document.data()? ["nickname"] as? String {
                        print("닉네임: \(nickname)")
                        self.nickNameLabel.text = "\(nickname)님의 여행 노트"
                    }
                } else {
                    print("사용자 정보를 가져오는 데 실패했습니다.")
                }
            }
        }
    }
    
    @objc private func handleTripAddedNotification() {
        fetchData()
    }
    
    private func fetchData() {
        TripDataManager.shared.fetchTrips { [weak self] trips in
            self?.trips = trips
            self?.tripCollectionView.reloadData()
        }
    }
    
    private func setupCollectionView() {
        tripCollectionView.delegate = self
        tripCollectionView.dataSource = self
    }
    
    private func setupCollectionViewLayout() {
        let flowLayout = createFlowLayout()
        tripCollectionView.collectionViewLayout = flowLayout
        configureCollectionView()
    }
    
    private func createFlowLayout() -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = Const.itemSize
        flowLayout.minimumLineSpacing = Const.itemSpacing
        flowLayout.minimumInteritemSpacing = 0
        return flowLayout
    }
    
    private func configureCollectionView() {
        tripCollectionView.reloadData()
        tripCollectionView.isPagingEnabled = false
        tripCollectionView.contentInsetAdjustmentBehavior = .never
        tripCollectionView.contentInset = Const.collectionViewContentInset
        tripCollectionView.decelerationRate = .fast // 스크롤 빠르게 -> 페이징 애니메이션 같이 보이게 함
        tripCollectionView.showsHorizontalScrollIndicator = false // 스크롤바 숨김
    }
    
    private func registerCollectionViewCell() {
        let tripNib = UINib(nibName: "TripCollectionViewCell", bundle: nil)
        tripCollectionView.register(tripNib, forCellWithReuseIdentifier: TripCollectionViewCell.cellIdentifier)
        
        let emptyNib = UINib(nibName: "EmptyCollectionViewCell", bundle: nil)
        tripCollectionView.register(emptyNib, forCellWithReuseIdentifier: EmptyCollectionViewCell.cellIdentifier)
    }
    
    @IBAction func addTripButtonTapped(_ sender: UIButton) {
        guard let setTripTitleVC = self.storyboard?.instantiateViewController(withIdentifier: "setTripTitleViewController") as? SetTripTitleViewController else { return }
        self.navigationController?.pushViewController(setTripTitleVC, animated: true)
    }
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // trips 배열이 비어 있을 경우 1개의 EmptyCollectionViewCell 표시
        // trips 배열이 비어 있지 않을 경우 trips 배열의 개수만큼 TripCollectionViewCell 표시
        return trips.isEmpty ? 1 : trips.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if trips.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyCollectionViewCell.cellIdentifier, for: indexPath) as! EmptyCollectionViewCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TripCollectionViewCell.cellIdentifier, for: indexPath) as! TripCollectionViewCell
            
            let trip = trips[indexPath.item]
            
            // 셀의 세부사항 설정 및 수정/삭제 액션 전달
            cell.configure(with: trip, onEditAction: { [weak self] in
                guard let editTripNoteVC = self?.storyboard?.instantiateViewController(withIdentifier: "editTripViewController") as? EditTripViewController else { return }
                editTripNoteVC.trip = trip
                editTripNoteVC.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(editTripNoteVC, animated: true)
            }, onDeleteAction: { [weak self] in
                self?.showDeleteAlert(for: indexPath)
            })
            return cell
        }
    }
    
    private func showDeleteAlert(for indexPath: IndexPath) {
        let alert = UIAlertController(title: "여행 삭제", message: "정말로 삭제하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { [weak self] _ in
            self?.deleteTrip(at: indexPath)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func deleteTrip(at indexPath: IndexPath) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 삭제할 여행 항목이 유효한지 검사
            guard indexPath.item < self.trips.count else { return }
            
            let tripToDelete = self.trips[indexPath.item]
            // 비동기 처리로 진행, 삭제 성공했을 때 클로저 호출
            TripDataManager.shared.deleteTrip(tripID: tripToDelete.id) { error in
                if let error = error {
                    print("여행 노트 삭제 실패: \(error.localizedDescription)")
                } else {
                    // 성공할 경우 trips 배열에서 해당 여행 제거
                    self.trips.remove(at: indexPath.item)
                    
                    if self.trips.isEmpty {
                        self.tripCollectionView.reloadData()
                    } else {
                        self.tripCollectionView.performBatchUpdates({
                            self.tripCollectionView.deleteItems(at: [indexPath])
                        }, completion: { finished in
                            if !finished {
                                print("CollectionView 삭제 반영 실패")
                            }
                        })
                    }
                }
            }
        }
    }
}

// -MARK: UICollectionViewDelegate
extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let tripNoteVC = storyboard?.instantiateViewController(withIdentifier: "tripNoteViewController") as? TripNoteViewController else { return }
        // 해당 여행 데이터를 전달하며 TripNote 뷰 컨트롤러로 이동
        tripNoteVC.trip = trips[indexPath.item]
        tripNoteVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(tripNoteVC, animated: true)
    }
}

// -MARK: UICollectionViewDelegateFlowLayout
extension MainViewController: UICollectionViewDelegateFlowLayout {
    // 페이징 구현
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let scrolledOffsetX = targetContentOffset.pointee.x + scrollView.contentInset.left
        let cellWidth = Const.itemSize.width + Const.itemSpacing
        let index = round(scrolledOffsetX / cellWidth)
        targetContentOffset.pointee = CGPoint(x: index * cellWidth - scrollView.contentInset.left, y: scrollView.contentInset.top)
    }
}

// CollectionView 레이아웃 설정
private enum Const {
    static let widthRatio: CGFloat = 0.8
    static let heightRatio: CGFloat = 0.5
    static let itemSpacing: CGFloat = 24.0

    static var itemSize: CGSize {
        // 화면 크기 비율로 아이템 크기 설정
        let width = UIScreen.main.bounds.width * self.widthRatio
        let height = UIScreen.main.bounds.height * self.heightRatio
        return CGSize(width: width, height: height)
    }

    static var insetX: CGFloat {
        // 좌우 여백 설정 -> CollectionView의 양쪽에 균등한 여백을 주기 위함
        (UIScreen.main.bounds.width - self.itemSize.width) / 2.0
    }
    
    static var collectionViewContentInset: UIEdgeInsets {
        // 상하좌우 여백 설정
        UIEdgeInsets(top: 0, left: self.insetX, bottom: 0, right: self.insetX)
    }
}
