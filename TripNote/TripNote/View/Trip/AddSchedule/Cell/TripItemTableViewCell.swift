//
//  TripItemTableViewCell.swift
//  TripNote
//
//  Created by 임수진 on 6/9/24.
//

import UIKit

class TripItemTableViewCell: UITableViewCell {
    static let cellIdentifier = "TripItemTableViewCell"

    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var placeDetailLabel: UILabel!
    @IBOutlet weak var memoLabel: UILabel!
    @IBOutlet weak var memoView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setConfigure()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setConfigure() {
        // 셀 스타일
        selectionStyle = .none
        
        // 숫자 Label
        numberLabel.layer.cornerRadius = 10
        numberLabel.clipsToBounds = true
        
        // 메모 UIView
        memoView.layer.cornerRadius = 5
    }
    
    func configure(with schedule: ScheduleModel, at indexPath: IndexPath) {
        numberLabel.text = String(indexPath.row + 1)
        placeLabel.text = schedule.place
        placeDetailLabel.text = schedule.placeAddress
        memoLabel.text = schedule.memo
    }
}
