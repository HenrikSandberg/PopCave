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
    @IBOutlet weak var segemntController: UISegmentedControl!
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var albumCatalog = [Album]()
    private var showInList = true
    
    private var layoutType: String {
        return showInList ? "customAlbumLineCell" : "customAlbumCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadTopAlbumsFromCoreData()
        self.collectionView.register(UINib(nibName: "AlbumCell", bundle: nil), forCellWithReuseIdentifier: "customAlbumCell")
        
       self.collectionView.register(UINib(nibName: "AlbumLineCell", bundle: nil), forCellWithReuseIdentifier: "customAlbumLineCell")
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        showInList = UserDefaults.standard.bool(forKey: "displayMode")
        segemntController.selectedSegmentIndex = showInList ? 1 : 0
        updateLayout()
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
            
            if (albumCatalog.count < 50) {
                
                let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

                let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
                loadingIndicator.hidesWhenStopped = true
                loadingIndicator.style = UIActivityIndicatorView.Style.medium
                loadingIndicator.startAnimating();

                alert.view.addSubview(loadingIndicator)
                present(alert, animated: true, completion: nil)
                
                loadTopAlbums()
                
                
                dismiss(animated: true, completion: nil)
            } else {
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
            
        } catch{
            print("Error with load: \(error)")
        }
    }
    
    func addAlbum(for album: AlbumStruct, with cover: Data?){
        var shouldAdd = true
        
        for content in albumCatalog {
            if (content.albumTitle! == album.strAlbum!) {
                shouldAdd = false
            }
        }
        
        if shouldAdd {
            let newAlbum = Album(context: context)
            newAlbum.artist = album.strArtist
            newAlbum.albumTitle = album.strAlbum
            newAlbum.albumId = album.idAlbum
            newAlbum.artisId = album.idArtist
            newAlbum.cover = cover
                
                
            albumCatalog.append(newAlbum)
            saveToFile()
        }
        
    }
    
    
    //MARK:- Load Data from internett
    private func loadTopAlbums() {
        
        //displayLoading()
        
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
    @IBAction func clickOnSegment(_ sender: UISegmentedControl) {
        
        showInList = !showInList
        
        UserDefaults.standard.set(showInList, forKey: "displayMode")
        updateLayout()
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
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: layoutType, for: indexPath) as? AlbumCell
            else {
                assertionFailure("Should have dequeued AlbumCell here")
                return UICollectionViewCell()
            }
        return configured(cell, at: indexPath, with: albumCatalog[indexPath.row])
    }
    
    func configured(_ cell: AlbumCell, at indexPath: IndexPath, with content: Album) -> AlbumCell {
        cell.configure(with: content)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToAlbum", sender: self)
        
    }
    
    private func updateLayout() {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let itemWidth: CGFloat
            let itemHeight: CGFloat
            
            if !showInList {
                itemWidth = CGFloat(149)
                itemHeight = CGFloat(195)
            } else {
                itemWidth = view.bounds.width - CGFloat(16)
                itemHeight = CGFloat(95)
            }
            
            layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
            layout.invalidateLayout()
        }
        collectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AlbumDetaleView,
            let index = collectionView.indexPathsForSelectedItems?.first {
            
            let album = albumCatalog[index.row]
            destination.getData(from: album)
        }
    }
}
