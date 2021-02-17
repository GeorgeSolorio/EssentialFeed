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
   
   private class FeedStoreSpy: FeedStore {
      
      enum RecievedMessages: Equatable {
         case deleteCachedFeed
         case insert([LocalFeedImage], Date)
      }
      
      private(set) var recievedMessages = [RecievedMessages]()
      private var deletionCompletions = [DeletionCompletion]()
      private var insertionCompletions = [InsertionCompletion]()
      
      func deleteCacheFeed(completion: @escaping DeletionCompletion) {
         deletionCompletions.append(completion)
         recievedMessages.append(.deleteCachedFeed)
      }
      
      func completeDeletion(with error: Error, at index: Int = 0) {
         deletionCompletions[index](error)
      }
      
      func completeDeletionSuccessfully(at index: Int = 0) {
         deletionCompletions[index](nil)
      }
      
      func completeInsertion(with error: Error?, at index: Int = 0) {
         insertionCompletions[index](error)
      }
      
      func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
         insertionCompletions.append(completion)
         recievedMessages.append(.insert(feed, timestamp))
      }
      
      func completeInsertionSuccessfully(at index: Int = 0) {
         insertionCompletions[index](nil)
      }
   }
}
