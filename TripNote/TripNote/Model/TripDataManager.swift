//
//  TripDataManager.swift
//  TripNote
//
//  Created by 임수진 on 6/12/24.
//

import Foundation
import UIKit

class TripDataManager {
    static let shared = TripDataManager()
    
    private var tripTitle: String?
    private var tripStartDate: Date?
    private var tripEndDate: Date?
    private var tripLocation: String?
    private var tripColor: UIColor?
    
    private init() {}
    
    func setTrip(title: String, startDate: Date, endDate: Date, location: String, color: UIColor) {
        self.tripTitle = title
        self.tripStartDate = startDate
        self.tripEndDate = endDate
        self.tripLocation = location
        self.tripColor = color
    }
    
    func setTripTitle(_ title: String) {
        self.tripTitle = title
    }
    
    func setTripDates(startDate: Date, endDate: Date) {
        self.tripStartDate = startDate
        self.tripEndDate = endDate
    }
    
    func setTripLocation(_ location: String) {
        self.tripLocation = location
    }
    
    func setTripColor(_ color: UIColor) {
        self.tripColor = color
    }
    
    func getTripTitle() -> String? {
        return self.tripTitle
    }
    
    func getTripStartDate() -> Date? {
        return self.tripStartDate
    }
    
    func getTripEndDate() -> Date? {
        return self.tripEndDate
    }
    
    func getTripLocation() -> String? {
        return self.tripLocation
    }
    
    func getTripColor() -> UIColor? {
        return self.tripColor
    }
}
