//
//  TripDataManager.swift
//  TripNote
//
//  Created by 임수진 on 6/12/24.
//

import Foundation
import UIKit
import Firebase

class TripDataManager {
    static let shared = TripDataManager()
    private let db = Firestore.firestore()
    private var tripModel: TripModel = TripModel()
    
    private init() {}
    
    func setTripModel(_ tripModel: TripModel) {
        self.tripModel = tripModel
    }
    
    func getTripModel() -> TripModel? {
        return self.tripModel
    }
    
    func setTripTitle(_ title: String) {
        self.tripModel.title = title
    }
    
    func setTripDates(startDate: Date, endDate: Date) {
        self.tripModel.startDate = startDate
        self.tripModel.endDate = endDate
    }
    
    func setTripLocation(_ location: String) {
        self.tripModel.location = location
    }
    
    func setTripColor(_ color: UIColor) {
        self.tripModel.color = color
    }
    
    func getTripTitle() -> String? {
        return self.tripModel.title
    }
    
    func getTripStartDate() -> Date? {
        return self.tripModel.startDate
    }
    
    func getTripEndDate() -> Date? {
        return self.tripModel.endDate
    }
    
    func getTripLocation() -> String? {
        return self.tripModel.location
    }
    
    func getTripColor() -> UIColor? {
        return self.tripModel.color
    }
    
    func clearTripModel() {
        self.tripModel = TripModel()
    }
    
    func fetchTrips(completion: @escaping ([TripModel]) -> Void) {
        let db = Firestore.firestore()
        db.collection("trips")
            .order(by: "createdAt", descending: true) // 생성한 순서로 정렬
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("데이터 불러오기 실패: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                var trips: [TripModel] = []
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let id = document.documentID
                    
                    let title = data["title"] as? String ?? ""
                    let startDateTimestamp = data["startDate"] as? Timestamp
                    let endDateTimestamp = data["endDate"] as? Timestamp
                    let location = data["location"] as? String ?? ""
                    let colorHexString = data["color"] as? String ?? "#000000"
                    
                    let startDate = startDateTimestamp?.dateValue()
                    let endDate = endDateTimestamp?.dateValue()
                    let color = UIColor(hex: colorHexString)
                    
                    let trip = TripModel(id: id,
                                         title: title,
                                         startDate: startDate,
                                         endDate: endDate,
                                         location: location,
                                         color: color)
                    trips.append(trip)
                }
                completion(trips)
                NotificationCenter.default.post(name: Notification.Name("TripAddedNotification"), object: nil)
            }
    }
    
    func updateTrip(tripID: String, title: String, startDate: Date, endDate: Date, location: String, completion: @escaping (Error?) -> Void) {
        let tripRef = db.collection("trips").document(tripID)
        
        tripRef.updateData([
            "title": title,
            "startDate": startDate,
            "endDate": endDate,
            "location": location
        ]) { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    func deleteTrip(tripID: String?, completion: @escaping (Error?) -> Void) {
        guard let tripID = tripID else {
            completion(nil)
            return
        }

        let db = Firestore.firestore()
        db.collection("trips").document(tripID).delete { error in
            if let error = error {
                completion(error)
                return
            }
            completion(nil)
        }
    }
}
