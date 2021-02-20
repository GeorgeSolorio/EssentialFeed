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
   
   func test_load_requestsCacheRetrieval() {
      let (sut, store) = makeSUT()
      
      sut.load() { _ in }
      
      XCTAssertEqual(store.recievedMessages, [.retrieve])
   }
   
   func test_load_failsOnRetrieval() {
      
      let (sut, store) = makeSUT()
      let retrievalError = anyNSError()
      
      expect(sut, toCompleteWith: .failure(retrievalError)) {
         store.completeRetrieval(with: retrievalError)
      }
   }
   
   func test_load_deliversNoImagesOnEmptyCache() {
      
      let (sut, store) = makeSUT()
      
      expect(sut, toCompleteWith: .success([])) {
         store.completeWithEmptyCache()
      }
   }
   
   func test_load_deliversCachedImagesOnLessThanSevenDaysOldCache() {
      let feed = uniqueImageFeed()
      let fixedCurrentDate = Date()
      let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
      let (sut, store) = makeSUT()
      
      expect(sut, toCompleteWith: .success(feed.models)) {
         store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp)
      }
   }
   
   // MARK: - Helpers
   
   private func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
      let models = [uniqueImage(), uniqueImage()]
      let local = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
      return (models, local)
   }
   
   private func uniqueImage() -> FeedImage {
      return FeedImage(id: UUID(), description: "any", location: "any", url: URL(string: "https://any-url.com")!)
   }
   
   private func anyNSError() -> NSError {
      return NSError(domain: "any error", code: 0)
   }
   
   private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.LoadResult, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
      
      let exp = expectation(description: "Wait for load to complete")
      
      sut.load() { recievedResult in
         switch (recievedResult, expectedResult) {
         case let (.success(recievedImages), .success(expectedImage)):
            XCTAssertEqual(recievedImages, expectedImage, file: file, line: line)
         case let (.failure(recievedError as NSError), .failure(expectedError as NSError)):
            XCTAssertEqual(recievedError, expectedError, file: file, line: line)
         default:
            XCTFail("Expected result \(expectedResult), got \(recievedResult) instead")
         }
         exp.fulfill()
      }
      
      action()
      wait(for: [exp], timeout: 1.0)
   }
   
   private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
      
      let store = FeedStoreSpy()
      let sut = LocalFeedLoader(store: store, currentDate: currentDate)
      trackForMemoryLeaks(sut, file: file, line: line)
      trackForMemoryLeaks(store, file: file, line: line)
      return (sut, store)
   }
}

private extension Date {
   func adding(days: Int) -> Date {
      return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
   }
   
   func adding(seconds: TimeInterval) -> Date {
      return self + seconds
   }
}
