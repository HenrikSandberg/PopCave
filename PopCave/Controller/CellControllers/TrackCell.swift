//
//  TrackCell.swift
//  PopCave
//
//  Created by Henrik Anthony Odden Sandberg on 04/12/2019.
//  Copyright © 2019 Henrik Anthony Odden Sandberg. All rights reserved.
//

import UIKit

class TrackCell: UITableViewCell {
    @IBOutlet weak var addFave: UIImageView!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    
    
    func configure(with track: Track) {
        songTitle.text = "\(track.number). \(track.title!)"
        let image = UIImage(systemName: track.isFavorite ? "star.fill" : "star")
        addFave.image = image
        
        let time = Int(track.length!)!.msToSeconds.minutesAndSecoundsString
        timeLbl.text = time
    }
}
