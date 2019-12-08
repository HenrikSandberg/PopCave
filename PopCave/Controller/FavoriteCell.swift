//
//  FavoriteCell.swift
//  PopCave
//
//  Created by Henrik Anthony Odden Sandberg on 07/12/2019.
//  Copyright © 2019 Henrik Anthony Odden Sandberg. All rights reserved.
//

import UIKit

class FavoriteCell: UITableViewCell {
    @IBOutlet weak var albumCoverImg: UIImageView!
    @IBOutlet weak var artistLbl: UILabel!
    @IBOutlet weak var songlbl: UILabel!
    @IBOutlet weak var playTimelbl: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with track: Track) {
        let album = track.parentAlbum!
        albumCoverImg.image = UIImage(data: album.cover!)
        artistLbl.text = album.artist!
        songlbl.text = track.title!
        
        let time = Int(track.length!)!.msToSeconds.minuteSecondMS
        playTimelbl.text = time
    }
    
}
