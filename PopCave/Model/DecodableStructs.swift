import Foundation

struct TrackStruct: Decodable {
    var strTrack: String?
    var intDuration: String?
    var intTrackNumber: String?
    var idTrack: String?
}

struct AlbumStruct: Decodable {
    var strArtist: String?
    var strAlbum: String?
    var strAlbumThumb: String?
    var idAlbum: String?
    var idArtist: String?
    var strDescription: String?
    var intYearReleased: String?
    
}

struct RecomendationStruct: Decodable {
    var Name: String?
}

struct ArtistStruct:Decodable {
    var strArtist: String?
    var strStyle: String?
    var strBiographyEN: String?
    var strCountry: String?
    var strArtistThumb: String?
}
