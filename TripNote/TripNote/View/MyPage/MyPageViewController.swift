//
//  MyPageViewController.swift
//  TripNote
//
//  Created by 임수진 on 6/9/24.
//

import UIKit
import Firebase

class MyPageViewController: UIViewController {
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserInfo()
    }
    
    private func getUserInfo() {
        guard let currentUser = Auth.auth().currentUser else {
            print("사용자가 로그인되어 있지 않습니다.")
            return
        }
        
        db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUser.uid)
        
        userRef.getDocument { (document, error) in
            if let error = error {
                print("사용자 데이터 가져오기 실패: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                let userData = document.data()
                if let email = userData?["email"] as? String, let nickname = userData?["nickname"] as? String {
                    print("닉네임: \(nickname)")
                    print("이메일: \(email)")
                    self.nickNameLabel.text = nickname
                    self.emailLabel.text = email
                } else {
                    print("사용자 데이터에 닉네임 또는 이메일이 존재하지 않음")
                }
            } else {
                print("사용자 데이터가 존재하지 않음")
            }
        }
    }
    
    @IBAction func deleteAccountTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "계정 삭제", message: "정말로 계정을 삭제하시겠습니까?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in self.deleteAccount() }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }
    
    private func deleteAccount() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let userRef = db.collection("users").document(currentUser.uid)
        
        userRef.delete { error in
            if let error = error {
                print("계정 삭제 실패: \(error.localizedDescription)")
                self.showAlert(title: "계정 삭제 실패", message: error.localizedDescription)
            } else {
                print("계정 삭제 성공")
                self.showAlert(title: "계정 삭제 성공", message: "계정이 성공적으로 삭제되었습니다.")
                
                // Firebase에서 사용자 삭제
                currentUser.delete { error in
                    if let error = error {
                        print("Firebase에서 사용자 삭제 실패: \(error.localizedDescription)")
                    } else {
                        print("Firebase에서 사용자 삭제 성공")
                    }
                    
                    // 시작화면으로 돌아가기
                    guard let startVC = self.storyboard?.instantiateViewController(withIdentifier: "startViewController") else { return }
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        window.rootViewController = startVC
                    }
                }
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
