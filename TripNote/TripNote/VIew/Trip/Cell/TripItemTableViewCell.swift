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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureView()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func configureView() {
        // 숫자 Label
        numberLabel.layer.cornerRadius = 10
        numberLabel.clipsToBounds = true
    }
    
}
