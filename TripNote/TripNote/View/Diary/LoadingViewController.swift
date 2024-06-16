//
//  LoadingViewController.swift
//  TripNote
//
//  Created by 임수진 on 6/17/24.
//

import UIKit

import UIKit

import UIKit

class LoadingViewController: UIViewController {

    let loadingIndicator = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoadingIndicator()
    }

    private func setupLoadingIndicator() {
        // 로딩 인디케이터 설정
        loadingIndicator.color = .gray
        loadingIndicator.center = view.center
        loadingIndicator.hidesWhenStopped = true 
        view.addSubview(loadingIndicator)
    }

    func startLoading() {
        // 로딩 시작 시 호출되는 메서드
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
    }

    func stopLoading() {
        // 로딩 종료 시 호출되는 메서드
        loadingIndicator.stopAnimating()
        view.isUserInteractionEnabled = true
    }
}
