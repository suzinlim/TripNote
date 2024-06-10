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
    }
    
    func configure(at indexPath: IndexPath) {
        numberLabel.text = String(indexPath.row + 1)
    }
}
