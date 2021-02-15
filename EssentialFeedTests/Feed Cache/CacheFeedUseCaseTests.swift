//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by George Solorio on 2/11/21.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
   
   private let store: FeedStore
   private let currentData: () -> Date
   
   init(store: FeedStore, currentDate: @escaping () -> Date) {
      self.store = store
      self.currentData = currentDate
   }
   
   func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
      store.deleteCacheFeed { [weak self] error in
         
         guard let self = self else { return }
         
         if let cacheDeletionError = error {
            completion(cacheDeletionError)
         } else {
            self.store.insert(items, timestamp: self.currentData()) { [weak self] error in
                  
               guard self != nil else { return }
               completion(error)
            }
         }
      }
   }
}

protocol FeedStore {
   typealias DeletionCompletion = (Error?) -> Void
   typealias InsertionCompletion = (Error?) -> Void

   func deleteCacheFeed(completion: @escaping DeletionCompletion)
   func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
}

class CacheFeedUseCaseTests: XCTestCase {
   
   func test_init_doesNotStoreUponCreation() {
      let (_, store) = makeSUT()
      
      XCTAssertEqual(store.recievedMessages, [])
   }
   
   func test_save_requestCacheDeletion() {
      let items = [uniqueItem(), uniqueItem()]
      let (sut, store) = makeSUT()

      sut.save(items) { _ in }
      
      XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed])
   }
   
   func test_save_doesNotRequestCacheInsertionOnDeletionError() {
      let items = [uniqueItem(), uniqueItem()]
      let (sut, store) = makeSUT()
      let deletionError = anyNSError()
      
      sut.save(items) { _ in }
      store.completeDeletion(with: deletionError)
      
      XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed])
   }
   
   func test_save_requestsNewCacheWithTimeStampOnSuccessfullDeletion() {
      let timestamp = Date()
      let items = [uniqueItem(), uniqueItem()]
      let (sut, store) = makeSUT(currentDate: { timestamp })
      
      sut.save(items) { _ in }
      store.completeDeletionSuccessfully()
      
      XCTAssertEqual(store.recievedMessages, [.deleteCachedFeed, .insert(items, timestamp)])
   }
   
   func test_save_failsOnDeletionError() {
      let (sut, store) = makeSUT()
      let deletionError = anyNSError()
      
      expect(sut, toCompleteWithError: deletionError, when: {
         store.completeDeletion(with: deletionError)
      })
   }
   
   func test_save_failsOnInsertionError() {
      
      let (sut, store) = makeSUT()
      let insertionError = anyNSError()
      
      expect(sut, toCompleteWithError: insertionError, when: {
         store.completeDeletionSuccessfully()
         store.completeInsertion(with: insertionError)
      })
   }
   
   func test_save_succeedsOnSuccessfulCacheInsertion() {
      let (sut, store) = makeSUT()
      
      expect(sut, toCompleteWithError: nil, when: {
         store.completeDeletionSuccessfully()
         store.completeInsertionSuccessfully()
      })
   }
   
   func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
      let store = FeedStoreSpy()
      var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
      
      var recievedResults = [Error?]()
      sut?.save([uniqueItem()]) { recievedResults.append($0) }
      
      sut = nil
      store.completeDeletion(with: anyNSError())
      
      XCTAssertTrue(recievedResults.isEmpty)
   }
   
   func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
      let store = FeedStoreSpy()
      var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
      
      var recievedResults = [Error?]()
      sut?.save([uniqueItem()]) { recievedResults.append($0) }
      
      store.completeDeletionSuccessfully()
      sut = nil
      store.completeDeletion(with: anyNSError())
      
      XCTAssertTrue(recievedResults.isEmpty)
   }
   
   
   // MARK: - Helpers
   
   private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
      
      let store = FeedStoreSpy()
      let sut = LocalFeedLoader(store: store, currentDate: currentDate)
      trackForMemoryLeaks(sut, file: file, line: line)
      trackForMemoryLeaks(store, file: file, line: line)
      return (sut, store)
   }
   
   private func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
      
      let exp = expectation(description: "wait for save completion")
      
      var recievedError: Error?
      sut.save([uniqueItem()]) { error in
         recievedError = error
         exp.fulfill()
      }
      
      action()
      wait(for: [exp], timeout: 1.0)
      
      XCTAssertEqual(recievedError as NSError?, expectedError, file: file, line: line)
   }
   
   private func uniqueItem() -> FeedItem {
      return FeedItem(id: UUID(), description: "any", location: "any", imageURL: URL(string: "https://any-url.com")!)
   }
   
   private func anyNSError() -> NSError {
      return NSError(domain: "any error", code: 0)
   }
   
   private class FeedStoreSpy: FeedStore {
      
      enum RecievedMessages: Equatable {
         case deleteCachedFeed
         case insert([FeedItem], Date)
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
      
      func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
         insertionCompletions.append(completion)
         recievedMessages.append(.insert(items, timestamp))
      }
      
      func completeInsertionSuccessfully(at index: Int = 0) {
         insertionCompletions[index](nil)
      }
   }
}
