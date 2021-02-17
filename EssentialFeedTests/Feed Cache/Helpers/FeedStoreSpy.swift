//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by George Solorio on 2/17/21.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
   
   enum RecievedMessages: Equatable {
      case deleteCachedFeed
      case insert([LocalFeedImage], Date)
      case retrieve
   }
   
   private(set) var recievedMessages = [RecievedMessages]()
   private var deletionCompletions = [DeletionCompletion]()
   private var insertionCompletions = [InsertionCompletion]()
   private var retrievalCompletions = [RetrievalCompletion]()
   
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
   
   func retrieve(completion: @escaping RetrievalCompletion) {
      retrievalCompletions.append(completion)
      recievedMessages.append(.retrieve)
   }
   
   func completeRetrieval(with error: Error, at index: Int = 0) {
      retrievalCompletions[index](error)
   }
}
