//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by George Solorio on 2/11/21.
//

import XCTest
import EssentialFeed


class LocalFeedLoader {
   
   var store: FeedStore
   
   init(store: FeedStore) {
      self.store = store
   }
   
   func save(_ items: [FeedItem]) {
      store.deleteCacheFeed()
   }
}

class FeedStore {
   var deleteCacheFeedCallCount = 0
   
   func deleteCacheFeed() {
      deleteCacheFeedCallCount += 1
   }
}

class CacheFeedUseCaseTests: XCTestCase {
   
   func test_init_doesNotDeleteCacheUponCreation() {
      let store = FeedStore()
      _ = LocalFeedLoader(store: store)
      
      XCTAssertEqual(store.deleteCacheFeedCallCount, 0)
   }
   
   func test_save_requestCacheDeletion() {
      let store = FeedStore()
      let sut = LocalFeedLoader(store: store)
      let items = [uniqueItem(), uniqueItem()]
      sut.save(items)
      
      XCTAssertEqual(store.deleteCacheFeedCallCount, 1)
   }
   
   
   // MARK: - Helpers
   func uniqueItem() -> FeedItem {
      return FeedItem(id: UUID(), description: "any", location: "any", imageURL: URL(string: "https://any-url.com")!)
   }
}
