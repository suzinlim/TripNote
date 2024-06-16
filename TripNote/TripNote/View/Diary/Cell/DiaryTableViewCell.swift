//
//  DiaryTableViewCell.swift
//  TripNote
//
//  Created by 임수진 on 6/9/24.
//

import UIKit
import FirebaseStorage
import SDWebImage

class DiaryTableViewCell: UITableViewCell {
    
    static let cellIdentifier = "DiaryTableViewCell"

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var contentLabel: UILabel!
    
    var diary: DiaryModel?
    var storageRef: StorageReference?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setLayout()
        setupCollectionView()
        setupStorageReference()
    }

     override func setSelected(_ selected: Bool, animated: Bool) {
         super.setSelected(selected, animated: animated)
     }
     
     private func setLayout() {
         contentView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
         contentView.preservesSuperviewLayoutMargins = false
     }
     
     private func setupCollectionView() {
         imageCollectionView.dataSource = self
         imageCollectionView.delegate = self
         
         // collectionView layout 설정
         let layout = UICollectionViewFlowLayout()
         layout.scrollDirection = .horizontal
         layout.minimumLineSpacing = 10
         let cellSize = imageCollectionView.frame.height
         layout.itemSize = CGSize(width: cellSize, height: cellSize)
         
         // collectionView 설정
         imageCollectionView.collectionViewLayout = layout
         imageCollectionView.isPagingEnabled = true
         imageCollectionView.showsHorizontalScrollIndicator = false
         
         // collectionViewCell 등록
         let photoNib = UINib(nibName: "PhotoCollectionViewCell", bundle: nil)
         imageCollectionView.register(photoNib, forCellWithReuseIdentifier: PhotoCollectionViewCell.cellIdentifier)
     }
     
     private func setupStorageReference() {
         storageRef = Storage.storage().reference()
     }
     
     func configure(with diary: DiaryModel) {
         self.diary = diary
         dateLabel.text = formatDate(diary.timestamp)
         contentLabel.text = diary.text
         imageCollectionView.reloadData()
         
         selectionStyle = .none
     }
     
     private func formatDate(_ date: Date) -> String {
         let formatter = DateFormatter()
         formatter.locale = Locale(identifier: "ko_KR")
         formatter.dateFormat = "yy. MM. dd"
         return formatter.string(from: date)
     }
 }

// MARK: - UICollectionViewDataSource
extension DiaryTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return diary?.imageUrls?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.cellIdentifier, for: indexPath) as! PhotoCollectionViewCell
        
        guard let imageUrls = diary?.imageUrls else {
            return cell
        }

        if indexPath.item < imageUrls.count {
            let imageUrl = imageUrls[indexPath.item]
            if let url = URL(string: imageUrl) {
                cell.imageView.sd_setImage(with: url, placeholderImage: nil, options: [.progressiveLoad])
            }
        }

        cell.imageView.contentMode = .scaleAspectFill
        cell.imageView.clipsToBounds = true

        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension DiaryTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSize = collectionView.frame.height
        return CGSize(width: itemSize, height: itemSize)
    }
}
