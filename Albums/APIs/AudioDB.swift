//
//  AudioDB.swift
//  Albums
//
//  Created by Tyler Reckart on 6/9/23.
//

import Foundation
import Alamofire
import CoreData

struct AudioDBArtist: Codable {
    var strArtist: String?
    var strArtistAlternate: String?
    var strLabel: String?
    var intFormedYear: String?
    var intBornYear: String?
    var intDiedYear: String?
    var strDisbanded: String?
    var strStyle: String?
    var strGenre: String?
    var strMood: String?
    var strWebsite: String?
    var strBiographyEN: String?
    var strArtistThumb: String?
}

struct AudioDBAristResponse: Decodable {
    var artists: [AudioDBArtist]? = []
}

class AudioDB: ObservableObject {
    var container: NSPersistentContainer
    
    private let apikey: String = "523532"
    private let baseurl: String = "https://theaudiodb.com/api/v1/json"
    
    init(cont: NSPersistentContainer) {
        container = cont
    }
    
    public func lookupArtist(_ id: String) async -> Artist? {
        let me = "AudioDBService.lookupArtist(): "
        let qs = "artist-mb.php?i=\(id)"
        print(me + qs)
        
        let value = try? await AF
            .request("\(baseurl)/\(apikey)/\(qs)")
            .serializingDecodable(AudioDBAristResponse.self)
            .value
        let results = value?.artists ?? [] as [AudioDBArtist]
        
        if results.isEmpty {
            return nil
        }
        
        return self.mapAudioDBArtistToCoreDataModel(results[0])
    }
    
    public func mapAudioDBArtistToCoreDataModel(_ data: AudioDBArtist) -> Artist {
        let artist = Artist(context: container.viewContext)
    
        artist.name = data.strArtist
        artist.alternateName = data.strArtistAlternate
        artist.label = data.strLabel
        artist.yearFormed = data.intFormedYear
        artist.born = data.intBornYear
        artist.died = data.intDiedYear
        artist.yearDisbanded = data.strDisbanded
        artist.style = data.strStyle
        artist.mood = data.strMood
        artist.genre = data.strGenre
        artist.website = data.strWebsite
        artist.bio = data.strBiographyEN
        artist.thumbnail = data.strArtistThumb
        
        return artist
    }
}
