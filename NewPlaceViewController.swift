//
//  NewPlaceViewController.swift
//  Restaurants
//
//  Created by Beibarys Shaggy on 19.08.2021.
//

import UIKit

class NewPlaceViewController: UITableViewController {
    
    @IBOutlet weak var placeOfImage: UIImageView!
    
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var placeLocation: UITextField!
    @IBOutlet weak var placeType: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var newPlace = Restaurant()
    var currentPlace: Restaurant?
    var imageIsChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        saveButton.isEnabled = false
        placeName.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        
        setupEditScreen()
    }

    
//    Mark: Table View delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let cameraIcon = #imageLiteral(resourceName: "camera")
            let photoIcon = #imageLiteral(resourceName: "photo")
            
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                // Choose camera
                self.chooseImagePicker(source: .camera)
            }
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photo = UIAlertAction(title: "Photo", style: .default) { _ in
                // Choose photo
                self.chooseImagePicker(source: .photoLibrary)
            }
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true)
        } else {
            view.endEditing(true)
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
    func saveNewPlace() {
        
        var image: UIImage?
        
        if imageIsChanged {
            image = placeOfImage.image
        } else {
            image = #imageLiteral(resourceName: "imagePlaceholder")
        }
        
        let imageData = image?.pngData()
        
        newPlace = Restaurant(name: placeName.text!, location: placeLocation.text, type: placeType.text, imageData: imageData)
        
        if currentPlace != nil {
            try! realm.write {
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = imageData
            }
        } else {
            StorageManager.saveObject(newPlace)
        }
        

    }
    
    private func setupEditScreen() {
        if currentPlace != nil {
            setupNavigationBar()
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else { return }
            imageIsChanged = true
            placeOfImage.image = image
            placeName.text = currentPlace?.name
            placeLocation.text = currentPlace?.location
            placeType.text = currentPlace?.type
            placeOfImage.contentMode = .scaleAspectFill

        }
    }
    
    private func setupNavigationBar() {
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        saveButton.isEnabled = true
    }
}

//   Mark: Text field delegate

extension NewPlaceViewController: UITextFieldDelegate {
    // hide keyboard to click Done
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func textChanged() {
        if placeName.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }

    
}

extension NewPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        placeOfImage.image = info[.editedImage] as? UIImage
        imageIsChanged = true
        placeOfImage.clipsToBounds = true
        placeOfImage.contentMode = .scaleAspectFill
        dismiss(animated: true)
    }
}
