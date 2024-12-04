//
//  NetworkJSONOperationTests.swift
//  Albums
//
//  Created by Gustavo Gava on 04/12/2024.
//

import XCTest

final class NetworkJSONOperationTestCase : XCTestCase {
    private typealias NetworkJSONOperationTestDouble = NetworkJSONOperation<SessionTestDouble, JSONHandlerTestDouble>
    
    override func tearDown() {
        SessionTestDouble.parameterRequest = nil
        SessionTestDouble.returnData = nil
        SessionTestDouble.returnResponse = nil
        
        JSONHandlerTestDouble.parameterData = nil
        JSONHandlerTestDouble.parameterResponse = nil
        JSONHandlerTestDouble.returnJSON = nil
    }
    
    func testSessionError() async {
        SessionTestDouble.returnData = nil
        SessionTestDouble.returnResponse = nil
        JSONHandlerTestDouble.returnJSON = nil
        
        do {
            _ = try await NetworkJSONOperationTestDouble.json(for: URLRequestTestDouble())
            XCTFail()
        } catch {
            XCTAssertEqual(SessionTestDouble.parameterRequest, URLRequestTestDouble())
            
            XCTAssertNil(JSONHandlerTestDouble.parameterData)
            XCTAssertNil(JSONHandlerTestDouble.parameterResponse)
            
            if let error = try? XCTUnwrap(error as? NetworkJSONOperationTestDouble.Error) {
                XCTAssertEqual(error.code, .sessionError)
                
                if let underlying = try? XCTUnwrap(error.underlying as NSError?) {
                    XCTAssertIdentical(
                        underlying,
                        SessionTestDouble.returnError
                    )
                }
            }
        }
    }
    
    func testJSONHandlerError() async {
        SessionTestDouble.returnData = DataTestDouble()
        SessionTestDouble.returnResponse = HTTPURLResponseTestDouble()
        
        JSONHandlerTestDouble.returnJSON = nil
        
        do {
            _ = try await NetworkJSONOperationTestDouble.json(for: URLRequestTestDouble())
            XCTFail()
        } catch {
            XCTAssertEqual(SessionTestDouble.parameterRequest, URLRequestTestDouble())
            
            XCTAssertEqual(JSONHandlerTestDouble.parameterData, SessionTestDouble.returnData)
            XCTAssertIdentical(JSONHandlerTestDouble.parameterResponse, SessionTestDouble.returnResponse)
            
            if let error = try? XCTUnwrap(error as? NetworkJSONOperationTestDouble.Error) {
                XCTAssertEqual(error.code, .jsonHandlerError)
                
                if let underlying = try? XCTUnwrap(error.underlying as NSError?) {
                    XCTAssertIdentical(
                        underlying,
                        JSONHandlerTestDouble.returnError
                    )
                }
            }
        }
    }

    func testSuccess() async {
        SessionTestDouble.returnData = DataTestDouble()
        SessionTestDouble.returnResponse = HTTPURLResponseTestDouble()

        JSONHandlerTestDouble.returnJSON = NSObject()
        
        do {
            let json = try await NetworkJSONOperationTestDouble.json(for: URLRequestTestDouble())
            
            XCTAssertEqual(SessionTestDouble.parameterRequest, URLRequestTestDouble())
            
            XCTAssertEqual(JSONHandlerTestDouble.parameterData, SessionTestDouble.returnData)
            XCTAssertIdentical(JSONHandlerTestDouble.parameterResponse, SessionTestDouble.returnResponse)
            
            XCTAssertIdentical(json, JSONHandlerTestDouble.returnJSON)
        } catch {
            XCTFail()
        }
    }
}

extension NetworkJSONOperationTestCase {
    private struct SessionTestDouble : NetworkJSONOperationSession {
        static var parameterRequest: URLRequest?
        static var returnData: Data?
        static var returnResponse: URLResponse?
        static let returnError = NSErrorTestDouble()
    
        static func data(for request: URLRequest) async throws -> (Data, URLResponse) {
            self.parameterRequest = request
            guard
                let returnData = self.returnData,
                let returnResponse = self.returnResponse
            else {
                throw self.returnError
            }
            return (returnData,returnResponse)
        }
    }
}

extension NetworkJSONOperationTestCase {
    private struct JSONHandlerTestDouble : NetworkJSONOperationJSONHandler {
        static var parameterData: Data?
        static var parameterResponse: URLResponse?
        static var returnJSON: NSObject?
        static let returnError = NSErrorTestDouble()
    
        static func json(
          with data: Data,
          response: URLResponse
        ) throws -> NSObject {
            self.parameterData = data
            self.parameterResponse = response
            guard let returnJSON = self.returnJSON else {
                throw self.returnError
            }
            return returnJSON
        }
    }
}
