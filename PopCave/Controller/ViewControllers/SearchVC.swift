import UIKit
import CoreData

class SearchVC: UIViewController, UICollectionViewDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    private var albumStructCatalog = [(AlbumStruct, Data)]()
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        loader.stopAnimating()
        loader.hidesWhenStopped = true
        
        self.collectionView.register(UINib(nibName: "AlbumCell", bundle: nil), forCellWithReuseIdentifier: "customAlbumCell")
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
            newAlbum.year = album.intYearReleased
            newAlbum.cover = cover
            newAlbum.top50Album = false
                
                
            albumCatalog.append(newAlbum)
            saveToFile()
            return newAlbum
        }
        return nil
    }
    
}

//MARK: - Search bar methods
extension SearchVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text {
            albumStructCatalog.removeAll()
            
            DispatchQueue.main.async {
                self.loader.startAnimating()
                self.collectionView.reloadData()
                searchBar.resignFirstResponder()
            }
            
            search(for: text)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let text = searchBar.text {
            if text.count == 0 {
                 DispatchQueue.main.async {
                    self.loader.stopAnimating()
                    self.albumStructCatalog.removeAll()
                    self.collectionView.reloadData()
                    searchBar.resignFirstResponder()
                 }
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            self.loader.stopAnimating()
            self.albumStructCatalog.removeAll()
            self.collectionView.reloadData()
            searchBar.resignFirstResponder()
        }
    }
    
    private func search(for text: String, typeSeach: String = "s") {
        var nameStr = text.lowercased()
        nameStr = nameStr.replacingOccurrences(of: " ", with: "%20")
        
        let strUrl = "https://www.theaudiodb.com/api/v1/json/\(THEAUDIODB_KEY)/searchalbum.php?\(typeSeach)=\(nameStr)"
        
        if let url = URL(string: strUrl) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                
                guard let data = data else {
                    self.search(for: text, typeSeach: "a")
                    return
                }
                
                do {
                    let albums = try JSONDecoder().decode([String:[AlbumStruct]].self, from: data)
                    
                    for album in albums["album"]! {
                        if let strUrl = album.strAlbumThumb {
                            if let url = URL(string: strUrl) {
                                do {
                                    let image = try Data(contentsOf : url)
                                    self.albumStructCatalog.append((album, image))
                                    
                                    DispatchQueue.main.async {
                                        self.loader.stopAnimating()
                                        self.albumStructCatalog.sort(by: {Int($0.0.intYearReleased!)! > Int($1.0.intYearReleased!)!})
                                        self.updateLayout()
                                        self.collectionView.reloadData()
                                    }
                                } catch let err {
                                    print(err)
                                }
                            }
                        }
                    }
                    
                } catch {
                    if (typeSeach != "a"){
                        self.search(for: text, typeSeach: "a")
                    } else {
                        DispatchQueue.main.async {
                            self.loader.stopAnimating()
                        }
                    }
                }
                
            }.resume()
        }
    }
}

//MARK:- Collection view
extension SearchVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumStructCatalog.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customAlbumCell", for: indexPath) as? AlbumCell
            else {
                assertionFailure("Should have dequeued AlbumCell here")
                return UICollectionViewCell()
            }
        
        return configured(cell, at: indexPath, with: albumStructCatalog[indexPath.row])
    }
    
    func configured(_ cell: AlbumCell, at indexPath: IndexPath, with content: (AlbumStruct, Data?)) -> AlbumCell {
        cell.configure(with: content)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "searchToAlbum", sender: self)
    }
    
    private func updateLayout() {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let itemWidth = view.bounds.width / 2.5
            let itemHeight = CGFloat(200)
            
            layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
            layout.invalidateLayout()
        }
        collectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AlbumVC, let index = collectionView.indexPathsForSelectedItems?.first {
            let (album, cover) = (albumStructCatalog[index.row])
            let alb = addAlbum(for: album, with: cover)
            destination.getData(from: alb!)
        }
    }
}
