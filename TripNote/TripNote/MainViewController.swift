//
//  MainViewController.swift
//  TripNote
//
//  Created by 임수진 on 6/6/24.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var tripCollectionView: UICollectionView!
    
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
        let flowLayout = UICollectionViewFlowLayout()
        let numberOfItemsPerRow: CGFloat = 1
        let spacingBetweenItems: CGFloat = 10
        let itemWidth = tripCollectionView.bounds.width - (numberOfItemsPerRow - 1) * spacingBetweenItems
        let itemHeight = tripCollectionView.bounds.height
        
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        flowLayout.minimumLineSpacing = spacingBetweenItems
        flowLayout.minimumInteritemSpacing = spacingBetweenItems
        
        tripCollectionView.collectionViewLayout = flowLayout
        tripCollectionView.reloadData()
    }
    
    func registerCollectionViewCell() {
        tripCollectionView.register(UINib(nibName: "TripCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "tripCollectionViewCell")
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tripCollectionViewCell", for: indexPath) as! TripCollectionViewCell
        
        return cell
    }
}
