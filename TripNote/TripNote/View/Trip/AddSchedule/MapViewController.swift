//
//  MapViewController.swift
//  TripNote
//
//  Created by 임수진 on 6/16/24.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var completedButton: UIButton!
    
    var placeName: String?
    var placeAddress: String?
    var placeLatitude: Double?
    var placeLongitude: Double?
    
    weak var delegate: MapViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapView()
        configureCompletedButton()
    }
    
    private func configureMapView() {
        if let latitude = placeLatitude, let longitude = placeLongitude {
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = placeName
            annotation.subtitle = placeAddress
            mapView.addAnnotation(annotation)
            
            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
    }
    
    private func configureCompletedButton() {
        // 선택하기 버튼
        completedButton.layer.cornerRadius = 10
        completedButton.addTarget(self, action: #selector(completedButtonTapped), for: .touchUpInside)
    }
    
    @IBAction func completedButtonTapped(_ sender: UIButton) {
        // 데이터 전달을 위해 delegate를 이용하여 장소 정보 전달
        delegate?.didSelectLocation(placeName: placeName, placeAddress: placeAddress)
        
        // 현재 화면 닫기
        dismiss(animated: true, completion: nil)
    }
}

protocol MapViewControllerDelegate: AnyObject {
    func didSelectLocation(placeName: String?, placeAddress: String?)
}
