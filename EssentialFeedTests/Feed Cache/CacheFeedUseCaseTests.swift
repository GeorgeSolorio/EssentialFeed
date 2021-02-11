//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by George Solorio on 2/11/21.
//

import XCTest

class LocalFeedLoader {
   init(store: FeedStore) {
      
   }
}

class FeedStore {
   var deleteCacheFeedCallCount = 0
}

class CacheFeedUseCaseTests: XCTestCase {
   
   func test_init_doesNotDeleteCacheUponCreation() {
      let store = FeedStore()
      _ = LocalFeedLoader(store: store)
      
      XCTAssertEqual(store.deleteCacheFeedCallCount, 0)
   }
}
