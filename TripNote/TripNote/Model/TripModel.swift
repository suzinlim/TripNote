//
//  TripModel.swift
//  TripNote
//
//  Created by 임수진 on 6/15/24.
//

import Foundation
import UIKit

class TripModel {
    var id: String?
    var title: String?
    var startDate: Date?
    var endDate: Date?
    var location: String?
    var color: UIColor?
    
    init(id: String? = nil, title: String? = nil, startDate: Date? = nil, endDate: Date? = nil, location: String? = nil, color: UIColor? = nil) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
        self.color = color
    }
}
