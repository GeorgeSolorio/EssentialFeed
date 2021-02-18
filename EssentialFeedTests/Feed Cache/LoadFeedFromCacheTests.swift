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
      
      var recievedError: Error?
      let exp = expectation(description: "Wait for load to complete")
      sut.load() { result in
         switch result {
         case let .failure(error):
            recievedError = error
         default:
            XCTFail("Expected failure, for \(result) instead")
         }
         exp.fulfill()
      }
      
      store.completeRetrieval(with: retrievalError)
      wait(for: [exp], timeout: 1.0)
      XCTAssertEqual(recievedError as NSError?, retrievalError)
   }
   
   func test_load_deliversNoImagesOnEmptyCache() {

      let (sut, store) = makeSUT()
      
      let exp = expectation(description: "Wait for load to complete")
      var recieveImages: [FeedImage]?
      
      sut.load() { result in
         switch result {
         case let .success(images):
            recieveImages = images
         default:
            XCTFail("Expected success, got \(result) instead")
         }
         exp.fulfill()
      }

      store.completeWithEmptyCache()
      wait(for: [exp], timeout: 1.0)
      XCTAssertEqual(recieveImages, [])

   }
   
   // MARK: - Helpers
   
   private func anyNSError() -> NSError {
      return NSError(domain: "any error", code: 0)
   }
   
   private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
      
      let store = FeedStoreSpy()
      let sut = LocalFeedLoader(store: store, currentDate: currentDate)
      trackForMemoryLeaks(sut, file: file, line: line)
      trackForMemoryLeaks(store, file: file, line: line)
      return (sut, store)
   }
}
