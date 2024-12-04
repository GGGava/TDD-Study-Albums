//
//  NetworkJSONOperation.swift
//  Albums
//
//  Created by Gustavo Gava on 04/12/2024.
//

import Foundation

protocol NetworkJSONOperationSession {
    static func data(for: URLRequest) async throws -> (Data, URLResponse)
}

extension NetworkSession: NetworkJSONOperationSession where URLSession == Foundation.URLSession {
    
}

protocol NetworkJSONOperationJSONHandler {
    associatedtype JSON
  
    static func json(with: Data, response: URLResponse) throws -> JSON
}

extension NetworkJSONHandler: NetworkJSONOperationJSONHandler where
    DataHandler == NetworkDataHandler, JSONSerialization == Foundation.JSONSerialization {
}

struct NetworkJSONOperation<Session: NetworkJSONOperationSession, JSONHandler: NetworkJSONOperationJSONHandler> {
    static func json(for request: URLRequest) async throws -> JSONHandler.JSON {
        let (data, response) = try await sessionData(for: request)
        return try json(with: data, response: response)
    }
    
    private static func sessionData(for request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await Session.data(for: request)
        } catch {
            throw Self.Error.init(.sessionError, underlying: error)
        }
    }

    private static func json(with data: Data, response: URLResponse) throws -> JSONHandler.JSON {
        do {
            return try JSONHandler.json(with: data, response: response)
        } catch {
            throw Self.Error.init(.jsonHandlerError, underlying: error)
        }
    }
}

extension NetworkJSONOperation {
    struct Error : Swift.Error {
        enum Code {
            case sessionError
            case jsonHandlerError
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
