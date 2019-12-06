import UIKit

class AlbumCell: UICollectionViewCell {
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var albumImg: UIImageView!
    
    
    func configure(with album:Album) {
        if let cover = album.cover {
            let img = UIImage(data: cover)
            albumImg.image = img
        }
        songTitle.text = album.albumTitle ?? "Hello World"
        artistName.text = album.artist ?? "This is an artist"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
