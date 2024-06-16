//
//  DiaryModel.swift
//  TripNote
//
//  Created by 임수진 on 6/16/24.
//

import Foundation

struct DiaryModel {
    let userId: String
    let text: String
    let timestamp: Date
    let imageUrls: [String]?
    
    init(userId: String, text: String, timestamp: Date, imageUrls: [String]?) {
        self.userId = userId
        self.text = text
        self.timestamp = timestamp
        self.imageUrls = imageUrls
    }
}
