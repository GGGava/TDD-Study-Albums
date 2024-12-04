//
//  AlbumsTests.swift
//  AlbumsTests
//
//  Created by Gustavo Gava on 26/11/2024.
//

import XCTest
@testable import Albums

final class AlbumsTests: XCTestCase {
}

func DataTestDouble() -> Data {
    return Data(UInt8.min...UInt8.max)
}

func HTTPURLResponseTestDouble(
  statusCode: Int = 200,
  headerFields: Dictionary<String, String>? = nil
) -> HTTPURLResponse {
    return HTTPURLResponse(
        url: URLTestDouble(),
        statusCode: statusCode,
        httpVersion: "HTTP/1.1",
        headerFields: headerFields
    )!
}
    
func NSErrorTestDouble() -> NSError {
    return NSError(
        domain: "",
        code: 0
    )
}

func URLRequestTestDouble() -> URLRequest {
    return URLRequest(url: URLTestDouble())
}

func URLResponseTestDouble() -> URLResponse {
    return URLResponse(
        url: URLTestDouble(),
        mimeType: nil,
        expectedContentLength: 0,
        textEncodingName: nil
    )
}

func URLTestDouble() -> URL {
    return URL(string: "http://localhost/")!
}
