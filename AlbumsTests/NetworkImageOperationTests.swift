//
//  NetworkImageOperationTest.swift
//  Albums
//
//  Created by Gustavo Gava on 04/12/2024.
//

import XCTest

final class NetworkImageOperationTestCase: XCTestCase {
    private typealias NetworkImageOperationTestDouble = NetworkImageOperation<SessionTestDouble, ImageHandlerTestDouble>

    override func tearDown() {
        SessionTestDouble.parameterRequest = nil
        SessionTestDouble.returnData = nil
        SessionTestDouble.returnResponse = nil
        
        ImageHandlerTestDouble.parameterData = nil
        ImageHandlerTestDouble.parameterResponse = nil
        ImageHandlerTestDouble.returnImage = nil
    }
    
    func testSessionError() async {
        SessionTestDouble.returnData = nil
        SessionTestDouble.returnResponse = nil
        ImageHandlerTestDouble.returnImage = nil
        
        do {
            _ = try await NetworkImageOperationTestDouble.image(for: URLRequestTestDouble())
            XCTFail()
        } catch {
            XCTAssertEqual(SessionTestDouble.parameterRequest, URLRequestTestDouble())
            
            XCTAssertNil(ImageHandlerTestDouble.parameterData)
            XCTAssertNil(ImageHandlerTestDouble.parameterResponse)
            
            if let error = try? XCTUnwrap(error as? NetworkImageOperationTestDouble.Error) {
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

    func testImageHandlerError() async {
        SessionTestDouble.returnData = DataTestDouble()
        SessionTestDouble.returnResponse = HTTPURLResponseTestDouble()
        
        ImageHandlerTestDouble.returnImage = nil
        
        do {
            _ = try await NetworkImageOperationTestDouble.image(for: URLRequestTestDouble())
            XCTFail()
        } catch {
            XCTAssertEqual(SessionTestDouble.parameterRequest, URLRequestTestDouble())
            
            XCTAssertEqual(ImageHandlerTestDouble.parameterData, SessionTestDouble.returnData)
            XCTAssertIdentical(ImageHandlerTestDouble.parameterResponse, SessionTestDouble.returnResponse)
            
            if let error = try? XCTUnwrap(error as? NetworkImageOperationTestDouble.Error) {
                XCTAssertEqual(error.code, .imageHandlerError)
                
                if let underlying = try? XCTUnwrap(error.underlying as NSError?) {
                    XCTAssertIdentical(
                        underlying,
                        ImageHandlerTestDouble.returnError
                    )
                }
            }
        }
    }

    func testSuccess() async {
        SessionTestDouble.returnData = DataTestDouble()
        SessionTestDouble.returnResponse = HTTPURLResponseTestDouble()
        
        ImageHandlerTestDouble.returnImage = NSObject()
        
        do {
            let image = try await NetworkImageOperationTestDouble.image(for: URLRequestTestDouble())

            XCTAssertEqual(SessionTestDouble.parameterRequest, URLRequestTestDouble())
            
            XCTAssertEqual(ImageHandlerTestDouble.parameterData, SessionTestDouble.returnData)
            XCTAssertIdentical(ImageHandlerTestDouble.parameterResponse, SessionTestDouble.returnResponse)
            
            XCTAssertIdentical(image, ImageHandlerTestDouble.returnImage)
        } catch {
            XCTFail()
        }
    }
}

extension NetworkImageOperationTestCase {
    private struct SessionTestDouble : NetworkImageOperationSession {
        static var parameterRequest: URLRequest?
        static var returnData: Data?
        static var returnResponse: URLResponse?
        static let returnError = NSErrorTestDouble()
        
        static func data(for request: URLRequest) async throws -> (Data, URLResponse) {
            self.parameterRequest = request
            guard let returnData = self.returnData, let returnResponse = self.returnResponse else {
                throw self.returnError
            }
            return (returnData, returnResponse)
        }
    }
}

extension NetworkImageOperationTestCase {
    private struct ImageHandlerTestDouble : NetworkImageOperationImageHandler {
        static var parameterData: Data?
        static var parameterResponse: URLResponse?
        static var returnImage: NSObject?
        static let returnError = NSErrorTestDouble()
        
        static func image(with data: Data, response: URLResponse) throws -> NSObject {
            self.parameterData = data
            self.parameterResponse = response
            guard let returnImage = self.returnImage else {
                throw self.returnError
            }
            return returnImage
        }
    }
}
