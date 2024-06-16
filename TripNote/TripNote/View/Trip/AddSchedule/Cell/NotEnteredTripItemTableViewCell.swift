//
//  NotEnteredTripItemTableViewCell.swift
//  TripNote
//
//  Created by 임수진 on 6/12/24.
//

import UIKit

protocol NotEnteredTripItemTableViewCellDelegate: AnyObject {
    func addScheduleTapped(cell: NotEnteredTripItemTableViewCell, tripId: String)
}

class NotEnteredTripItemTableViewCell: UITableViewCell {
    
    static let cellIdentifier = "NotEnteredTripItemTableViewCell"
    var delegate: NotEnteredTripItemTableViewCellDelegate?
    var trip: TripModel?
    var tripId: String?
    var indexPath: IndexPath?
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with trip: TripModel, at indexPath: IndexPath) {
        // 셀 스타일
        selectionStyle = .none
        
        self.trip = trip
        self.tripId = trip.id // tripId 설정 추가
        self.indexPath = indexPath // indexPath 설정 추가
        
        dayLabel.text = "Day " + String(indexPath.section + 1)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM월 dd일"
        
        if let startDate = trip.startDate {
            let currentDate = Calendar.current.date(byAdding: .day, value: indexPath.section, to: startDate)!
            dateLabel.text = dateFormatter.string(from: currentDate)
        } else {
            dateLabel.text = "지정된 날짜가 없습니다"
        }
    }
    
    @IBAction func addScheduleButtonTapped(_ sender: UIButton) {
        guard let tripId = tripId, let indexPath = indexPath else {
            print("Trip ID or IndexPath is nil")
            return
        }
        
        let sectionDate = calculateSectionDate(for: indexPath)
        
        // delegate를 통해 셀과 tripId 그리고 선택된 날짜 전달
        delegate?.addScheduleTapped(cell: self, tripId: tripId)
    }
    
    private func calculateSectionDate(for indexPath: IndexPath) -> Date {
        guard let trip = trip, let startDate = trip.startDate else {
            fatalError("Trip or startDate should not be nil")
        }
        
        let currentDate = Calendar.current.date(byAdding: .day, value: indexPath.section, to: startDate)!
        return currentDate
    }
}
