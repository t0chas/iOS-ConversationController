//
//  ConversationControllerUnitTests.m
//  ConversationControllerUnitTests
//
//  Created by Alejandro Santiago on 5/26/17.
//  Copyright © 2017 Alejandro Santiago. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TSLinkedList.h"

@interface ConversationControllerUnitTests : XCTestCase

@end

@implementation ConversationControllerUnitTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testLinkedList_addItem{
    TSLinkedList* linkedList = [[TSLinkedList alloc] init];
    XCTAssertNotNil(linkedList);
    XCTAssertTrue(linkedList.count == 0);
    
    TSLinkedListItem* item = [[TSLinkedListItem alloc] init];
    [linkedList addItem:item];
    
    XCTAssertTrue(linkedList.count == 1);
    TSLinkedListItem* assertItem = [linkedList itemAtIndex:0];
    XCTAssertTrue(assertItem == item);
}

- (void)testLinkedList_indexOfItem{
    TSLinkedList* linkedList = [[TSLinkedList alloc] init];
    XCTAssertNotNil(linkedList);
    XCTAssertTrue(linkedList.count == 0);
    
    TSLinkedListItem* item0 = [[TSLinkedListItem alloc] init];
    [linkedList addItem:item0];
    TSLinkedListItem* item1 = [[TSLinkedListItem alloc] init];
    [linkedList addItem:item1];
    TSLinkedListItem* item2 = [[TSLinkedListItem alloc] init];
    [linkedList addItem:item2];
    TSLinkedListItem* item3 = [[TSLinkedListItem alloc] init];
    [linkedList addItem:item3];
    TSLinkedListItem* item4 = [[TSLinkedListItem alloc] init];
    [linkedList addItem:item4];
    
    XCTAssertTrue(linkedList.count == 5);
    
    TSLinkedListItem* assertItem = [linkedList itemAtIndex:2];
    XCTAssertTrue(assertItem == item2);
    
    NSUInteger idx = [linkedList indexOfItem:item3];
    XCTAssertTrue(idx == 3);
    
    idx = [linkedList indexOfItem:item0];
    XCTAssertTrue(idx == 0);
    
    idx = [linkedList indexOfItem:item4];
    XCTAssertTrue(idx == 4);
}

- (void)testLinkedList_insertItem_last{
    TSLinkedList* linkedList = [[TSLinkedList alloc] init];
    XCTAssertNotNil(linkedList);
    XCTAssertTrue(linkedList.count == 0);
    
    TSLinkedListItem* item0 = [[TSLinkedListItem alloc] init];
    [linkedList addItem:item0];
    TSLinkedListItem* item1 = [[TSLinkedListItem alloc] init];
    [linkedList addItem:item1];
    TSLinkedListItem* item2 = [[TSLinkedListItem alloc] init];
    [linkedList addItem:item2];
    TSLinkedListItem* item3 = [[TSLinkedListItem alloc] init];
    [linkedList addItem:item3];
    TSLinkedListItem* item4 = [[TSLinkedListItem alloc] init];
    [linkedList addItem:item4];
    
    XCTAssertTrue(linkedList.count == 5);
    
    
    TSLinkedListItem* otherItem = [[TSLinkedListItem alloc] init];
    [linkedList insertItem:otherItem atIndex:5];
    XCTAssertTrue(linkedList.count == 6);
    
    TSLinkedListItem* assertItem = [linkedList itemAtIndex:5];
    XCTAssertTrue(assertItem == otherItem);
    
    assertItem = [linkedList itemAtIndex:4];
    XCTAssertTrue(assertItem == item4);
    
    
    NSUInteger idx = [linkedList indexOfItem:otherItem];
    XCTAssertTrue(idx == 5);
}

- (void)testLinkedList_insertItem_middle{
    TSLinkedList* linkedList = [[TSLinkedList alloc] init];
    XCTAssertNotNil(linkedList);
    XCTAssertTrue(linkedList.count == 0);
    
    TSLinkedListItem* item0 = [[TSLinkedListItem alloc] init];
    [linkedList addItem:item0];
    TSLinkedListItem* item1 = [[TSLinkedListItem alloc] init];
    [linkedList addItem:item1];
    TSLinkedListItem* item2 = [[TSLinkedListItem alloc] init];
    [linkedList addItem:item2];
    TSLinkedListItem* item3 = [[TSLinkedListItem alloc] init];
    [linkedList addItem:item3];
    TSLinkedListItem* item4 = [[TSLinkedListItem alloc] init];
    [linkedList addItem:item4];
    
    XCTAssertTrue(linkedList.count == 5);
    
    
    TSLinkedListItem* otherItem = [[TSLinkedListItem alloc] init];
    [linkedList insertItem:otherItem atIndex:3];
    XCTAssertTrue(linkedList.count == 6);
    
    TSLinkedListItem* assertItem = [linkedList itemAtIndex:3];
    XCTAssertTrue(assertItem == otherItem);
    
    assertItem = [linkedList itemAtIndex:2];
    XCTAssertTrue(assertItem == item2);
    
    assertItem = [linkedList itemAtIndex:4];
    XCTAssertTrue(assertItem == item3);
    
    
    NSUInteger idx = [linkedList indexOfItem:otherItem];
    XCTAssertTrue(idx == 3);
}

- (void)testLinkedList_insertItem_first{
    TSLinkedList* linkedList = [[TSLinkedList alloc] init];
    XCTAssertNotNil(linkedList);
    XCTAssertTrue(linkedList.count == 0);
    
    TSLinkedListItem* item0 = [[TSLinkedListItem alloc] init];
    [linkedList addItem:item0];
    TSLinkedListItem* item1 = [[TSLinkedListItem alloc] init];
    [linkedList addItem:item1];
    TSLinkedListItem* item2 = [[TSLinkedListItem alloc] init];
    [linkedList addItem:item2];
    TSLinkedListItem* item3 = [[TSLinkedListItem alloc] init];
    [linkedList addItem:item3];
    TSLinkedListItem* item4 = [[TSLinkedListItem alloc] init];
    [linkedList addItem:item4];
    
    XCTAssertTrue(linkedList.count == 5);
    
    
    TSLinkedListItem* otherItem = [[TSLinkedListItem alloc] init];
    [linkedList insertItem:otherItem atIndex:0];
    XCTAssertTrue(linkedList.count == 6);
    
    TSLinkedListItem* assertItem = [linkedList itemAtIndex:0];
    XCTAssertTrue(assertItem == otherItem);
    
    assertItem = [linkedList itemAtIndex:1];
    XCTAssertTrue(assertItem == item0);
    
    assertItem = [linkedList itemAtIndex:5];
    XCTAssertTrue(assertItem == item4);
    
    
    NSUInteger idx = [linkedList indexOfItem:otherItem];
    XCTAssertTrue(idx == 0);
}

- (void)testLinkedList_removeItem_last{
    TSLinkedList* linkedList = [[TSLinkedList alloc] init];
    XCTAssertNotNil(linkedList);
    XCTAssertTrue(linkedList.count == 0);
    
    TSLinkedListItem* item0 = [[TSLinkedListItem alloc] init];
    [linkedList addItem:item0];
    TSLinkedListItem* item1 = [[TSLinkedListItem alloc] init];
    [linkedList addItem:item1];
    TSLinkedListItem* item2 = [[TSLinkedListItem alloc] init];
    [linkedList addItem:item2];
    TSLinkedListItem* item3 = [[TSLinkedListItem alloc] init];
    [linkedList addItem:item3];
    TSLinkedListItem* item4 = [[TSLinkedListItem alloc] init];
    [linkedList addItem:item4];
    
    XCTAssertTrue(linkedList.count == 5);
    
    
    [linkedList removeItem:item4];
    XCTAssertTrue(linkedList.count == 4);
    
    TSLinkedListItem* assertItem = [linkedList itemAtIndex:4];
    XCTAssertNil(assertItem);
    
    assertItem = [linkedList itemAtIndex:3];
    XCTAssertTrue(assertItem == item3);
    
    NSUInteger idx = [linkedList indexOfItem:item4];
    XCTAssertTrue(idx == NSNotFound);
}

- (void)testLinkedList_removeItem_middle{
    TSLinkedList* linkedList = [[TSLinkedList alloc] init];
    XCTAssertNotNil(linkedList);
    XCTAssertTrue(linkedList.count == 0);
    
    TSLinkedListItem* item0 = [[TSLinkedListItem alloc] init];
    [linkedList addItem:item0];
    TSLinkedListItem* item1 = [[TSLinkedListItem alloc] init];
    [linkedList addItem:item1];
    TSLinkedListItem* item2 = [[TSLinkedListItem alloc] init];
    [linkedList addItem:item2];
    TSLinkedListItem* item3 = [[TSLinkedListItem alloc] init];
    [linkedList addItem:item3];
    TSLinkedListItem* item4 = [[TSLinkedListItem alloc] init];
    [linkedList addItem:item4];
    
    XCTAssertTrue(linkedList.count == 5);
    
    
    [linkedList removeItem:item2];
    XCTAssertTrue(linkedList.count == 4);
    
    TSLinkedListItem* assertItem = [linkedList itemAtIndex:4];
    XCTAssertNil(assertItem);
    
    assertItem = [linkedList itemAtIndex:1];
    XCTAssertTrue(assertItem == item1);
    
    assertItem = [linkedList itemAtIndex:2];
    XCTAssertTrue(assertItem == item3);
    
    assertItem = [linkedList itemAtIndex:3];
    XCTAssertTrue(assertItem == item4);
    
    NSUInteger idx = [linkedList indexOfItem:item2];
    XCTAssertTrue(idx == NSNotFound);
}

- (void)testLinkedList_removeItem_first{
    TSLinkedList* linkedList = [[TSLinkedList alloc] init];
    XCTAssertNotNil(linkedList);
    XCTAssertTrue(linkedList.count == 0);
    
    TSLinkedListItem* item0 = [[TSLinkedListItem alloc] init];
    [linkedList addItem:item0];
    TSLinkedListItem* item1 = [[TSLinkedListItem alloc] init];
    [linkedList addItem:item1];
    TSLinkedListItem* item2 = [[TSLinkedListItem alloc] init];
    [linkedList addItem:item2];
    TSLinkedListItem* item3 = [[TSLinkedListItem alloc] init];
    [linkedList addItem:item3];
    TSLinkedListItem* item4 = [[TSLinkedListItem alloc] init];
    [linkedList addItem:item4];
    
    XCTAssertTrue(linkedList.count == 5);
    
    
    [linkedList removeItem:item0];
    XCTAssertTrue(linkedList.count == 4);
    
    TSLinkedListItem* assertItem = [linkedList itemAtIndex:4];
    XCTAssertNil(assertItem);
    
    assertItem = [linkedList itemAtIndex:0];
    XCTAssertTrue(assertItem == item1);
    
    assertItem = [linkedList itemAtIndex:3];
    XCTAssertTrue(assertItem == item4);
    
    NSUInteger idx = [linkedList indexOfItem:item0];
    XCTAssertTrue(idx == NSNotFound);
}

-(void)testLinkedList_InsertPerformance {
    // This is an example of a performance test case.
    
    TSLinkedList* linkedList = [[TSLinkedList alloc] init];
    XCTAssertNotNil(linkedList);
    XCTAssertTrue(linkedList.count == 0);
    
    for(int i=0; i< 10000; i++){
        TSLinkedListItem* item0 = [[TSLinkedListItem alloc] init];
        [linkedList addItem:item0];
    }
    XCTAssertTrue(linkedList.count == 10000);
    
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        
        TSLinkedListItem* item0 = [[TSLinkedListItem alloc] init];
        [linkedList addItem:item0];
    }];
}

@end
