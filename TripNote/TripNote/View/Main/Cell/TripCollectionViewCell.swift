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
    
    var onDeleteAction: (() -> Void)?
    var onEditAction: (() -> Void)?
    
    lazy var menuItems: [UIAction] = {
        return [
            UIAction(title: "수정하기", image: UIImage(systemName: "square.and.pencil"), handler: { [weak self] _ in
                self?.onEditAction?()
            }),
            UIAction(title: "삭제하기", image: UIImage(systemName: "trash"), attributes: .destructive, handler: { [weak self] _ in
                self?.onDeleteAction?()
            }),
        ]
    }()
    
    lazy var menu: UIMenu = {
        return UIMenu(title: "", options: [], children: menuItems)
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
        configureComponent()
    }
    
    private func setupCell() {
        // 모서리 둥글게 설정
        self.contentView.layer.cornerRadius = 10
        self.contentView.layer.masksToBounds = true
        // 셀 그림자 설정
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        self.layer.masksToBounds = false
        
        moreButton.menu = menu
        moreButton.showsMenuAsPrimaryAction = true
    }
    
    private func configureComponent() {
        // 디데이 Label
        d_dayLabel.layer.cornerRadius = 5
        d_dayLabel.clipsToBounds = true
        d_dayLabel.addPadding(UIEdgeInsets(top: 15, left: 30, bottom: 15, right: 30))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onDeleteAction = nil
        onEditAction = nil
    }
    
    func configure(with trip: TripModel, onEditAction: @escaping () -> Void, onDeleteAction: @escaping () -> Void) {
        
        // 여행 제목
        tripLabel.text = trip.title
        
        // 여행 노트 색
        backgroundImageView.backgroundColor = trip.color
        
        // 여행 날짜
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let startDate = trip.startDate, let endDate = trip.endDate {
            dateLabel.text = "\(dateFormatter.string(from: startDate)) ~ \(dateFormatter.string(from: endDate))"
        } else {
            dateLabel.text = "날짜 정보 없음"
        }
        
        // 여행 시작 날짜와 오늘 날짜의 차이 계산 -> d_dayLabel 표시 목적
        if let startDate = trip.startDate {
            let calendar = Calendar.current
            let currentDate = Date()
            let components = calendar.dateComponents([.day], from: currentDate, to: startDate)
            
            if let days = components.day {
                if days > 0 {
                    d_dayLabel.text = "D-\(days)"
                } else if days == 0 {
                    d_dayLabel.text = "D-day"
                } else {
                    d_dayLabel.text = "D+\(abs(days))"
                }
            } else {
                d_dayLabel.text = ""
            }
        } else {
            d_dayLabel.text = ""
        }
        
        self.onEditAction = onEditAction
        self.onDeleteAction = onDeleteAction
    }
}
