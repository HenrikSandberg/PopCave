//
//  ViewController.swift
//  PopCave
//
//  Created by Henrik Anthony Odden Sandberg on 13/11/2019.
//  Copyright © 2019 Henrik Anthony Odden Sandberg. All rights reserved.
//

import UIKit
import CoreData

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
//    private var tableView = UITableView()
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var albumCatalog = [Album]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTopAlbumsFromCoreData()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        
        self.collectionView.frame = self.view.bounds;
        self.view.addSubview(self.collectionView);
    
    }
    
    
    //MARK:- Context related
    private func saveToFile() {
        do {
            try context.save()
        } catch {
            print("Error saving item: \(error)")
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func loadTopAlbumsFromCoreData(){
        
        let request: NSFetchRequest<Album> = Album.fetchRequest()
        
        do{
            albumCatalog = try context.fetch(request)
            
            if albumCatalog.count >= 0 {
                loadTopAlbums()
            } else {
                self.collectionView.reloadData()
            }
        } catch{
            print("Error with load: \(error)")
        }
    }
    
    func addAlbum(for album: AlbumStruct, with cover: Data?){
        let newAlbum = Album(context: context)
        newAlbum.artist = album.strArtist
        newAlbum.albumTitle = album.strAlbum
        newAlbum.albumId = album.idAlbum
        newAlbum.artisId = album.idArtist
        newAlbum.cover = cover
        
        albumCatalog.append(newAlbum)
        saveToFile()
    }
    
    
    //MARK:- Load Data from internett
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
                                    let image = try Data(contentsOf : url)
                                    self.addAlbum(for: album, with: image)
                                } catch let err {
                                    print(err)
                                }
                            }
                        }
                    }
                } catch let jsonError {
                    print("error accured: \(jsonError)")
                }
                
            }.resume()
        }
    }
    
    //MARK:- Toggle Views
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
        return albumCatalog.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as? AlbumCell
            else {
                assertionFailure("Should have dequeued SongCell here")
                return UICollectionViewCell()
            }
        return configured(cell, at: indexPath, with: albumCatalog[indexPath.row])
    }
    
    func configured(_ cell: AlbumCell, at indexPath: IndexPath, with content: Album) -> AlbumCell {

        if let cover = content.cover {
            cell.coverArt.image = UIImage(data: cover)
        }
        
        cell.songTitle.text = content.albumTitle ?? "Hello World"
        cell.artistName.text = content.artist ?? "This is an artist"
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToAlbum", sender: self)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AlbumDetaleView,
            let index = collectionView.indexPathsForSelectedItems?.first {
            
            let album = albumCatalog[index.row]
            destination.getFromCollection(
                artist: album.artist!,
                album: album.albumTitle!,
                cover: album.cover!,
                id: album.artisId!
            )
        }
    }
}
