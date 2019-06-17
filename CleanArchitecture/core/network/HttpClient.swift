//
//  HttpClient.swift
//  CleanArchitecture
//
//  Created by Alberto on 17/06/2019.
//  Copyright © 2019 Alberto. All rights reserved.
//

import Foundation

//TODO: URLRequestConvertible
//TODO: namespaces
class HttpClient {
    
    private let urlSession: URLSession
    private let respondQueue: DispatchQueue
    private let requestAdapter: RequestAdapter?
    private let requestRetrier: RequestRetrier?
    
    init(urlSession: URLSession,
         respondQueue: DispatchQueue = DispatchQueue.main,
         requestAdapter: RequestAdapter? = nil,
         requestRetrier: RequestRetrier? = nil) {
        self.urlSession = urlSession
        self.respondQueue = respondQueue
        self.requestAdapter = requestAdapter
        self.requestRetrier = requestRetrier
    }
    
    func send(request: URLRequest, completion: @escaping (Result<HttpResponse, Error>) -> Void) -> Cancelable {
        let cancelable = URLSessionTaskCancelable()
        let task = send(request: request, cancelable: cancelable, completion: completion)
        cancelable.tasks.append(task)
        return cancelable
    }
    
    // MARK: private
    
    private func send(request: URLRequest,
                      cancelable: URLSessionTaskCancelable,
                      retries: Int = 1,
                      completion: @escaping (Result<HttpResponse, Error>) -> Void) -> URLSessionTask {
        var newRequest: URLRequest = request
        if let adaptedRequest = try? requestAdapter?.adapt(request) {
            newRequest = adaptedRequest
        }
        let task = urlSession.dataTask(with: newRequest) { [weak self] (dta, res, err) in
            guard let self = self else { return }
            let urlResponse = res as? HTTPURLResponse
            if let retrier = self.requestRetrier, retries > 0 {
                retrier.should(retry: urlResponse, with: err) { (status) in
                    switch status {
                    case .retry:
                        let retryTask = self.send(request: request, cancelable: cancelable, retries: 0, completion: completion)
                        cancelable.tasks.append(retryTask)
                    case .continue:
                        self.sendResponse(data: dta, response: urlResponse, error: err, completion: completion)
                    case .failed(let error):
                        self.error(error: error, completion: completion)
                    }
                }
            } else {
                self.sendResponse(data: dta, response: urlResponse, error: err, completion: completion)
            }
        }
        task.resume()
        return task
    }
    
    private func sendResponse(data: Data?, response: HTTPURLResponse?, error: Error?, completion: @escaping (Result<HttpResponse, Error>) -> Void) {
        if let urlResponse = response, urlResponse.statusCode >= 200 && urlResponse.statusCode < 300, let data = data {
            self.success(response: HttpResponse(data: data, httpResponse: urlResponse), completion: completion)
        } else {
            self.error(error: error, completion: completion)
        }
    }
    
    private func success(response: HttpResponse, completion: @escaping (Result<HttpResponse, Error>) -> Void) {
        self.respondQueue.async {
            completion(.success(response))
        }
    }
    
    private func error(error: Error?, completion: @escaping (Result<HttpResponse, Error>) -> Void) {
        var err: Error
        if let some = error {
            err = some
        } else {
            err = HttpClientError.internal
        }
        self.respondQueue.async {
            completion(.failure(err))
        }
    }
    
}

protocol RequestAdapter {
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest
}

enum RequestRetrierStatus {
    case retry, `continue`, failed(error: Error)
}

protocol RequestRetrier {
    typealias RequestRetryCompletion = (_ status: RequestRetrierStatus) -> Void
    func should(retry response: HTTPURLResponse?, with error: Error?, completion: @escaping RequestRetryCompletion)
}

struct HttpResponse {
    let data: Data
    let httpResponse: HTTPURLResponse
}

enum HttpClientError: Error {
    case `internal`
}

enum HttpClientAuthorizationError: Error, Equatable {
    case refreshing
}

protocol Cancelable {
    func cancel()
}

class URLSessionTaskCancelable: Cancelable {
    
    var tasks = [URLSessionTask]()
    
    func cancel() {
        tasks.forEach({ $0.cancel()} )
    }
    
}
