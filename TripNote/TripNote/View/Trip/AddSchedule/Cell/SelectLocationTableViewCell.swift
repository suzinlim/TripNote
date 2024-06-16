//
//  SelectLocationTableViewCell.swift
//  TripNote
//
//  Created by 임수진 on 6/16/24.
//

import UIKit

class SelectLocationTableViewCell: UITableViewCell {
    
    static let cellIdentifier = "SelectLocationTableViewCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
