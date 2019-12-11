import UIKit

class TrackCell: UITableViewCell {
    @IBOutlet weak var addFave: UIImageView!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    
    
    func configure(with track: Track) {
        songTitle.text = "\(track.number). \(track.title!)"
        let image = UIImage(systemName: track.isFavorite ? "star.fill" : "star")
        addFave.image = image
        
        let time = Int(track.length!)!.milisToSecounds.minutesAndSecoundsString
        timeLbl.text = time
    }
}
