//
//  AlbumsListModel.swift
//  Albums
//
//  Created by Gustavo Gava on 04/12/2024.
//

import Foundation

protocol AlbumsListModelJSONOperation {
    associatedtype JSON
    
    static func json(for: URLRequest) async throws -> JSON
}

extension NetworkJSONOperation: AlbumsListModelJSONOperation where
    Session == NetworkSession<Foundation.URLSession>,
    JSONHandler == NetworkJSONHandler<NetworkDataHandler, Foundation.JSONSerialization> {
    
}

struct Album: Codable, Equatable, Identifiable {
    let id: String
    let artist: String
    let name: String
    let image: String
    
    enum CodingKeys: String, CodingKey {
        case id = "im:id"
        case artist = "im:artist"
        case name = "im:name"
        case image = "im:image"
    }
}

@MainActor
final class AlbumsListModel<JSONOperation: AlbumsListModelJSONOperation>: ObservableObject {
    @Published private(set) var albums = Array<Album>()
    
    func requestAlbums() async throws {
        if let url = URL(string: "https://itunes.apple.com/us/rss/topalbums/limit=100/json") {
            let request = URLRequest(url: url)
            let albumsJson = try await JSONOperation.json(for: request)
            self.albums = Albums(albumsJson)
        }
    }
}


extension AlbumsListModel {
    private func Albums(_ json: Any) -> Array<Album> {
      var albums = Array<Album>()
      if let array = ((json as? Dictionary<String, Any>)?["feed"] as? Dictionary<String, Any>)?["entry"] as? Array<Dictionary<String, Any>> {
        for dictionary in array {
          if let artist = ((dictionary["im:artist"] as? Dictionary<String, Any>)?["label"] as? String),
             let name = ((dictionary["im:name"] as? Dictionary<String, Any>)?["label"] as? String),
             let image = ((dictionary["im:image"] as? Array<Dictionary<String, Any>>)?[2]["label"] as? String),
             let id = (((dictionary["id"] as? Dictionary<String, Any>)?["attributes"] as? Dictionary<String, Any>)?["im:id"] as? String) {
            let album = Album(
              id: id,
              artist: artist,
              name: name,
              image: image
            )
            albums.append(album)
          }
        }
      }
      return albums
    }

}
