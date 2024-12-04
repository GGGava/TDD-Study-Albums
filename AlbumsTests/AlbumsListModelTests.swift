//
//  AlbumsListModelTests.swift
//  Albums
//
//  Created by Gustavo Gava on 04/12/2024.
//

import XCTest

final class AlbumsListModelTestCase: XCTestCase {
    private typealias AlbumsListModelTestDouble = AlbumsListModel<JSONOperationTestDouble>
    
    private static var request: URLRequest {
        return URLRequest(url: URL(string: "https://itunes.apple.com/us/rss/topalbums/limit=100/json")!)
    }
    
    private static var albums: Array<Album> {
        return Albums(Self.json)
    }
    
    override func tearDown() {
        JSONOperationTestDouble.parameterRequest = nil
        JSONOperationTestDouble.returnJSON = nil
    }

    @MainActor
    func testError() async {
        JSONOperationTestDouble.returnJSON = nil
        
        let model = AlbumsListModelTestDouble()
        do {
            try await model.requestAlbums()
            XCTFail()
        } catch {
            XCTAssertEqual(JSONOperationTestDouble.parameterRequest, Self.request)
            
            XCTAssertEqual(model.albums, [])
            
            if let error = try? XCTUnwrap(error as NSError?) {
                XCTAssertIdentical(error, JSONOperationTestDouble.returnError)
            }
        }
    }

    @MainActor
    func testSuccess() async {
        JSONOperationTestDouble.returnJSON = Self.json
        
        let model = AlbumsListModelTestDouble()
        
        var modelDidChange = false
        let modelWillChange = model.objectWillChange.sink() { _ in
            modelDidChange = true
        }

        var albumsDidChange = false
        let albumsWillChange = model.$albums.sink() { _ in
            albumsDidChange = true
        }
        
        do {
            try await model.requestAlbums()
            XCTAssertTrue(modelDidChange)
            XCTAssertTrue(albumsDidChange)
            
            XCTAssertEqual(JSONOperationTestDouble.parameterRequest, Self.request)
            XCTAssertEqual(model.albums, Self.albums)
        } catch {
            XCTFail()
        }
        
        modelWillChange.cancel()
        albumsWillChange.cancel()
    }
}

extension AlbumsListModelTestCase {
    private struct JSONOperationTestDouble : AlbumsListModelJSONOperation {
        static var parameterRequest: URLRequest?
        static var returnJSON: Any?
        static let returnError = NSErrorTestDouble()
    
        static func json(for request: URLRequest) async throws -> Any {
            self.parameterRequest = request
            guard let returnJSON = self.returnJSON else {
                throw self.returnError
            }
            return returnJSON
        }
    }
}

extension AlbumsListModelTestCase {
    private static var json: Any {
        let bundle = Bundle(for: AlbumsListModelTestCase.self)
        let url = bundle.url(forResource: "Albums", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let json = try! JSONSerialization.jsonObject(
          with: data,
          options: []
        )
        return json
    }
    
    private static func Albums(_ json: Any) -> Array<Album> {
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
