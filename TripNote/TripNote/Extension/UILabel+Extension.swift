//
//  UILabel+Extension.swift
//  TripNote
//
//  Created by 임수진 on 6/7/24.
//

import Foundation
import UIKit

extension UILabel {
    func addPadding(_ insets: UIEdgeInsets) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: insets.left + insets.right, height: insets.top + insets.bottom))
        self.addSubview(paddingView)
        
        paddingView.translatesAutoresizingMaskIntoConstraints = false
        paddingView.topAnchor.constraint(equalTo: self.topAnchor, constant: insets.top).isActive = true
        paddingView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -insets.bottom).isActive = true
        paddingView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: insets.left).isActive = true
        paddingView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -insets.right).isActive = true
    }
}
