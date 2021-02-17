//
//  LoadFeedFromCacheTests.swift
//  EssentialFeedTests
//
//  Created by George Solorio on 2/17/21.
//

import XCTest
import EssentialFeed

class LoadFeedFromCacheTests: XCTestCase {
   
   func test_init_doesNotMessageStoreUponCreation() {
      let (_, store) = makeSUT()
      
      XCTAssertEqual(store.recievedMessages, [])
   }
   
   
   // MARK: - Helpers
   
   private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
      
      let store = FeedStoreSpy()
      let sut = LocalFeedLoader(store: store, currentDate: currentDate)
      trackForMemoryLeaks(sut, file: file, line: line)
      trackForMemoryLeaks(store, file: file, line: line)
      return (sut, store)
   }
}
