//
//  PhotoCollectionViewCell.swift
//  TripNote
//
//  Created by 임수진 on 6/16/24.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    static let cellIdentifier = "PhotoCollectionViewCell"
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
