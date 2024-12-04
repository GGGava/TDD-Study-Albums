//
//  NetworkImageSerialization.swift
//  Albums
//
//  Created by Gustavo Gava on 29/11/2024.
//

import Foundation

protocol NetworkImageSerializationImageSource {
  associatedtype ImageSource
  associatedtype Image
  
    static func createImageSource(
        with: CFData,
        options: CFDictionary?
    ) -> ImageSource?
  
    static func createImage(
        with: ImageSource,
        at: Int,
        options: CFDictionary?
    ) -> Image?
}

extension NetworkImageSource: NetworkImageSerializationImageSource {}

struct NetworkImageSerialization<ImageSource: NetworkImageSerializationImageSource> {
    struct Error : Swift.Error {
        enum Code {
          case imageSourceError
          case imageError
        }
      
        let code: Self.Code
        let underlying: Swift.Error?
      
        init(
            _ code: Self.Code,
            underlying: Swift.Error? = nil
        ) {
            self.code = code
            self.underlying = underlying
        }
    }

    static func image(with data: Data) throws -> ImageSource.Image {
        guard let imageSource = ImageSource.createImageSource(with: data as CFData, options: nil) else {
            throw Error(.imageSourceError, underlying: nil)
        }
        guard let image = ImageSource.createImage(with: imageSource, at: 0, options: nil) else {
            throw Error(.imageError, underlying: nil)
        }
        
        return image
    }
}
