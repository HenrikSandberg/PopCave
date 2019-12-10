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
    
    func configure(for artist: String, with data:Data) {
        text.text = artist
        self.image.image = UIImage(data: data)
        self.image.layer.borderWidth = 4
        self.image.layer.masksToBounds = false
        self.image.layer.borderColor = #colorLiteral(red: 0.9411764706, green: 0.3843137255, blue: 0.4392156863, alpha: 1)
        self.image.layer.cornerRadius = self.image.frame.height/2
        self.image.clipsToBounds = true
    }
}
