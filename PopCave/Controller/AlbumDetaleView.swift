//
//  AlbumDetaljeView.swift
//  PopCave
//
//  Created by Henrik Anthony Odden Sandberg on 03/12/2019.
//  Copyright © 2019 Henrik Anthony Odden Sandberg. All rights reserved.
//

import UIKit
import CoreData

//TODO:- Should fill this put
struct TrackStruct: Decodable {
    var strTrack: String?
    var intDuration: String?
    var intTrackNumber: String?
    var idTrack: String?
}

class AlbumDetaleView: UIViewController {
    @IBOutlet weak var coverImg: UIImageView!
    @IBOutlet weak var albumLbl: UILabel!
    @IBOutlet weak var artistLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private var selectedAlbum: Album? {
        didSet {
            loadItems()
        }
    }
    
    var trackList = [Track]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configure()
    }
    
    func getData(from album: Album) {
        selectedAlbum = album
    }

    func configure() {
        if let album = selectedAlbum {
            coverImg.image = UIImage(data: album.cover!)!
            albumLbl.text = album.albumTitle!
            artistLbl.text = album.artist!
        }
    }
    
    
    //MARK:- Load data from web
    private func loadTracks(from albumid: String) {
            if let url = URL(string: "https://www.theaudiodb.com/api/v1/json/1/track.php?m=\(albumid)") {
                URLSession.shared.dataTask(with: url) { (data, response, error) in

                    guard let data = data else { return }
                    
                    do {
                        let tracks = try JSONDecoder().decode([String:[TrackStruct]].self, from: data)

                        for track in tracks["track"]! {
                            self.addTrack(with: track)
                        }

                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }


                    } catch let jsonError {
                        print("error accured: \(jsonError)")
                    }

                }.resume()
            }
        }
    
    
    //MARK: - File methodes
    func saveToFile() {
        do{
            try context.save()
        } catch {
            print("Error saving item: \(error)")
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func loadItems(_ request: NSFetchRequest<Track> = Track.fetchRequest()) {
        
        let predicate = NSPredicate(format: "parentAlbum.albumId MATCHES %@", (selectedAlbum!.albumId!))
        request.predicate = predicate
        
        
        do {
            trackList = try context.fetch(request)
            
            if trackList.count <= 0 {
                loadTracks(from: selectedAlbum!.albumId!)
            }
            
            trackList.sort(by: {$0.number < $1.number})
            
            
        } catch{
            print("Error with load: \(error)")
        }
        

    }
    
    func addTrack(with data: TrackStruct) {
        var shouldAdd = true
        
        for content in trackList {
            if (content.title! == data.strTrack!) {
                shouldAdd = false
            }
        }
        
        if shouldAdd {
            let newTrack = Track(context: context)
            newTrack.isFavorite = false
            newTrack.length = data.intDuration!
            newTrack.title = data.strTrack!
            newTrack.parentAlbum = selectedAlbum
            newTrack.trackId = Int32(data.idTrack!)!
            newTrack.number = Int32(data.intTrackNumber!)!
            
            trackList.append(newTrack)
            saveToFile()
        }
    }
}
    
// MARK: - Table view
extension AlbumDetaleView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "trackCell", for: indexPath) as? TrackCell{
            let track = trackList[indexPath.row]
            cell.configure(with: track)
            return cell
        }
        
        return TrackCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        trackList[indexPath.row].isFavorite = !trackList[indexPath.row].isFavorite
        saveToFile()
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
