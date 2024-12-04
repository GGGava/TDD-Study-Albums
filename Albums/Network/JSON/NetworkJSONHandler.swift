//
//  NetworkJSONHandler.swift
//  Albums
//
//  Created by Gustavo Gava on 27/11/2024.
//

import Foundation

protocol NetworkJSONHandlerDataHandler {
    static func data(
        with data: Data,
        response: URLResponse
    ) throws -> Data
}

protocol NetworkJSONHandlerJSONSerialization {
    associatedtype JSON
    
    static func jsonObject(with: Data, options: JSONSerialization.ReadingOptions) throws -> JSON
}

extension JSONSerialization: NetworkJSONHandlerJSONSerialization {}

struct NetworkJSONHandler<DataHandler: NetworkJSONHandlerDataHandler, JSONSerializer: NetworkJSONHandlerJSONSerialization> {
    struct Error : Swift.Error {
        enum Code {
            case mimeTypeError
            case dataHandlerError
            case jsonSerializationError
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

    static func json(
        with data: Data,
        response: URLResponse
    ) throws -> JSONSerializer.JSON {
        guard let dataType = response.mimeType?.lowercased(), dataType == "text/javascript" else {
            throw Error(.mimeTypeError)
        }
        
        let data = try { () -> Data in
            do {
                return try DataHandler.data(with: data, response: response)
            } catch {
                throw Error(.dataHandlerError, underlying: error)
            }
        }()
        
        do {
            return try JSONSerializer.jsonObject(with: data, options: [])
        } catch {
            throw Error(.jsonSerializationError, underlying: error)
        }
    }
}
