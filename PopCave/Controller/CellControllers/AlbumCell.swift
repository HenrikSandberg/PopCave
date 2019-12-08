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
    
    func configure(with album:(AlbumStruct, Data?)) {
        songTitle.text = album.0.strAlbum ?? "This is a title"
        artistName.text = album.0.strArtist ?? "This is an artist"
        albumImg.image = album.1 != nil ? UIImage(data: album.1!) : UIImage(named: "empty")
    }
}
