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

class ListViewController: UIViewController {
    
    var ligandsArray: [String] = []
    var searchLigands: [String] = []
    // to do: add api class 
    
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
        //to do: api request method call
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
