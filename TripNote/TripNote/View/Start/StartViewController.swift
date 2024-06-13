//
//  StartViewController.swift
//  TripNote
//
//  Created by 임수진 on 6/12/24.
//

import UIKit

class StartViewController: UIViewController {
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    private func configureView() {
        // 시작 버튼
        startButton.layer.cornerRadius = 10
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        
        guard let signUpVC = self.storyboard?.instantiateViewController(withIdentifier: "signUpViewController") as? SignUpViewController else { return }
        self.navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        
        guard let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginViewController") as? LoginViewController else { return }
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
    
}
