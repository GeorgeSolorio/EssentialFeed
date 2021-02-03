//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by George Solorio on 2/3/21.
//

import XCTest

class RemoteFeedLoader {
   
}

class HTTPClient {
   var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
   
   func test_init_doesNotRequestDataFromURL() {
      
      let client = HTTPClient()
      _ = RemoteFeedLoader()
            
      XCTAssertNil(client.requestedURL)
   }
}
