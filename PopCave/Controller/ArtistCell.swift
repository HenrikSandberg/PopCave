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
    }
}

//DispatchQueue.main.async {
//    self.collectionView.reloadData()
//}

//for album in albums["loved"]!{
//    if let contentUrl = album.strAlbumThumb {
//        if let url = URL(string: contentUrl) {
//            do {
//                let image = try Data(contentsOf : url)
//
//
//            } catch let err {
//                print(err)
//            }
//        }
//    }
//}
