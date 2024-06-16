//
//  SearchViewController.swift
//  TripNote
//
//  Created by 임수진 on 6/16/24.
//

import UIKit
import MapKit

class SearchViewController: UIViewController {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    private var searchCompleter = MKLocalSearchCompleter() // 검색을 도와주는 변수
    private var searchResults = [MKLocalSearchCompletion]() // 검색 결과를 담는 변수
    private var localSearch: MKLocalSearch?
    private let koreaBounds = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 36.34, longitude: 127.77),
        span: MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
    )
    
    var selectedPlaceName: String?
    var selectedPlaceAddress: String?
    var selectedPlace: MKMapItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchCompleter()
        setupTableView()
        setupSearchTextField()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        searchCompleter.delegate = nil
    }

    private func setupSearchCompleter() {
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .pointOfInterest // 검색 결과 타입 설정
        searchCompleter.region = koreaBounds // 검색 범위 설정
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SelectLocationTableViewCell", bundle: nil), forCellReuseIdentifier: SelectLocationTableViewCell.cellIdentifier)
        tableView.tableFooterView = UIView()
    }

    private func setupSearchTextField() {
        searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        if let searchText = textField.text, !searchText.isEmpty {
            searchCompleter.queryFragment = searchText
        } else {
            searchResults.removeAll()
            tableView.reloadData()
        }
    }

    private func search(for suggestedCompletion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: suggestedCompletion)
        search(using: searchRequest)
    }

    private func search(using searchRequest: MKLocalSearch.Request) {
        searchRequest.region = koreaBounds
        searchRequest.resultTypes = .pointOfInterest
        localSearch = MKLocalSearch(request: searchRequest)
        localSearch?.start { [weak self] (response, error) in
            guard let self = self else { return }
            if let error = error {
                print("검색 오류: \(error.localizedDescription)")
                return
            }
            guard let place = response?.mapItems.first else {
                print("검색된 장소가 없음")
                return
            }
            
            // 검색된 장소 정보 저장
            self.selectedPlaceName = place.name
            self.selectedPlaceAddress = place.placemark.title
            
            // NotificationCenter 통해 데이터 전달
            NotificationCenter.default.post(name: .selectedPlaceNotification, object: self, userInfo: [
                "placeName": self.selectedPlaceName,
                "placeAddress": self.selectedPlaceAddress
            ])
            
            self.dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - Extensions
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SelectLocationTableViewCell.cellIdentifier, for: indexPath) as? SelectLocationTableViewCell else { return UITableViewCell() }

        cell.titleLabel.text = searchResults[indexPath.row].title
        cell.subTitleLabel.text = searchResults[indexPath.row].subtitle

        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedCompletion = searchResults[indexPath.row]
        search(for: selectedCompletion)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            searchCompleter.queryFragment = searchText
        } else {
            searchResults.removeAll()
            tableView.reloadData()
        }
    }
}

extension SearchViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        tableView.reloadData()

        // 검색 결과 출력
        for result in searchResults {
            print("장소: \(result.title), 도로명 주소: \(result.subtitle)")
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("위치 검색 실패: \(error.localizedDescription)")
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension Notification.Name {
    static let selectedPlaceNotification = Notification.Name("SelectedPlaceNotification")
}
