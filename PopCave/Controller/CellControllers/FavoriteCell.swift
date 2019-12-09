import UIKit

class FavoriteCell: UITableViewCell {
    @IBOutlet weak var albumCoverImg: UIImageView!
    @IBOutlet weak var artistLbl: UILabel!
    @IBOutlet weak var songlbl: UILabel!
    @IBOutlet weak var playTimelbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with track: Track) {
        let album = track.parentAlbum!
        albumCoverImg.image = UIImage(data: album.cover!)
        artistLbl.text = album.artist!
        songlbl.text = track.title!
        
        let time = Int(track.length!)!.msToSeconds.minutesAndSecoundsString
        playTimelbl.text = time
    }
    
}
