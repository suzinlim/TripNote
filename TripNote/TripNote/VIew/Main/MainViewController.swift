//
//  MainViewController.swift
//  TripNote
//
//  Created by 임수진 on 6/6/24.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var tripCollectionView: UICollectionView!
    @IBOutlet weak var addButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupCollectionViewLayout()
        registerCollectionViewCell()
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
        tripCollectionView.register(UINib(nibName: "TripCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "tripCollectionViewCell")
    }
    
    @IBAction func addTripButtonTapped(_ sender: UIButton) {
        print("여행 추가하기 버튼")
        guard let setTripTitleVC = self.storyboard?.instantiateViewController(withIdentifier: "setTripTitleViewController") as? SetTripTitleViewController else { return }
        self.navigationController?.pushViewController(setTripTitleVC, animated: true)
    }
    
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tripCollectionViewCell", for: indexPath) as! TripCollectionViewCell
        
        return cell
    }
}

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
