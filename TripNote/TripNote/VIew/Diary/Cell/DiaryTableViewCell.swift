//
//  DiaryTableViewCell.swift
//  TripNote
//
//  Created by 임수진 on 6/9/24.
//

import UIKit

class DiaryTableViewCell: UITableViewCell {
    
    static let cellIdentifier = "DiaryTableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        setLayout()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setLayout() {
        contentView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        contentView.preservesSuperviewLayoutMargins = false
    }
    
}
