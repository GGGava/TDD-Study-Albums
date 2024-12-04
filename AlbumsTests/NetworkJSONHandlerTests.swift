//
//  NetworkJSONHandlerTests.swift
//  Albums
//
//  Created by Gustavo Gava on 27/11/2024.
//

import XCTest

final class NetworkJSONHandlerTestCase: XCTestCase {
    private typealias NetworkJSONHandlerTestDouble = NetworkJSONHandler<DataHandlerTestDouble, JSONSerializationTestDouble>
    
    override func tearDown() {
        DataHandlerTestDouble.parameterData = nil
        DataHandlerTestDouble.parameterResponse = nil
        DataHandlerTestDouble.returnData = nil
        
        JSONSerializationTestDouble.parameterData = nil
        JSONSerializationTestDouble.parameterOptions = nil
        JSONSerializationTestDouble.returnJSON = nil
    }
    
    func testMimeTypeError() {
        DataHandlerTestDouble.returnData = nil
        JSONSerializationTestDouble.returnJSON = nil

        let response = HTTPURLResponseTestDouble(headerFields: ["CONTENT-TYPE": "IMAGE/PNG"])
        
        XCTAssertThrowsError(
            try NetworkJSONHandlerTestDouble.json(
                with: DataTestDouble(),
                response: response
            )
        ) { error in
            
            XCTAssertNil(DataHandlerTestDouble.parameterData)
            XCTAssertNil(DataHandlerTestDouble.parameterResponse)
            
            XCTAssertNil(JSONSerializationTestDouble.parameterData)
            XCTAssertNil(JSONSerializationTestDouble.parameterOptions)

            if let error = try? XCTUnwrap(error as? NetworkJSONHandlerTestDouble.Error) {
                XCTAssertEqual(error.code, .mimeTypeError)
                XCTAssertNil(error.underlying)
            }
        }
    }
    
    func testDataHandlerError() {
        DataHandlerTestDouble.returnData = nil

        let response = HTTPURLResponseTestDouble(headerFields: ["CONTENT-TYPE": "TEXT/JAVASCRIPT"])
        
        XCTAssertThrowsError(
            try NetworkJSONHandlerTestDouble.json(with: DataTestDouble(), response: response)
        ) { error in
            XCTAssertEqual(
              DataHandlerTestDouble.parameterData,
              DataTestDouble()
            )
            XCTAssertIdentical(
              DataHandlerTestDouble.parameterResponse,
              response
            )
            
            XCTAssertNil(JSONSerializationTestDouble.parameterData)
            XCTAssertNil(JSONSerializationTestDouble.parameterOptions)

            if let error = try? XCTUnwrap(error as? NetworkJSONHandlerTestDouble.Error) {
                XCTAssertEqual(error.code, .dataHandlerError)
                if let underlying = try? XCTUnwrap(error.underlying as NSError?) {
                    XCTAssertIdentical(
                        underlying,
                        DataHandlerTestDouble.returnError
                    )
                }
            }
        }
    }

    func testJSONSerializationError() {
        DataHandlerTestDouble.returnData = DataTestDouble()
        JSONSerializationTestDouble.returnJSON = nil
        
        let response = HTTPURLResponseTestDouble(headerFields: ["CONTENT-TYPE": "TEXT/JAVASCRIPT"])
        
        XCTAssertThrowsError(
            try NetworkJSONHandlerTestDouble.json(with: DataTestDouble(), response: response)
        ) { error in
            XCTAssertEqual(
                DataHandlerTestDouble.parameterData,
                DataTestDouble()
            )
            XCTAssertIdentical(
                DataHandlerTestDouble.parameterResponse,
                response
            )
            
            XCTAssertEqual(
                JSONSerializationTestDouble.parameterData,
                DataHandlerTestDouble.returnData
            )
            XCTAssertEqual(
                JSONSerializationTestDouble.parameterOptions,
                []
            )
            
            if let error = try? XCTUnwrap(error as? NetworkJSONHandlerTestDouble.Error) {
                XCTAssertEqual(error.code, .jsonSerializationError)
                if let underlying = try? XCTUnwrap(error.underlying as NSError?) {
                    XCTAssertIdentical(
                        underlying,
                        JSONSerializationTestDouble.returnError
                    )
                }
            }
        }
    }

    func testSuccess() {
        DataHandlerTestDouble.returnData = DataTestDouble()
        JSONSerializationTestDouble.returnJSON = NSObject()
        
        let response = HTTPURLResponseTestDouble(headerFields: ["CONTENT-TYPE": "TEXT/JAVASCRIPT"])
        
        XCTAssertNoThrow(
            try {
                let json = try NetworkJSONHandlerTestDouble.json(with: DataTestDouble(), response: response)
                
                XCTAssertEqual(
                    DataHandlerTestDouble.parameterData,
                    DataTestDouble()
                )

                XCTAssertIdentical(
                    DataHandlerTestDouble.parameterResponse,
                    response
                )
                
                XCTAssertEqual(
                    JSONSerializationTestDouble.parameterData,
                    DataHandlerTestDouble.returnData
                )
                XCTAssertEqual(
                    JSONSerializationTestDouble.parameterOptions,
                    []
                )
                
                XCTAssertIdentical(
                    json,
                    JSONSerializationTestDouble.returnJSON
                )
            }()
        )
    }
}

extension NetworkJSONHandlerTestCase {
    private struct DataHandlerTestDouble: NetworkJSONHandlerDataHandler {
        static var parameterData: Data?
        static var parameterResponse: URLResponse?
        static var returnData: Data?
        static let returnError = NSErrorTestDouble()
        
        static func data(
            with data: Data,
            response: URLResponse
        ) throws -> Data {
            self.parameterData = data
            self.parameterResponse = response
            guard let returnData = self.returnData else {
                throw self.returnError
            }
            return returnData
        }
    }

    private struct JSONSerializationTestDouble : NetworkJSONHandlerJSONSerialization {
        static var parameterData: Data?
        static var parameterOptions: JSONSerialization.ReadingOptions?
        static var returnJSON: NSObject?
        static let returnError = NSErrorTestDouble()
        
        static func jsonObject(
            with data: Data,
            options: JSONSerialization.ReadingOptions
        ) throws -> NSObject {
            self.parameterData = data
            self.parameterOptions = options
            guard let returnJSON = self.returnJSON else {
                throw self.returnError
            }
            return returnJSON
        }
    }
}
