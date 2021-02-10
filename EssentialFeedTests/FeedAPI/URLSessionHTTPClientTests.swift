//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by George Solorio on 2/9/21.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
   private let session: URLSession
   
   init(session: URLSession = .shared) {
      self.session = session
   }
   
   func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
      session.dataTask(with: url) { _, _, error in
         if let error = error {
            completion(.failure(error))
         }
      }.resume()
   }
}

class URLSessionHTTPClientTests: XCTestCase {
   
   func test_getFromURL_performGETRequestWithURL() {
      URLProtocolStub.startInterceptingRequests()
      
      let url = URL(string: "https://any-url")!

      let exp = expectation(description: "Wait for request")
      URLProtocolStub.observeRequests { request in
         XCTAssertEqual(request.url, url)
         XCTAssertEqual(request.httpMethod, "GET")
         exp.fulfill()
      }
      
      URLSessionHTTPClient().get(from: url) { _ in }
      
      wait(for: [exp], timeout: 1.0)
      URLProtocolStub.stopInterceptingRequests()
   }
   
   func test_getFromURL_failsOnRequestError() {
      URLProtocolStub.startInterceptingRequests()
      let url = URL(string: "https://any-url")!
      let error = NSError(domain: "any error", code: 1)
      URLProtocolStub.stub(data: nil, response: nil, error: error)
      
      let sut = URLSessionHTTPClient()
      
      let exp = expectation(description: "Wait for completion")
      sut.get(from: url) { result in
         switch result {
         case let .failure(recievedError as NSError):
            XCTAssertEqual(recievedError.code, error.code)
         default:
            XCTFail("Expected failure with error: \(error), got \(result) instead")
         }
         
         exp.fulfill()
      }
      
      wait(for: [exp], timeout: 1.0)
      URLProtocolStub.stopInterceptingRequests()
   }
   
   // MARK: - Helpers
   
   private class URLProtocolStub: URLProtocol {
      private static var stub: Stub?
      private static var requestObserver: ((URLRequest) -> Void)?
      private struct Stub {
         let data: Data?
         let response: URLResponse?
         let error: Error?
      }
      
      static func observeRequests(observer: @escaping (URLRequest) -> Void) {
         requestObserver = observer
      }
      
      static func startInterceptingRequests() {
         URLProtocol.registerClass(URLProtocolStub.self)
      }
      
      static func stopInterceptingRequests() {
         URLProtocol.unregisterClass(URLProtocolStub.self)
         stub = nil
         requestObserver = nil
      }
      
      static func stub(data: Data?, response: URLResponse?, error: Error? = nil) {
         stub = Stub(data: data, response: response, error: error)
      }
      
      override class func canInit(with request: URLRequest) -> Bool {
         requestObserver?(request)
         return true
      }
      
      override class func canonicalRequest(for request: URLRequest) -> URLRequest {
         return request
      }
      
      override func startLoading() {
         
         if let data = URLProtocolStub.stub?.data {
            client?.urlProtocol(self, didLoad: data)
         }
         
         if let response = URLProtocolStub.stub?.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
         }
         
         if let error = URLProtocolStub.stub?.error {
            client?.urlProtocol(self, didFailWithError: error)
         }
         
         client?.urlProtocolDidFinishLoading(self)
      }
      
      override func stopLoading() { }
   }
}
