//
//  HttpClientTests.swift
//  CleanArchitectureTests
//
//  Created by Alberto on 17/06/2019.
//  Copyright © 2019 Alberto. All rights reserved.
//

import XCTest
@testable import CleanArchitecture

class HttpClientTests: XCTestCase {
    
    private var httpClient: HttpClient!
    private var mockUrlSession: URLSessionMock!
    private var auhtHandler: SomeAuthHandler!
    private var endpoint = "https://endpoint.com/some"
    private var authEndpoint = "https://endpoint.com/auth/token"
    private let encoder = JSONEncoder()
    
    override func setUp() {
        super.setUp()
        mockUrlSession = URLSessionMock()
        auhtHandler = SomeAuthHandler(accessToken: "not-valid-token", refreshToken: "valid-token", urlSession: mockUrlSession, authEndpoint: authEndpoint)
        httpClient = HttpClient(urlSession: mockUrlSession, respondQueue: DispatchQueue.main, requestAdapter: auhtHandler, requestRetrier: auhtHandler)
    }
    
    override func tearDown() {
        mockUrlSession = nil
        httpClient = nil
        super.tearDown()
    }
    
    func test_given_valid_token_when_send_request_then_refreshing_not_sended() throws {
        let expectation = self.expectation(description: #function)
        let request = URLRequest(url: try URL(string: endpoint).unwrap())
        mockUrlSession.mockResponses[request] = URLSessionMock.Response(data: nil, response: nil, error: givenError())
        
        var result: Result<HttpResponse, Error>? = nil
        _ = httpClient.send(request: request) { (res) in
            result = res
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
        XCTAssertNotNil(result)
    }
    
    func test_given_invalid_token_when_send_request_then_refresh_and_repeat() throws {
        var notValidTokenRequest = URLRequest(url: try URL(string: endpoint).unwrap())
        notValidTokenRequest.addValue("Bearer not-valid-token", forHTTPHeaderField: "Authorization")
        mockUrlSession.mockResponses[notValidTokenRequest] = URLSessionMock.Response(data: nil, response: nil, error: givenUnauthorizedError())
        
        var renewTokenRequest = URLRequest(url: try URL(string: authEndpoint).unwrap())
        renewTokenRequest.httpMethod = "POST"
        renewTokenRequest.httpBody = ["access_token": "not-valid-token",
                                      "refresh_token": "valid-token"].data
        let renewTokendata = try encoder.encode(givenRenewTokenResponse())
        mockUrlSession.mockResponses[renewTokenRequest] = URLSessionMock.Response(data: renewTokendata, response: try given200Response(), error: nil)
        
        var validTokenRequest = URLRequest(url: try URL(string: endpoint).unwrap())
        validTokenRequest.addValue("Bearer new-access-token", forHTTPHeaderField: "Authorization")
        let someData = try encoder.encode(givenSomeEndpointData())
        mockUrlSession.mockResponses[validTokenRequest] = URLSessionMock.Response(data: someData, response: try given200Response(), error: nil)
        
        let expectation = self.expectation(description: #function)
        let someRequest = URLRequest(url: try URL(string: endpoint).unwrap())
        
        var result: Result<HttpResponse, Error>? = nil
        _ = httpClient.send(request: someRequest) { (res) in
            result = res
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        XCTAssertNotNil(result)
        var resultData: Data?
        switch try result.unwrap() {
        case .success(let httpResponse):
            resultData = httpResponse.data
        case .failure:
            break
        }
        XCTAssertNotNil(resultData)
        XCTAssertEqual(resultData, try encoder.encode(givenSomeEndpointData()))
        XCTAssertEqual(auhtHandler.accessToken, "new-access-token")
        XCTAssertEqual(auhtHandler.refreshToken, "new-refresh-token")
    }
    
    func test_given_invalid_token_when_send_request_but_error_refreshing_then_not_refreshed_and_fail() throws {
        var notValidTokenRequest = URLRequest(url: try URL(string: endpoint).unwrap())
        notValidTokenRequest.addValue("Bearer not-valid-token", forHTTPHeaderField: "Authorization")
        mockUrlSession.mockResponses[notValidTokenRequest] = URLSessionMock.Response(data: nil, response: nil, error: givenUnauthorizedError())
        
        var renewTokenRequest = URLRequest(url: try URL(string: authEndpoint).unwrap())
        renewTokenRequest.httpMethod = "POST"
        renewTokenRequest.httpBody = ["access_token": "not-valid-token",
                                      "refresh_token": "valid-token"].data
        mockUrlSession.mockResponses[renewTokenRequest] = URLSessionMock.Response(data: nil, response: nil, error: givenError())
        
        let expectation = self.expectation(description: #function)
        let someRequest = URLRequest(url: try URL(string: endpoint).unwrap())
        
        var result: Result<HttpResponse, Error>? = nil
        _ = httpClient.send(request: someRequest) { (res) in
            result = res
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
        XCTAssertNotNil(result)
        var resultError: HttpClientAuthorizationError?
        switch try result.unwrap() {
        case .success: break
        case .failure(let error):
            resultError = error as? HttpClientAuthorizationError
        }
        XCTAssertNotNil(resultError)
        XCTAssertEqual(resultError, HttpClientAuthorizationError.refreshing)
        XCTAssertEqual(auhtHandler.accessToken, "not-valid-token")
        XCTAssertEqual(auhtHandler.refreshToken, "valid-token")
    }
    
    func test_given_invalid_token_when_send_multiple_request_then_match_only_refreshed_once() throws {
        throw TestError.notImplemented
    }
    
    func test_given_request_when_canceled_then_not_respond() throws {
        let expectation = self.expectation(description: #function)
        let request = URLRequest(url: try URL(string: endpoint).unwrap())
        mockUrlSession.mockResponses[request] = URLSessionMock.Response(data: nil, response: nil, error: givenError())
        
        var resultError: Error?
        let cancelable = httpClient.send(request: request) { (res) in
            switch res {
            case .success: break
            case .failure(let error):
                resultError = error
            }
            expectation.fulfill()
        }
        cancelable.cancel()
        
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(try resultError.unwrap().code, NSURLErrorCancelled)
    }
    
    // MARK: private
    
    private func givenError() -> Error {
        return NSError(domain: "", code: NSURLErrorUnknown, userInfo: nil)
    }
    
    private func givenUnauthorizedError() -> Error {
        return NSError(domain: "", code: 401, userInfo: nil)
    }
    
    private func givenRenewTokenResponse() -> API.Tokens {
        return API.Tokens(accesToken: "new-access-token", refreshToken: "new-refresh-token")
    }
    
    private func given200Response() throws -> HTTPURLResponse {
        return try HTTPURLResponse(url: try URL(string: "https://whatever").unwrap(), statusCode: 200, httpVersion: "", headerFields: nil).unwrap()
    }
    
    private func givenSomeEndpointData() throws -> API.Some {
        return API.Some(data: "data")
    }
}

class URLSessionMock: URLSession {
    
    struct Response {
        let data: Data?
        let response: URLResponse?
        let error: Error?
    }
    var mockResponses: [URLRequest: Response]! = [URLRequest: Response]()
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let response = mockResponses[request]
        return URLSessionDataTaskMock { canceled in
            if canceled {
                completionHandler(nil, nil, NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled, userInfo: nil))
            } else {
                completionHandler(response?.data, response?.response, response?.error)
            }
        }
    }
    
}

class URLSessionDataTaskMock: URLSessionDataTask {
    
    private let closure: (_ canceled: Bool) -> Void
    private(set) var canceled: Bool = false
    
    init(closure: @escaping (_ canceled: Bool) -> Void) {
        self.closure = closure
    }
    
    override func resume() {
        DispatchQueue.main.async {
            self.closure(self.canceled)
        }
    }
    
    override func cancel() {
        canceled = true
    }
    
}

enum TestError: Error {
    case notImplemented
}

enum API {}

extension API {
    
    struct Tokens: Codable {
        let accesToken: String
        let refreshToken: String
    }
    
    struct Some: Codable {
        let data: String
    }
}

class SomeAuthHandler: RequestAdapter, RequestRetrier {
    
    private let urlSession: URLSession
    private let authEndpoint: String
    private let lock: NSLock = NSLock()
    private var isRefreshing = false
    private(set) var accessToken: String
    private(set) var refreshToken: String
    private(set) var requestsToRetry = [RequestRetryCompletion]()
    
    init(accessToken: String, refreshToken: String, urlSession: URLSession, authEndpoint: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.urlSession = urlSession
        self.authEndpoint = authEndpoint
    }
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var request = urlRequest
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func should(retry response: HTTPURLResponse?, with error: Error?, completion: @escaping RequestRetryCompletion) {
        lock.lock()
        defer {
            lock.unlock()
        }
        if response?.statusCode == 401 || error?.code == 401 {
            requestsToRetry.append(completion)
            if !isRefreshing {
                refreshTokens { [weak self]  newAccessToken, newRefreshToken in
                    guard let self = self else { return }
                    self.lock.lock()
                    defer {
                        self.lock.unlock()
                    }
                    self.isRefreshing = false
                    if let accessToken = newAccessToken, let refreshToken = newRefreshToken {
                        self.accessToken = accessToken
                        self.refreshToken = refreshToken
                        self.requestsToRetry.forEach { $0(.retry) }
                    } else {
                        self.requestsToRetry.forEach { $0(.failed(error: HttpClientAuthorizationError.refreshing)) }
                    }
                    self.requestsToRetry.removeAll()
                }
            }
        } else {
            completion(.continue)
        }
    }
    
    private func refreshTokens(completion: @escaping (_ newAccessToken: String?, _ newRefreshToken: String?) -> Void) {
        guard !isRefreshing else { return }
        isRefreshing = true
        
        var authRequest = URLRequest(url: URL(string: authEndpoint)!)
        authRequest.httpMethod = "POST"
        authRequest.httpBody = ["access_token": accessToken,
                                "refresh_token": refreshToken].data
        urlSession.dataTask(with: authRequest) { (dta, res, err) in
            if let urlResponse = res as? HTTPURLResponse, urlResponse.statusCode >= 200 && urlResponse.statusCode < 300, let data = dta {
                if let tokens = try? JSONDecoder().decode(API.Tokens.self, from: data) {
                    completion(tokens.accesToken, tokens.refreshToken)
                    return
                }
            }
            completion(nil, nil)
            }.resume()
    }
    
}

extension Dictionary {
    var data: Data? {
        return try? JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted])
    }
}
