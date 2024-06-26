//
//  ScheduleModel.swift
//  TripNote
//
//  Created by 임수진 on 6/15/24.
//

import Foundation

struct ScheduleModel {
    var id: String?
    var date: Date
    var place: String
    var placeAddress: String
    var memo: String
    
    init(id: String? = nil, date: Date, place: String, placeAddress: String, memo: String) {
        self.id = id
        self.date = date
        self.place = place
        self.placeAddress = placeAddress
        self.memo = memo
    }
}
