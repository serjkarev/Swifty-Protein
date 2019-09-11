//
//  ViewController.swift
//  Swifty Protein
//
//  Created by MacBook Pro on 8/28/19.
//  Copyright © 2019 MacBook Pro. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import LocalAuthentication

class ListViewController: UIViewController {
    
    var ligandsArray: [String] = []
    var searchLigands: [String] = []
    let networkingClient = NetworkingClient()
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var ligandsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ligandsTableView.dataSource = self
        ligandsTableView.delegate = self
        searchBar.delegate = self
        
        searchBar.barTintColor = UIColor.clear
        searchBar.backgroundImage = UIImage()
        
        readFromTxt()
        searchLigands = ligandsArray
        setupView()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK:- Read from file
    
    private func readFromTxt() {
        if let path = Bundle.main.path(forResource: "ligands", ofType: "txt") {
            do {
                let text = try String(contentsOfFile: path , encoding: String.Encoding.utf8)
                ligandsArray = text.components(separatedBy: "\n")
                ligandsArray.removeLast()
            }catch{
                print("Error \(error)")
            }
        }
    }

    //MARK:- Background video block
    
    private func setupView() {
        let path = URL(fileURLWithPath:  Bundle.main.path(forResource: "backgroundvideo", ofType: "mp4")!)
        let player = AVPlayer(url: path)
        let newLayer = AVPlayerLayer(player: player)
        newLayer.frame = self.videoView.frame
        self.videoView.layer.addSublayer(newLayer)
        newLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        player.play()
        player.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none
        NotificationCenter.default.addObserver(self, selector: #selector(ListViewController.videoDidPlayToEnd(_:)), name: NSNotification.Name("AVPlayerItemDidPlayToEndTimeNotification"), object: player.currentItem)
    }

    @objc func videoDidPlayToEnd(_ notification: Notification) {
        let player: AVPlayerItem = notification.object as! AVPlayerItem
        player.seek(to: CMTime.zero)
    }
    
}

//MARK: - TableView Methods

extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchLigands.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ligandsTableView.dequeueReusableCell(withIdentifier: "ligandCell", for: indexPath) as! LigandsTableViewCell
        cell.libandName.text = searchLigands[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        networkingClient.getLigand(ligandName: searchLigands[indexPath.row]) { (json, error) in
            print("??????????????")
            print(json)
            print("!!!!!!!!!!!!!")
            print(error)
        }
    }
    
}

//MARK: - SearchBar Methods

extension ListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchLigands = searchText.isEmpty ? ligandsArray : ligandsArray.filter { (item: String) -> Bool in
            return item.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        ligandsTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchLigands = ligandsArray
        ligandsTableView.reloadData()
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
}
//MARK: - TouchID FaceID Methods

//extension ListViewController {
//    
//    func authenticationWithTouchID() {
//        let localAuthenticationContext = LAContext()
//        localAuthenticationContext.localizedFallbackTitle = "Use Passcode"
//        
//        var authError: NSError?
//        let reasonString = "To access the secure data"
//        
//        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
//            
//            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString) { success, evaluateError in
//                
//                if success {
//                    
//                    //TODO: User authenticated successfully, take appropriate action
//                    
//                } else {
//                    //TODO: User did not authenticate successfully, look at error and take appropriate action
//                    guard let error = evaluateError else {
//                        return
//                    }
//                    
//                    print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
//                    
//                    //TODO: If you have choosen the 'Fallback authentication mechanism selected' (LAError.userFallback). Handle gracefully
//                    
//                }
//            }
//        } else {
//            
//            guard let error = authError else {
//                return
//            }
//            //TODO: Show appropriate alert if biometry/TouchID/FaceID is lockout or not enrolled
//            print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error.code))
//        }
//    }
//    
//    func evaluatePolicyFailErrorMessageForLA(errorCode: Int) -> String {
//        var message = ""
//        if #available(iOS 11.0, macOS 10.13, *) {
//            switch errorCode {
//            case LAError.biometryNotAvailable.rawValue:
//                message = "Authentication could not start because the device does not support biometric authentication."
//                
//            case LAError.biometryLockout.rawValue:
//                message = "Authentication could not continue because the user has been locked out of biometric authentication, due to failing authentication too many times."
//                
//            case LAError.biometryNotEnrolled.rawValue:
//                message = "Authentication could not start because the user has not enrolled in biometric authentication."
//                
//            default:
//                message = "Did not find error code on LAError object"
//            }
//        } else {
//            switch errorCode {
//            case LAError.touchIDLockout.rawValue:
//                message = "Too many failed attempts."
//                
//            case LAError.touchIDNotAvailable.rawValue:
//                message = "TouchID is not available on the device"
//                
//            case LAError.touchIDNotEnrolled.rawValue:
//                message = "TouchID is not enrolled on the device"
//                
//            default:
//                message = "Did not find error code on LAError object"
//            }
//        }
//        
//        return message;
//    }
//    
//    func evaluateAuthenticationPolicyMessageForLA(errorCode: Int) -> String {
//        
//        var message = ""
//        
//        switch errorCode {
//            
//        case LAError.authenticationFailed.rawValue:
//            message = "The user failed to provide valid credentials"
//            
//        case LAError.appCancel.rawValue:
//            message = "Authentication was cancelled by application"
//            
//        case LAError.invalidContext.rawValue:
//            message = "The context is invalid"
//            
//        case LAError.notInteractive.rawValue:
//            message = "Not interactive"
//            
//        case LAError.passcodeNotSet.rawValue:
//            message = "Passcode is not set on the device"
//            
//        case LAError.systemCancel.rawValue:
//            message = "Authentication was cancelled by the system"
//            
//        case LAError.userCancel.rawValue:
//            message = "The user did cancel"
//            
//        case LAError.userFallback.rawValue:
//            message = "The user chose to use the fallback"
//            
//        default:
//            message = evaluatePolicyFailErrorMessageForLA(errorCode: errorCode)
//        }
//        
//        return message
//    }
//}
