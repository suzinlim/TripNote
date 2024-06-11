//
//  DimmedViewController.swift
//  TripNote
//
//  Created by 임수진 on 6/12/24.
//

import UIKit

class DimmedViewController: UIViewController {
    
    weak var currentViewController: UIViewController?

    let dimmedView = UIView().then {
        $0.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
        setupLayout()
        dimmedView.alpha = 0.0
    }
    
    func addContentViewController(_ viewController: UIViewController) {
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
        
        // Content ViewController의 레이아웃 설정
        viewController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showBottomSheet()
    }
    
    func addSubViews() {
        view.addSubview(dimmedView)
    }
    
    func setupLayout() {
        dimmedView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    public func showBottomSheet() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            self.dimmedView.alpha = 0.7
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    public func hideBottomSheetAndGoBack() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            self.dimmedView.alpha = 0.0
            self.view.layoutIfNeeded()
        }) { [weak self] _ in
            guard let self else { return }
            if self.presentingViewController != nil {
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    func transitionToViewController(_ viewController: UIViewController) {
        // 이전 뷰 컨트롤러 제거
        currentViewController?.removeFromParent()
        currentViewController?.view.removeFromSuperview()

        // 새로운 뷰 컨트롤러 추가
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
        
        // 현재 뷰 컨트롤러 갱신
        currentViewController = viewController
    }
}
