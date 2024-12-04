import XCTest

final class NetworkImageHandlerTestCase : XCTestCase {
    private typealias NetworkImageHandlerTestDouble = NetworkImageHandler<DataHandlerTestDouble, ImageSerializationTestDouble>
    
    override func tearDown() {
        DataHandlerTestDouble.parameterData = nil
        DataHandlerTestDouble.parameterResponse = nil
        DataHandlerTestDouble.returnData = nil
        
        ImageSerializationTestDouble.parameterData = nil
        ImageSerializationTestDouble.returnImage = nil
    }
    
    func testMimeTypeError() {
        DataHandlerTestDouble.returnData = nil
        ImageSerializationTestDouble.returnImage = nil
        
        let response = HTTPURLResponseTestDouble(headerFields: ["CONTENT-TYPE": "TEXT/JAVASCRIPT"])
        
        XCTAssertThrowsError(
            try NetworkImageHandlerTestDouble.image(with: DataTestDouble(), response: response)
        ) { error in
            XCTAssertNil(DataHandlerTestDouble.parameterData)
            XCTAssertNil(DataHandlerTestDouble.parameterResponse)
            
            XCTAssertNil(ImageSerializationTestDouble.parameterData)
            
            if let error = try? XCTUnwrap(error as? NetworkImageHandlerTestDouble.Error) {
                XCTAssertEqual(
                  error.code,
                  .mimeTypeError
                )
                XCTAssertNil(error.underlying)
            }
        }
    }
    
    func testDataHandlerError() {
        DataHandlerTestDouble.returnData = nil

        let response = HTTPURLResponseTestDouble(headerFields: ["CONTENT-TYPE": "IMAGE/PNG"])
        
        XCTAssertThrowsError(
            try NetworkImageHandlerTestDouble.image(with: DataTestDouble(), response: response)
        ) { error in
            XCTAssertEqual(
              DataHandlerTestDouble.parameterData,
              DataTestDouble()
            )
            XCTAssertIdentical(
              DataHandlerTestDouble.parameterResponse,
              response
            )
            
            XCTAssertNil(ImageSerializationTestDouble.parameterData)

            if let error = try? XCTUnwrap(error as? NetworkImageHandlerTestDouble.Error) {
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
    
    func testImageSerializationError() {
        DataHandlerTestDouble.returnData = DataTestDouble()
        ImageSerializationTestDouble.returnImage = nil
        
        let response = HTTPURLResponseTestDouble(headerFields: ["CONTENT-TYPE": "IMAGE/PNG"])
        
        XCTAssertThrowsError(
            try NetworkImageHandlerTestDouble.image(with: DataTestDouble(), response: response)
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
                ImageSerializationTestDouble.parameterData,
                DataHandlerTestDouble.returnData
            )
            
            if let error = try? XCTUnwrap(error as? NetworkImageHandlerTestDouble.Error) {
                XCTAssertEqual(error.code, .imageSerializationError)
                if let underlying = try? XCTUnwrap(error.underlying as NSError?) {
                    XCTAssertIdentical(
                        underlying,
                        ImageSerializationTestDouble.returnError
                    )
                }
            }
        }
    }
    
    func testSuccess() {
        DataHandlerTestDouble.returnData = DataTestDouble()
        ImageSerializationTestDouble.returnImage = NSObject()
        let response = HTTPURLResponseTestDouble(headerFields: ["CONTENT-TYPE": "IMAGE/PNG"])
        
        XCTAssertNoThrow(
            try {
                let image = try NetworkImageHandlerTestDouble.image(with: DataTestDouble(), response: response)
                XCTAssertEqual(
                  DataHandlerTestDouble.parameterData,
                  DataTestDouble()
                )
                XCTAssertIdentical(
                  DataHandlerTestDouble.parameterResponse,
                  response
                )
                XCTAssertEqual(
                    ImageSerializationTestDouble.parameterData,
                    DataHandlerTestDouble.returnData
                )
                XCTAssertIdentical(
                    ImageSerializationTestDouble.returnImage,
                    image
                )
            }()
        )
    }
}

extension NetworkImageHandlerTestCase {
  private struct DataHandlerTestDouble : NetworkImageHandlerDataHandler {
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
      guard
        let returnData = self.returnData
      else {
        throw self.returnError
      }
      return returnData
    }
  }
}

extension NetworkImageHandlerTestCase {
  private struct ImageSerializationTestDouble : NetworkImageHandlerImageSerialization {
    static var parameterData: Data?
    static var returnImage: NSObject?
    static let returnError = NSErrorTestDouble()
    
    static func image(with data: Data) throws -> NSObject {
      self.parameterData = data
      guard
        let returnImage = self.returnImage
      else {
        throw self.returnError
      }
      return returnImage
    }
  }
}
