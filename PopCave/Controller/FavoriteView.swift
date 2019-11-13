//
//  ViewController.swift
//  PopCave
//
//  Created by Henrik Anthony Odden Sandberg on 13/11/2019.
//  Copyright © 2019 Henrik Anthony Odden Sandberg. All rights reserved.
//

import UIKit
struct AlbumStruct {
    var artist:String
    var album:String
    var artwork:String
    
    init(json: [String: Any]) {
         album = json["title"] as? String ?? "Nothing"
         artist = "Somthing"
        artwork = "Somthing else"
    }
}

class FavoriteView: UIViewController, UICollectionViewDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    private var listContent = [AlbumStruct]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let jsonUrlString = "https://jsonplaceholder.typicode.com/todos"
        
        if let url = URL(string: jsonUrlString){
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                
                guard let data = data else { return }
//                let dataString = String(data: data, encoding: .utf8)
//                print(dataString ?? "Nothing")
                
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else {
                        print("Could not get JSON")
                        return
                    }
                    
                    let album = AlbumStruct(json: json)
                    print(album.album)
                    
                } catch let jsonError {
                    print("error accured: \(jsonError)")
                }
                
            }.resume()
        }

        
        collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
}

extension FavoriteView: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as? AlbumCell else {
          assertionFailure("Should have dequeued SongCell here")
          return UICollectionViewCell()
        }
        return configured(cell, at: indexPath)
    }
    
    func configured(_ cell: AlbumCell, at indexPath: IndexPath) -> AlbumCell {
        cell.songTitle.text = "Hello World"
        cell.artistName.text = "This is an artist"
        //cell.coverArt.image =
        return cell
    }
}

//func loadData(from urlString: String) {
//
//    guard let url = URL(string: urlString) else {return}
//    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
//
//        guard let dataResponse = data, error == nil else {
//              print(error?.localizedDescription ?? "Response Error")
//              return
//        }
//
//        do {
//            let jsonResponse = try JSONSerialization.jsonObject(with: dataResponse, options: [])
//
//            guard let jsonArray = jsonResponse as? [[String: Any]] else { return }
//
//            DispatchQueue.main.sync(execute: {
//                for content in jsonArray{
//                    guard let title = content["title"] as? String else {
//                        print("Coud not cast to string")
//                        return
//                    }
//                    self.data.append(albumContent(title: title, album: "Test", artwork: "hello"))
//                }
//
//                self.collectionView.reloadData()
//            })
//
//
//         } catch let parsingError {
//            print("Error", parsingError)
//       }
//    }
//    task.resume()
//}
