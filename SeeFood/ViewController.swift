//
//  ViewController.swift
//  SeeFood
//
//  Created by Cygnus on 7/3/19.
//  Copyright © 2019 KSS Co., Ltd. All rights reserved.
//  Designed by Andyle

import UIKit
import VisualRecognitionV3
import RestKit
import SVProgressHUD

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate  {

    let apikey = "u-VBkv1GjjlJHHuTb5cXLvyZQvNQblTHvruhJ12Tznf7"
    let version = "2019-07-03"
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    var classificationResults = [String:Double]()

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        cameraButton.isEnabled = false
        SVProgressHUD.show()
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            imageView.image =  image
            
            imagePicker.dismiss(animated: true, completion: nil)
            
            let visualRecognition = VisualRecognition(version: version, apiKey: apikey)
            
            let imageData = image.jpegData(compressionQuality: 0.01)
            let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentURL.appendingPathComponent("tempImage.jpg")
            try? imageData?.write(to: fileURL, options: [])
            
            visualRecognition.classify(imagesFile: imageData, imagesFilename: nil, imagesFileContentType: nil, url: nil, threshold: nil, owners: nil, classifierIDs: nil, acceptLanguage: "en", headers: nil) { (classifiedImages, error) in
                self.classificationResults = [:]
                let classes = classifiedImages?.result?.images.first!.classifiers.first!.classes
                if let clss = classes?.count {
                    for index in 0..<clss{
                        self.classificationResults[classes![index].className] = classes![index].score
                    }
                    let results = self.classificationResults.sorted(by: { (a : (key: String, value: Double),b : (key: String, value: Double)) -> Bool in
                        return a.value > b.value
                    })
                    print(results)
                    
                    DispatchQueue.main.async {
                        self.cameraButton.isEnabled = true
                        SVProgressHUD.dismiss()
                    }
                    
                    DispatchQueue.main.async {
                        self.navigationItem.title = "\(results.first!)"
                    }
                }
                
            }
            
        }
        else {
            print("There was an error picking the image :( ")
        }
        
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
}

