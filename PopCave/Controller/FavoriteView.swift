//
//  ViewController.swift
//  PopCave
//
//  Created by Henrik Anthony Odden Sandberg on 13/11/2019.
//  Copyright © 2019 Henrik Anthony Odden Sandberg. All rights reserved.
//

import UIKit
struct AlbumStruct: Decodable {
    var strArtist:String?
    var strAlbum:String?
    var strAlbumThumb:String?
    var idAlbum:String?
    var idArtist:String?
    var strDescription: String?
}

class FavoriteView: UIViewController, UICollectionViewDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    private var listContent = [AlbumStruct]()
    private var albumCovers = [UIImage?]()
    private var tableView = UITableView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTopAlbums()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        
        self.collectionView.frame = self.view.bounds;
        self.view.addSubview(self.collectionView);
    
    }
    
    
    private func loadTopAlbums() {
        if let url = URL(string: "https://www.theaudiodb.com/api/v1/json/1/mostloved.php?format=album") {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                
                guard let data = data else { return }
//                let dataString = String(data: data, encoding: .utf8)
//                print(dataString ?? "Nothing")
                
                do {
                    let albums = try JSONDecoder().decode([String:[AlbumStruct]].self, from: data)
                    
                    for album in albums["loved"]!{
                        if let contentUrl = album.strAlbumThumb {
                            if let url = URL(string: contentUrl) {
                                do {
                                    let data = try Data(contentsOf : url)
                                    let image = UIImage(data : data)
                                    self.albumCovers.append(image)
                                    self.listContent.append(album)
                                } catch let err {
                                    print(err)
                                }
                            }
                        }
                    }
                                    
                    DispatchQueue.main.async {
                        //self.listContent = albums["loved"]!
                        self.collectionView.reloadData()
                    }

                    
                } catch let jsonError {
                    print("error accured: \(jsonError)")
                }
                
            }.resume()
        }
    }
    
    
    @IBAction func toogleBetweenViews(_ sender: UIBarButtonItem) {
        print("Button pressed")
//        UIView toView
//        UIView fromView
//
//        if (self.collectionView.superview == self.view)
//        {
//            fromView = self.tableView
//            toView = self.collectionView
//        }
//        else
//        {
//            fromView = self.collectionView
//            toView = self.tableView
//        }
//
//        [fromView removeFromSuperview]
//
//        toView.frame = self.view.bounds
//        [self.view addSubview:toView]
    }
    
    
}


//MARK:- All Collection view realted code
extension FavoriteView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listContent.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as? AlbumCell else {
            assertionFailure("Should have dequeued SongCell here")
            return UICollectionViewCell()
        }
        return configured(cell, at: indexPath, with: listContent[indexPath.row])
    }
    
    func configured(_ cell: AlbumCell, at indexPath: IndexPath, with content: AlbumStruct) -> AlbumCell {

        cell.coverArt.image = self.albumCovers[indexPath.row]
        cell.songTitle.text = content.strAlbum ?? "Hello World"
        cell.artistName.text = content.strArtist ?? "This is an artist"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Hello")
        performSegue(withIdentifier: "goToAlbum", sender: self)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Clicekd")
        if let destination = segue.destination as? AlbumDetaleView, let index = collectionView.indexPathsForSelectedItems?.first {
            let album = listContent[index.row]
            
            if let cover = albumCovers[index.row] {
                destination.getFromCollection(
                    artist: album.strArtist!,
                    album: album.strAlbum!,
                    cover: cover,
                    id: album.idAlbum!
                )
            }
        }
    
    }
}
