//
//  iTunesAlbumsSearchResponse.swift
//  Albums
//
//  Created by Tyler Reckart on 5/22/23.
//

import Foundation

struct iTunesAlbumsSearchResponse: Decodable {
    var resultCount: Int
    var results: [iTunesAlbum]
}

struct iTunesArtistSearchResponse: Decodable {
    var resultCount: Int
    var results: [iTunesArtist]
}


//{
//  "resultCount": 6,
//  "results": [
//    {
//      "wrapperType": "artist",
//      "artistType": "Artist",
//      "artistName": "Polyphia",
//      "artistLinkUrl": "https://music.apple.com/us/artist/polyphia/640294344?uo=4",
//      "artistId": 640294344,
//      "amgArtistId": 3015593,
//      "primaryGenreName": "Rock",
//      "primaryGenreId": 21
//    },
//    {
//      "wrapperType": "collection",
//      "collectionType": "Album",
//      "artistId": 640294344,
//      "collectionId": 1078457179,
//      "amgArtistId": 3015593,
//      "artistName": "Polyphia",
//      "collectionName": "Renaissance",
//      "collectionCensoredName": "Renaissance",
//      "artistViewUrl": "https://music.apple.com/us/artist/polyphia/640294344?uo=4",
//      "collectionViewUrl": "https://music.apple.com/us/album/renaissance/1078457179?uo=4",
//      "artworkUrl60": "https://is1-ssl.mzstatic.com/image/thumb/Music49/v4/6d/a9/0d/6da90d64-7aa6-7fc4-26f1-f2b4dcf452c2/886445701180.jpg/60x60bb.jpg",
//      "artworkUrl100": "https://is1-ssl.mzstatic.com/image/thumb/Music49/v4/6d/a9/0d/6da90d64-7aa6-7fc4-26f1-f2b4dcf452c2/886445701180.jpg/100x100bb.jpg",
//      "collectionPrice": 9.99,
//      "collectionExplicitness": "notExplicit",
//      "trackCount": 12,
//      "copyright": "℗ 2016 Equal Vision Records, Inc.",
//      "country": "USA",
//      "currency": "USD",
//      "releaseDate": "2016-03-11T08:00:00Z",
//      "primaryGenreName": "Alternative"
//    },
//    {
//      "wrapperType": "collection",
//      "collectionType": "Album",
//      "artistId": 640294344,
//      "collectionId": 1416234351,
//      "amgArtistId": 3015593,
//      "artistName": "Polyphia",
//      "collectionName": "New Levels New Devils",
//      "collectionCensoredName": "New Levels New Devils",
//      "artistViewUrl": "https://music.apple.com/us/artist/polyphia/640294344?uo=4",
//      "collectionViewUrl": "https://music.apple.com/us/album/new-levels-new-devils/1416234351?uo=4",
//      "artworkUrl60": "https://is1-ssl.mzstatic.com/image/thumb/Music124/v4/57/5c/00/575c009a-6d69-6ac4-7c91-7e307d920279/794558040969.jpg/60x60bb.jpg",
//      "artworkUrl100": "https://is1-ssl.mzstatic.com/image/thumb/Music124/v4/57/5c/00/575c009a-6d69-6ac4-7c91-7e307d920279/794558040969.jpg/100x100bb.jpg",
//      "collectionPrice": 9.99,
//      "collectionExplicitness": "notExplicit",
//      "trackCount": 10,
//      "copyright": "℗ 2018 Equal Vision Records, Inc.",
//      "country": "USA",
//      "currency": "USD",
//      "releaseDate": "2018-10-12T07:00:00Z",
//      "primaryGenreName": "Prog-Rock/Art Rock"
//    },
//    {
//      "wrapperType": "collection",
//      "collectionType": "Album",
//      "artistId": 640294344,
//      "collectionId": 640294125,
//      "amgArtistId": 3015593,
//      "artistName": "Polyphia",
//      "collectionName": "Inspire - EP",
//      "collectionCensoredName": "Inspire - EP",
//      "artistViewUrl": "https://music.apple.com/us/artist/polyphia/640294344?uo=4",
//      "collectionViewUrl": "https://music.apple.com/us/album/inspire-ep/640294125?uo=4",
//      "artworkUrl60": "https://is1-ssl.mzstatic.com/image/thumb/Music124/v4/36/cb/ff/36cbfffb-6bfa-e9d6-824c-6325e0d54955/887516989025.jpg/60x60bb.jpg",
//      "artworkUrl100": "https://is1-ssl.mzstatic.com/image/thumb/Music124/v4/36/cb/ff/36cbfffb-6bfa-e9d6-824c-6325e0d54955/887516989025.jpg/100x100bb.jpg",
//      "collectionPrice": 4.95,
//      "collectionExplicitness": "notExplicit",
//      "trackCount": 5,
//      "copyright": "℗ 2013 Polyphia",
//      "country": "USA",
//      "currency": "USD",
//      "releaseDate": "2013-04-21T07:00:00Z",
//      "primaryGenreName": "Rock"
//    },
//    {
//      "wrapperType": "collection",
//      "collectionType": "Album",
//      "artistId": 640294344,
//      "collectionId": 1257322261,
//      "amgArtistId": 3015593,
//      "artistName": "Polyphia",
//      "collectionName": "The Most Hated - EP",
//      "collectionCensoredName": "The Most Hated - EP",
//      "artistViewUrl": "https://music.apple.com/us/artist/polyphia/640294344?uo=4",
//      "collectionViewUrl": "https://music.apple.com/us/album/the-most-hated-ep/1257322261?uo=4",
//      "artworkUrl60": "https://is1-ssl.mzstatic.com/image/thumb/Music124/v4/5a/7a/1d/5a7a1d5d-1692-a711-975b-ca07763acfe5/859721867894_cover.jpg/60x60bb.jpg",
//      "artworkUrl100": "https://is1-ssl.mzstatic.com/image/thumb/Music124/v4/5a/7a/1d/5a7a1d5d-1692-a711-975b-ca07763acfe5/859721867894_cover.jpg/100x100bb.jpg",
//      "collectionPrice": 6.99,
//      "collectionExplicitness": "explicit",
//      "contentAdvisoryRating": "Explicit",
//      "trackCount": 6,
//      "copyright": "℗ 2017 Polyphia",
//      "country": "USA",
//      "currency": "USD",
//      "releaseDate": "2017-07-14T07:00:00Z",
//      "primaryGenreName": "Alternative"
//    },
//    {
//      "wrapperType": "collection",
//      "collectionType": "Album",
//      "artistId": 640294344,
//      "collectionId": 1651208826,
//      "amgArtistId": 3015593,
//      "artistName": "Polyphia",
//      "collectionName": "Remember That You Will Die",
//      "collectionCensoredName": "Remember That You Will Die",
//      "artistViewUrl": "https://music.apple.com/us/artist/polyphia/640294344?uo=4",
//      "collectionViewUrl": "https://music.apple.com/us/album/remember-that-you-will-die/1651208826?uo=4",
//      "artworkUrl60": "https://is3-ssl.mzstatic.com/image/thumb/Music122/v4/e1/42/b3/e142b3e5-257a-c520-5ff1-6446b4e2295e/4050538873566.jpg/60x60bb.jpg",
//      "artworkUrl100": "https://is3-ssl.mzstatic.com/image/thumb/Music122/v4/e1/42/b3/e142b3e5-257a-c520-5ff1-6446b4e2295e/4050538873566.jpg/100x100bb.jpg",
//      "collectionPrice": 9.99,
//      "collectionExplicitness": "explicit",
//      "contentAdvisoryRating": "Explicit",
//      "trackCount": 12,
//      "copyright": "℗ 2022 Polyphia under exclusive license to Rise Records, Inc. / BMG Rights Management (US) LLC",
//      "country": "USA",
//      "currency": "USD",
//      "releaseDate": "2022-10-28T07:00:00Z",
//      "primaryGenreName": "Rock"
//    }
//  ]
//}
