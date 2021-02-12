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
      store.deleteCacheFeed { [unowned self] error in
         completion(error)
         if error == nil {
            self.store.insert(items, timestamp: self.currentData())
         }
      }
   }
}

class FeedStore {
   
   typealias DeletionCompletion = (Error?) -> Void
   
   enum RecievedMessages: Equatable {
      case deleteCachedFeed
      case insert([FeedItem], Date)
   }
   
   private(set) var recievedMessages = [RecievedMessages]()
   private var deletionCompletions = [DeletionCompletion]()
   
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
   
   func insert(_ items: [FeedItem], timestamp: Date) {
      recievedMessages.append(.insert(items, timestamp))
   }
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
      let items = [uniqueItem(), uniqueItem()]
      let (sut, store) = makeSUT()
      let deletionError = anyNSError()
      
      var recievedError: Error?
      let exp = expectation(description: "wait for save completion")
      sut.save(items) { error in
         recievedError = error
         exp.fulfill()
      }
      
      store.completeDeletion(with: deletionError)
      wait(for: [exp], timeout: 1.0)
      XCTAssertEqual(recievedError as NSError?, deletionError)
   }
   
   // MARK: - Helpers
   
   private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
      
      let store = FeedStore()
      let sut = LocalFeedLoader(store: store, currentDate: currentDate)
      trackForMemoryLeaks(sut, file: file, line: line)
      trackForMemoryLeaks(store, file: file, line: line)
      return (sut, store)
   }
   
   private func uniqueItem() -> FeedItem {
      return FeedItem(id: UUID(), description: "any", location: "any", imageURL: URL(string: "https://any-url.com")!)
   }
   
   private func anyNSError() -> NSError {
      return NSError(domain: "any error", code: 0)
   }
}
