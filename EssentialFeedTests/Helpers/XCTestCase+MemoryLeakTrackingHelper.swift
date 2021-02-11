//
//  XCTTestCase+MemoryLeakTrackingHelper.swift
//  EssentialFeedTests
//
//  Created by George Solorio on 2/10/21.
//

import Foundation
import XCTest

extension XCTestCase {
   func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
      addTeardownBlock { [weak instance] in
         XCTAssertNil(instance, "Instance should have been deallocated! Potential memory leak.", file: file, line: line)
      }
   }
}
