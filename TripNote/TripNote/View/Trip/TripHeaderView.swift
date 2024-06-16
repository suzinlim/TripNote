//
//  TripHeaderView.swift
//  TripNote
//
//  Created by 임수진 on 6/9/24.
//

import UIKit

class TripHeaderView: UITableViewHeaderFooterView {
    
    var titleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
    }
    
    var subTitleLabel = UILabel().then {
        $0.textColor = UIColor(named: "mainColor")
        $0.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
    }
    
    var dateLabel = UILabel().then {
        $0.textColor = .darkGray
        $0.font = UIFont.systemFont(ofSize: 15)
    }
    
    var scheduleLabel = UILabel().then {
        $0.text = "일정"
        $0.font = UIFont.systemFont(ofSize: 17)
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func setupViews() {
        [titleLabel, subTitleLabel, dateLabel, scheduleLabel].forEach { addSubview($0) }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(20)
            $0.leading.equalTo(16)
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.equalTo(titleLabel)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(20)
            $0.leading.equalTo(titleLabel)
        }
        
        scheduleLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(50)
            $0.leading.equalTo(titleLabel)
        }
    }
    
    func configure(with trip: TripModel) {
        // 여행 제목
        titleLabel.text = trip.title
        
        // 여행 날짜
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy. MM. dd"
        if let startDate = trip.startDate, let endDate = trip.endDate {
            dateLabel.text = "\(dateFormatter.string(from: startDate)) ~ \(dateFormatter.string(from: endDate))"
            
            // 여행 날짜 계산해서 subTitleLabel에 반영
            let currentDate = Date()
            if currentDate < startDate {
                let daysDifference = Calendar.current.dateComponents([.day], from: currentDate, to: startDate).day!
                subTitleLabel.text = "여행 \(daysDifference)일 전"
            } else {
                subTitleLabel.text = "여행 중"
            }
        } else {
            dateLabel.text = "날짜 정보 없음"
            subTitleLabel.text = ""
        }
    }
}
