//
//  TripCollectionViewCell.swift
//  TripNote
//
//  Created by 임수진 on 6/6/24.
//

import UIKit

final class TripCollectionViewCell: UICollectionViewCell {
    static let cellIdentifier = "TripCollectionViewCell"

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var d_dayLabel: UILabel!
    @IBOutlet weak var tripLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    
    // -TODO: 더보기 메뉴 항목별 액션 추가
    lazy var menuItems: [UIAction] = {
        return [
            UIAction(title: "수정하기", image: UIImage(systemName: "square.and.pencil"), handler: { _ in }),
            UIAction(title: "삭제하기", image: UIImage(systemName: "trash"), attributes: .destructive, handler: { _ in }),
        ]
    }()
    
    lazy var menu: UIMenu = {
        return UIMenu(title: "", options: [], children: menuItems)
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
        configureComponents()
    }
    
    private func setupCell() {
        // 모서리를 둥글게 설정
        self.contentView.layer.cornerRadius = 10
        self.contentView.layer.masksToBounds = true
        // 셀의 그림자 설정
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        self.layer.masksToBounds = false
        
        moreButton.menu = menu
    }
    
    private func configureComponents() {
        // 디데이 Label
        d_dayLabel.layer.cornerRadius = 5
        d_dayLabel.clipsToBounds = true
        d_dayLabel.addPadding(UIEdgeInsets(top: 15, left: 30, bottom: 15, right: 30))
    }
    
    override func prepareForReuse() {
      super.prepareForReuse()
    }
    
    @IBAction func moreButtonTapped(_ sender: UIButton) {
        sender.showsMenuAsPrimaryAction = true
    }
}
