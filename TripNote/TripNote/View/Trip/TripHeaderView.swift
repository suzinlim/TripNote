//
//  TripHeaderView.swift
//  TripNote
//
//  Created by 임수진 on 6/9/24.
//

import UIKit

class TripHeaderView: UITableViewHeaderFooterView {
    
    var titleLabel = UILabel().then {
        $0.text = "통장이 텅장되는 여행"
        $0.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
    }
    
    var subTitleLabel = UILabel().then {
        $0.text = "여행 3일 전"
        $0.textColor = UIColor(named: "mainColor")
        $0.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
    }
    
    var dateLabel = UILabel().then {
        $0.text = "24. 06. 18 ~ 24. 06. 25"
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
}
