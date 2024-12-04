//
//  NetworkImageOperation.swift
//  Albums
//
//  Created by Gustavo Gava on 04/12/2024.
//

import Foundation

protocol NetworkImageOperationSession {
    static func data(for: URLRequest) async throws -> (Data, URLResponse)
}

extension NetworkSession : NetworkImageOperationSession where URLSession == Foundation.URLSession {
  
}

protocol NetworkImageOperationImageHandler {
    associatedtype Image
  
    static func image(with: Data, response: URLResponse) throws -> Image
}

extension NetworkImageHandler : NetworkImageOperationImageHandler where
    DataHandler == NetworkDataHandler, ImageSerialization == NetworkImageSerialization<NetworkImageSource> {
}

struct NetworkImageOperation<Session: NetworkImageOperationSession, ImageHandler: NetworkImageOperationImageHandler> {
    static func image(for request: URLRequest) async throws -> ImageHandler.Image {
        let (data, response) = try await sessionData(for: request)
        return try handlerImage(with: data, response: response)
    }

    private static func sessionData(for request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await Session.data(for: request)
        } catch {
            throw Self.Error(.sessionError, underlying: error)
        }
    }

    private static func handlerImage(with data: Data, response: URLResponse) throws -> ImageHandler.Image {
        do {
            return try ImageHandler.image(with: data, response: response)
        } catch {
            throw Self.Error(.imageHandlerError, underlying: error)
        }
    }
}

extension NetworkImageOperation {
    struct Error : Swift.Error {
        enum Code {
            case sessionError
            case imageHandlerError
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
}
