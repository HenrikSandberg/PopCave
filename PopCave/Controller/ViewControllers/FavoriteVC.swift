//
//  FavoriteVC.swift
//  PopCave
//
//  Created by Henrik Anthony Odden Sandberg on 06/12/2019.
//  Copyright © 2019 Henrik Anthony Odden Sandberg. All rights reserved.
//

import UIKit
import CoreData

class FavoriteVC: UITableViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var header: UIView!
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private var trackArray = [Track]()
    private var updateFavorite = false
    
    private var recomendationArray = [Recommendation]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "FavoriteCell", bundle: nil), forCellReuseIdentifier: "customFavoriteCell")
        collectionView.register(UINib(nibName: "ArtistCell", bundle: nil), forCellWithReuseIdentifier: "customArtisCell")
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem        
        updateFavorite = UserDefaults.standard.bool(forKey: "updateFavorite")
    
        collectionView.dataSource = self
        collectionView.delegate = self
        
        tableView.tableHeaderView = header
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadItems()
        getRecommendations()
    }
    
    //MARK:- Context Handling
    private func saveToFile() {
        do {
            try context.save()
        } catch {
            print("Error saving item: \(error)")
        }
    }
    
    private func updateItem(at index: Int) {
        trackArray[index].isFavorite = false
        saveToFile()
        trackArray.remove(at: index)
        UserDefaults.standard.set(true, forKey: "updateFavorite")
        getRecommendations()
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
            
            //trackArray.sort(by: {$0.trackId < $1.trackId})
            
            tableView.reloadData()
        } catch {
            print("Error with load: \(error)")
        }
    }
    
    
    //MARK:- Recomendations
    private func resetRecommendations() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Recommendation")
        fetchRequest.includesPropertyValues = false
        
        do {
            let request: NSFetchRequest<Recommendation> = Recommendation.fetchRequest()
            recomendationArray = try context.fetch(request)
            recomendationArray.removeAll()
            saveToFile()
            
            let items = try context.fetch(fetchRequest) as! [NSManagedObject]

            for item in items {
                context.delete(item)
            }
            
            try context.save()
        } catch {
            print("Error with load: \(error)")
        }
    }
    
    private func loadRecommendations() {
        
        let request: NSFetchRequest<Recommendation> = Recommendation.fetchRequest()
        
        do {
            recomendationArray = try context.fetch(request)
            
            if recomendationArray.count < 0 {
                UserDefaults.standard.set(true, forKey: "updateFavorite")
                getRecommendations()
            } else {
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
            
        } catch {
            print("Error with load: \(error)")
        }
    }
    
    private func addRecommendation(with name: String){
        var shouldAdd = true
        
        for content in recomendationArray {
            if content.artistName! == name {
                shouldAdd = false
            }
        }
        
        if shouldAdd {
            let newRecommendation = Recommendation(context: context)
            newRecommendation.artistName = name
                
            recomendationArray.append(newRecommendation)
            saveToFile()
        }
    }

    
    private func getRecommendations() {
        
        var baseUrl = "https://tastedive.com/api/similar?q="
        var artistArray = [String]()
        
        if trackArray.count <= 0  {
            return
        }
        
        if !updateFavorite {
            loadRecommendations()
            return
        }
        
        resetRecommendations()
        
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
                    
                    if let artistCollection =  artists["Similar"]?["Results"]{
                        for artist in artistCollection {
                              if let name = artist.Name {
                                self.addRecommendation(with: name)
                              }
                          }
                        //self.recomendationArray = artistArray
                        UserDefaults.standard.set(false, forKey: "updateFavorite")
                    }
  
                } catch let error {
                    print("Error accured: \(error)")
                }
            }.resume()
        }
        
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
         return 1
     }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return trackArray.count
     }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "customFavoriteCell", for: indexPath) as! FavoriteCell
         cell.configure(with: trackArray[indexPath.row])
         return cell
     }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
   
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = self.trackArray[sourceIndexPath.row]
        trackArray.remove(at: sourceIndexPath.row)
        trackArray.insert(movedObject, at: destinationIndexPath.row)
        saveToFile()
    }
    
    

    // MARK: - Navigation
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "fromFavoriteToAlbum", sender: self)
    }
}

//MARK:- Collection View
extension FavoriteVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recomendationArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "artistCell", for: indexPath) as! ArtistCell
        cell.configure(with: recomendationArray[indexPath.row].artistName!)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "recomendationDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ArtistVC, let index = collectionView.indexPathsForSelectedItems?.first {
            destination.configure(from: recomendationArray[index.row].artistName!)
        }
        
        if let destination = segue.destination as? AlbumVC, let indexPath = tableView.indexPathForSelectedRow {
            destination.getData(from: trackArray[indexPath.row].parentAlbum!)
        }
    }
    
}

