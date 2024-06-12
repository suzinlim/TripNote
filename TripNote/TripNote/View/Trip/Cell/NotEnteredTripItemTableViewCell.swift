//
//  NotEnteredTripItemTableViewCell.swift
//  TripNote
//
//  Created by 임수진 on 6/12/24.
//

import UIKit

class NotEnteredTripItemTableViewCell: UITableViewCell {
    
    static let cellIdentifier = "NotEnteredTripItemTableViewCell"
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(at indexPath: IndexPath) {
        dayLabel.text = "Day " + String(indexPath.row + 1)
    }
    
    @IBAction func addTripAreaTapped(_ sender: UIButton) {
        
    }
}
