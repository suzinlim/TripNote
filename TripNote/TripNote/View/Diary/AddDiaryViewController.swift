//
//  AddDiaryViewController.swift
//  TripNote
//
//  Created by 임수진 on 6/11/24.
//

import UIKit
import BSImagePicker
import Photos
import Firebase
import FirebaseStorage

class AddDiaryViewController: UIViewController {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var diaryTextView: UITextView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    var selectedImages: [UIImage] = []
    var newDiaryRef: DocumentReference?
    
    let textViewPlaceHolder = "일기를 작성해보세요"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCollectionView()
        configureView()
        setKeyboard()
    }
    
    private func setCollectionView() {
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        if let layout = imageCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 10
        }
        imageCollectionView.isPagingEnabled = true
        
        let photoNib = UINib(nibName: "PhotoCollectionViewCell", bundle: nil)
        imageCollectionView.register(photoNib, forCellWithReuseIdentifier: PhotoCollectionViewCell.cellIdentifier)
    }
    
    private func configureView() {
        // 뒤로가기 버튼
        let backbutton = UIBarButtonItem(image: UIImage(named: "back"), style: .done, target: self, action: #selector(backButtonTapped))
        
        // 날짜 Label
        dateLabel.text = formatDate(Date())
        
        // 완료 버튼
        let completedbutton = UIBarButtonItem(image: UIImage(named: "check"), style: .done, target: self, action: #selector(completedButtonTapped))
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.leftBarButtonItem = backbutton
        self.navigationItem.rightBarButtonItem = completedbutton
        
        diaryTextView.becomeFirstResponder()
    }
     
     private func formatDate(_ date: Date) -> String {
         let formatter = DateFormatter()
         formatter.locale = Locale(identifier: "ko_KR")
         formatter.dateFormat = "yy. MM. dd"
         return formatter.string(from: date)
     }
    
    private func setKeyboard() {
//        diaryTextView.isFirstResponder = true
    }
    
    @objc func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func completedButtonTapped(_ sender: UIButton) {
        saveDiaryToFirebase()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addImageButtonTapped(_ sender: UIButton) {
        let imagePicker = ImagePickerController()
        imagePicker.settings.selection.max = 10
        imagePicker.settings.theme.selectionStyle = .numbered
        imagePicker.settings.fetch.assets.supportedMediaTypes = [.image]
        
        self.presentImagePicker(imagePicker, select: { (asset) in
        }, deselect: { (asset) in
        }, cancel: { (assets) in
        }, finish: { (assets) in
            self.handleSelectedAssets(assets)
        })
    }
    
    private func handleSelectedAssets(_ assets: [PHAsset]) {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat
        
        for asset in assets {
            let targetSize = CGSize(width: imageCollectionView.frame.height, height: imageCollectionView.frame.height)
            PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { (image, info) in
                if let image = image {
                    self.selectedImages.append(image)
                }
            }
        }
        self.imageCollectionView.reloadData()
    }
    
    private func saveDiaryToFirebase() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        let db = Firestore.firestore()
        let diariesRef = db.collection("diaries")
        
        newDiaryRef = diariesRef.document()
        
        uploadImagesToFirebase { imageUrls in
            let diaryData: [String: Any] = [
                "userId": currentUser.uid,
                "text": self.diaryTextView.text,
                "timestamp": FieldValue.serverTimestamp(),
                "imageUrls": imageUrls
            ]
            
            self.newDiaryRef?.setData(diaryData) { error in
                if let error = error {
                    print("일기 작성 실패: \(error.localizedDescription)")
                } else {
                    print("일기 작성 성공")
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    private func uploadImagesToFirebase(completion: @escaping ([String]) -> Void) {
        guard !selectedImages.isEmpty else {
            completion([])
            return
        }
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        var imageUrls: [String] = []
        let dispatchGroup = DispatchGroup()
        
        for (index, image) in selectedImages.enumerated() {
            let imageName = "\(newDiaryRef?.documentID)_\(index).jpg"
            let imageRef = storageRef.child("diary_images/\(imageName)")
            
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                dispatchGroup.enter()
                imageRef.putData(imageData, metadata: nil) { metadata, error in
                    if let error = error {
                        print("Error uploading image to Firebase Storage: \(error.localizedDescription)")
                        dispatchGroup.leave()
                    } else {
                        imageRef.downloadURL { url, error in
                            if let error = error {
                                print("Error getting download URL: \(error.localizedDescription)")
                            } else if let url = url {
                                imageUrls.append(url.absoluteString)
                            }
                            dispatchGroup.leave()
                        }
                    }
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            completion(imageUrls)
        }
    }
}

// -MARK: UICollectionViewDataSource
extension AddDiaryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.cellIdentifier, for: indexPath) as! PhotoCollectionViewCell
        cell.imageView.contentMode = .scaleAspectFill
        cell.imageView.clipsToBounds = true
        cell.imageView.image = selectedImages[indexPath.item]
        return cell
    }
}

// -MARK: UICollectionViewDelegateFlowLayout
extension AddDiaryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace: CGFloat = 10
        let availableWidth = collectionView.frame.width - paddingSpace
        let itemWidth = availableWidth / 2
        let itemHeight = itemWidth
        return CGSize(width: itemWidth, height: itemHeight)
    }
}

// -MARK: UITextViewDelegate
extension AddDiaryViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == textViewPlaceHolder {
            textView.text = nil
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = textViewPlaceHolder
            textView.textColor = .opaqueSeparator
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let inputString = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let oldString = textView.text, let newRange = Range(range, in: oldString) else { return true }
        let newString = oldString.replacingCharacters(in: newRange, with: inputString).trimmingCharacters(in: .whitespacesAndNewlines)

        let characterCount = newString.count
        guard characterCount <= 100 else { return false }

        return true
    }
}
