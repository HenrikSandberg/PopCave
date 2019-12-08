//
//  ArtistCell.swift
//  PopCave
//
//  Created by Henrik Anthony Odden Sandberg on 08/12/2019.
//  Copyright © 2019 Henrik Anthony Odden Sandberg. All rights reserved.
//

import UIKit

class ArtistCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var text: UILabel!
    
    func configure(with artist: String) {
        text.text = artist
        getArtistData(artist)
    }
    
    private func setImage(with data:Data) {
        DispatchQueue.main.async {
            self.image.image = UIImage(data: data)
            self.image.layer.borderWidth = 1
            self.image.layer.masksToBounds = false
            self.image.layer.borderColor = UIColor.black.cgColor
            self.image.layer.cornerRadius = self.image.frame.height/2
            self.image.clipsToBounds = true
        }
    }
    
    private func getArtistData(_ name: String){
        DispatchQueue.main.async {
            var urlString = name.lowercased()
            urlString = urlString.replacingOccurrences(of: " ", with: "%20")
            
            if let url = URL(string: "https://www.theaudiodb.com/api/v1/json/1/search.php?s=\(urlString)")  {
                
                URLSession.shared.dataTask(with: url) { (data, response, error) in
                    
                    guard let data = data else { return }
                    
                    do {
                        let artists = try JSONDecoder().decode([String:[ArtistStruct]].self, from: data)
                        
                        for artist in artists["artists"]! {
                            print(artist.strArtist!)
                            
                            if let contentUrl = artist.strArtistThumb {
                                if let url = URL(string: contentUrl) {
                                    do {
                                        let image = try Data(contentsOf : url)
                                        self.setImage(with: image)
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
            } else {
                print("URL is nil")
            }
        }
    }
}
