import XCTest

final class NetworkDataHandlerTestCase : XCTestCase {
    private static var errorCodes: Array<Int> {
        return Array(100...199) + Array(300...599)
    }
    
    private static var successCodes: Array<Int> {
        return Array(200...299)
    }
}

extension NetworkDataHandlerTestCase {
    func testError() {
        XCTAssertThrowsError(
            try NetworkDataHandler.data(
                with: DataTestDouble(),
                response: URLResponseTestDouble()
            )
        )
    }

    func testErrorWithStatusCode() {
        for statusCode in Self.errorCodes {
            XCTAssertThrowsError(
                try NetworkDataHandler.data(
                    with: DataTestDouble(),
                    response: HTTPURLResponseTestDouble(statusCode: statusCode)
                ),
                "Status Code \(statusCode)"
            ) { error in
                if let error = try? XCTUnwrap(error as? NetworkDataHandler.Error) {
                    XCTAssertEqual(
                        error.code,
                        .statusCodeError,
                        "Status Code \(statusCode)"
                    )
                    XCTAssertNil(
                        error.underlying,
                        "Status Code \(statusCode)"
                    )
                }
            }
        }
    }
    
    func testSuccess() {
        for statusCode in Self.successCodes {
            XCTAssertNoThrow(
                try {
                    let data = try NetworkDataHandler.data(
                        with: DataTestDouble(),
                        response: HTTPURLResponseTestDouble(statusCode: statusCode)
                    )
                    XCTAssertEqual(
                        data,
                        DataTestDouble(),
                        "Status Code \(statusCode)"
                    )
                }(),
                "Status Code \(statusCode)"
            )
        }
    }
}
