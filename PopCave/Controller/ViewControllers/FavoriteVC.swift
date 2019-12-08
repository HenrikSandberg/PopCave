//
//  FavoriteVC.swift
//  PopCave
//
//  Created by Henrik Anthony Odden Sandberg on 06/12/2019.
//  Copyright © 2019 Henrik Anthony Odden Sandberg. All rights reserved.
//

import UIKit
import CoreData

class FavoriteVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var trackArray = [Track]()
    private var recomendationArray = [String]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "FavoriteCell", bundle: nil), forCellReuseIdentifier: "customFavoriteCell")
        collectionView.register(UINib(nibName: "ArtistCell", bundle: nil), forCellWithReuseIdentifier: "customArtisCell")
        
        tableView.dataSource = self
        tableView.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadItems()
        getRecomendations()
    }
    
    //MARK:- Context Handling
    private func saveToFile(reload: Bool) {
        do {
            try context.save()
        } catch {
            print("Error saving item: \(error)")
        }
        
        if reload {
            tableView.reloadData()
        }
    }
    
    private func updateItem(at index: Int) {
        trackArray[index].isFavorite = false
        saveToFile(reload: false)
        trackArray.remove(at: index)
        getRecomendations()
    }
    
    
    //MARK:- Load items
    func loadItems() {
        do {
            let request: NSFetchRequest<Track> = Track.fetchRequest()
            let items = try context.fetch(request)
            
            for item in items {
                if item.isFavorite {
                    if !trackArray.contains(item) {
                        trackArray.append(item)
                    }
                }
            }
            
            trackArray.sort(by: {$0.trackId < $1.trackId})
            
            tableView.reloadData()
        } catch {
            print("Error with load: \(error)")
        }
    }
    
    
    //MARK:- Recomendations
    private func getRecomendations() {
        
        var baseUrl = "https://tastedive.com/api/similar?q="
        var artistArray = [String]()
        
        if trackArray.count <= 0 {
            return
        }
        
        for track in trackArray {
            var trackString = track.parentAlbum!.artist!
            trackString = trackString.replacingOccurrences(of: " ", with: "+")
            if !artistArray.contains(trackString) {
                artistArray.append(trackString)
            }
        }
        
        for number in Range(0...artistArray.count-1) {
            if (number < artistArray.count-1) {
                baseUrl = "\(baseUrl)\(artistArray[number])%2C"
            } else {
                baseUrl = "\(baseUrl)\(artistArray[number])"
            }
        }
        
        baseUrl = "\(baseUrl)/k=\(RECKEY)"
        
        if let url = URL(string: baseUrl) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                
                guard let data = data else { return }
                
                do {
                    let artists = try JSONDecoder().decode([String:[String:[RecomendationStruct]]].self, from: data)
                    var artistArray = [String]()
                    
                    if let artistCollection =  artists["Similar"]?["Results"]{
                        for artist in artistCollection {
                              if let name = artist.Name {
                                artistArray.append(name)
                              }
                          }
                        self.recomendationArray = artistArray
                    }
  
                } catch let error {
                    print("Error accured: \(error)")
                }
            }.resume()
        }
        
    }
}

// MARK: - Table view data source
extension FavoriteVC: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
         return 1
     }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return trackArray.count
     }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "customFavoriteCell", for: indexPath) as! FavoriteCell
         cell.configure(with: trackArray[indexPath.row])
         return cell
     }

     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
         if editingStyle == .delete {
             
             let alert = UIAlertController(title: "Would you like to remove \(self.trackArray[indexPath.row].title!) from your favorites?", message: "", preferredStyle: .alert)
             
             alert.addAction(UIAlertAction(title: "Cancel", style: .default) { cancel in
                 alert.dismiss(animated: true, completion: nil)
             })
             
             alert.addAction(UIAlertAction(title: "Remove", style: .default) { action in
                 self.updateItem(at: indexPath.row)
                 tableView.deleteRows(at: [indexPath], with: .fade)
             })
             
             present(alert, animated: true, completion: nil)

         }
     }
}

//MARK:- Collection View
extension FavoriteVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recomendationArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "artistCell", for: indexPath) as! ArtistCell
        cell.configure(with: recomendationArray[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "recomendationDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AlbumVC,
            let index = collectionView.indexPathsForSelectedItems?.first {
            
            //destination.getData(from: albumCatalog[index.row])
        }
    }
    
}

