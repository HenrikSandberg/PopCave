import UIKit

class AlbumCell: UICollectionViewCell {
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var albumImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with album:Album) {
        albumImg.image = UIImage(data: album.cover!) ?? UIImage(named: "empty")
        songTitle.text = album.albumTitle ?? "This is a title"
        artistName.text = album.artist ?? "This is an artist"
    }
    

}
