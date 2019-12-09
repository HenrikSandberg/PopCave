//
//  ArtistVC.swift
//  PopCave
//
//  Created by Henrik Anthony Odden Sandberg on 08/12/2019.
//  Copyright © 2019 Henrik Anthony Odden Sandberg. All rights reserved.
//

import UIKit

class ArtistVC: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segemntController: UISegmentedControl!
    @IBOutlet weak var artistImage: UIImageView!
    @IBOutlet weak var artistName: UILabel!
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var albums = [(album: AlbumStruct, cover: Data)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.register( UINib(nibName: "AlbumLineCell", bundle: nil),forCellWithReuseIdentifier: "customAlbumLineCell")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    func configure(from name: String) {
        getArtist(from: name)
    }
    
    private func createLoader() -> UIAlertController {
         let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

         let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
         loadingIndicator.hidesWhenStopped = true
         loadingIndicator.style = UIActivityIndicatorView.Style.medium
         loadingIndicator.startAnimating()
         
         alert.view.addSubview(loadingIndicator)
         return alert
     }
    
    private func setUpContent(with data: Data, artist: ArtistStruct) {
        DispatchQueue.main.async {
            self.artistName.text = artist.strArtist!
            self.artistImage.image = UIImage(data: data)
            self.artistImage.layer.borderWidth = 4
            self.artistImage.layer.masksToBounds = false
            self.artistImage.layer.borderColor = #colorLiteral(red: 0.9411764706, green: 0.3843137255, blue: 0.4392156863, alpha: 1)
            self.artistImage.layer.cornerRadius = self.artistImage.frame.height/2
            self.artistImage.clipsToBounds = true
        }
    }
    
    
    //MARK:- Load data
    private func getArtist(from name: String) {
        DispatchQueue.main.async {
            var urlString = name.lowercased()
            urlString = urlString.replacingOccurrences(of: " ", with: "%20")
            
            if let url = URL(string: "https://www.theaudiodb.com/api/v1/json/1/search.php?s=\(urlString)")  {
                
                URLSession.shared.dataTask(with: url) { (data, response, error) in
                    
                    guard let data = data else { return }
                    
                    do {
                        let artists = try JSONDecoder().decode([String:[ArtistStruct]].self, from: data)
                        
                        for artist in artists["artists"]! {
                            if let contentUrl = artist.strArtistThumb {
                                if let url = URL(string: contentUrl) {
                                    do {
                                        let image = try Data(contentsOf : url)
                                        self.setUpContent(with: image, artist: artist)
                                        self.getAlbums(for: name)
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
    }
    
    private func getAlbums(for artist: String){
        let strUrl = "https://www.theaudiodb.com/api/v1/json/"
        if let url = URL(string: "\(strUrl)\(THEAUDIODB_KEY)/searchalbum.php?s=\(artist)") {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                
                guard let data = data else { return }
                
                do {
                    let albums = try JSONDecoder().decode([String:[AlbumStruct]].self, from: data)
                    
                    DispatchQueue.main.async {
                        let alert = self.createLoader()
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                    for album in albums["album"]! {
                        if let strUrl = album.strAlbumThumb {
                            if let url = URL(string: strUrl) {
                                do {
                                    let image = try Data(contentsOf : url)
                                    self.albums.append((album: album, cover: image))
                                    DispatchQueue.main.async {
                                        self.collectionView.reloadData()
                                    }
                                } catch let err {
                                    print(err)
                                }
                            }
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
//                        self.updateLayout()
//                        self.collectionView.reloadData()
                    }
                    
                } catch let jsonError {
                    print("error accured: \(jsonError)")
                }
                
            }.resume()
        } else {
            print("NO sucesess with request")
            print(strUrl)
        }
    }
    
    //MARK:- Context Handling
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
    
    private func addAlbum(for album: AlbumStruct, with cover: Data?) -> Album? {
        var shouldAdd = true
        var albumCatalog = [Album]()
        
        for content in albumCatalog {
            if content.albumTitle! == album.strAlbum! {
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
            newAlbum.top50Album = false
                
                
            albumCatalog.append(newAlbum)
            saveToFile()
            return newAlbum
        }
        return nil
    }
}

//MARK:- Collection view
extension ArtistVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customAlbumLineCell", for: indexPath) as? AlbumCell
            else {
                assertionFailure("Should have dequeued AlbumCell here")
                return UICollectionViewCell()
            }
        
        return configured(cell, at: indexPath, with: (albums[indexPath.row]))
    }
    
    func configured(_ cell: AlbumCell, at indexPath: IndexPath, with content: (AlbumStruct, Data?)) -> AlbumCell {
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
            
//            if !showInList {
//                itemWidth = CGFloat(149)
//                itemHeight = CGFloat(200)
//            } else {
            itemWidth = view.bounds.width - CGFloat(16)
            itemHeight = CGFloat(95)
            
            layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
            layout.invalidateLayout()
        }
        collectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AlbumVC, let index = collectionView.indexPathsForSelectedItems?.first {
            let (album, cover) = (albums[index.row])
            
            if let alb = addAlbum(for: album, with: cover){
                destination.getData(from: alb)
            }
        }
    }
}
