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

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    
    var ligandsArray: [String] = []
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var ligandsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ligandsTableView.dataSource = self
        ligandsTableView.delegate = self
        readFromTxt()
        setupView()
        // Do any additional setup after loading the view.
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
    
    //MARK:- Table view methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ligandsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ligandsTableView.dequeueReusableCell(withIdentifier: "ligandCell", for: indexPath)
        cell.textLabel?.text = ligandsArray[indexPath.row]
        cell.textLabel?.textAlignment = NSTextAlignment.center
        cell.textLabel?.textColor = UIColor.cyan
        return cell
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

extension ListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("Click!!!!!!!!!!!!!!!")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("text Change?????????????????")
    }
}
