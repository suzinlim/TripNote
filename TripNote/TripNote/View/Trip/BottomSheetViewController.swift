//
//  BottomSheetViewController.swift
//  TripNote
//
//  Created by 임수진 on 6/12/24.
//

import UIKit
import SnapKit
import Then

class BottomSheetViewController: UIViewController {
    
    weak var currentViewController: UIViewController?
    let colors: [UIColor] = [
        UIColor(named: "Color1")!,
        UIColor(named: "Color2")!,
        UIColor(named: "Color3")!,
        UIColor(named: "Color4")!,
        UIColor(named: "Color5")!,
        UIColor(named: "Color6")!,
        UIColor(named: "Color7")!,
        UIColor(named: "Color8")!,
        UIColor(named: "Color9")!
    ]

    let dimmedView = UIView().then {
        $0.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    lazy var bottomSheetView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 30
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.clipsToBounds = true
    }
    
    lazy var titleLabel = UILabel().then {
        $0.text = "여행 커버 이미지"
        $0.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
    }
    
    lazy var titleDetailLabel = UILabel().then {
        $0.text = "여행 테마에 어울리는 색을 골라보세요"
        $0.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        $0.textColor = UIColor.systemGray
    }
    
    lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 20
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    lazy var nextButton = UIButton().then {
        $0.setTitle("여행 추가하기", for: .normal)
        $0.setTitleColor(UIColor.white, for: .normal)
        $0.backgroundColor = UIColor.opaqueSeparator
        $0.layer.cornerRadius = 10
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        $0.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    let totalHeight: CGFloat = 844 // 전체 높이
    let ratio: CGFloat = 310 // Bottom Sheet가 차지하는 높이
    
    var bottomSheetHeight: CGFloat {
        return (ratio / totalHeight) * UIScreen.main.bounds.height // 디바이스가 달라져도 비율만큼 차지
    }
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGesture()
        setupCollectionView()
        addSubViews()
        setupLayout()
        registerCollectionViewCell()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showBottomSheet()
    }
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        dimmedView.addGestureRecognizer(tapGesture)
    }
    
    private func setupCollectionView() {
        colorCollectionView.delegate = self
        colorCollectionView.dataSource = self
    }
    
    private func registerCollectionViewCell() {
        colorCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ColorCell")
    }
    
    private func addSubViews() {
        view.addSubview(dimmedView)
        view.addSubview(bottomSheetView)
        [titleLabel,
         titleDetailLabel,
         colorCollectionView,
         nextButton].forEach { bottomSheetView.addSubview($0) }
    }
    
    private func setupLayout() {
        dimmedView.alpha = 0.0
        dimmedView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
        bottomSheetView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.snp.bottom)
            $0.height.equalTo(bottomSheetHeight)
        }
        
        // 제목 Label
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(bottomSheetView).offset(35)
            $0.leading.trailing.equalToSuperview().inset(30)
        }
        
        // 제목 상세 Label
        titleDetailLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(7)
            $0.leading.trailing.equalToSuperview().inset(30)
        }
        
        // 색 CollectionView
        colorCollectionView.snp.makeConstraints {
            $0.top.equalTo(titleDetailLabel.snp.bottom).offset(25)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.height.equalTo(50)
        }
        
        // 다음으로 Button
        nextButton.snp.makeConstraints {
            $0.height.equalTo(52)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
    }
    
    public func showBottomSheet() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            self.dimmedView.alpha = 0.7
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    public func hideBottomSheetAndGoBack() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            self.dimmedView.alpha = 0.0
            self.view.layoutIfNeeded()
        }) { [weak self] _ in
            guard let self = self else { return }
            if self.presentingViewController != nil {
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        let touchPoint = gesture.location(in: dimmedView)
        if !bottomSheetView.frame.contains(touchPoint) {
            hideBottomSheetAndGoBack()
        }
    }
    
    @objc func nextButtonTapped() {
        guard let tripNoteVC = self.storyboard?.instantiateViewController(withIdentifier: "tripNoteViewController") as? TripNoteViewController else { return }
        self.navigationController?.pushViewController(tripNoteVC, animated: true)
    }
}

extension BottomSheetViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath)
        cell.backgroundColor = colors[indexPath.item]
        cell.layer.cornerRadius = cell.frame.size.width / 2
        cell.clipsToBounds = true
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
}
