//
//  TSLinkedList.h
//  ConversationControllerTest
//
//  Created by Alejandro Santiago on 5/26/17.
//  Copyright © 2017 Alejandro Santiago. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSLinkedListItem.h"

@interface TSLinkedList : NSObject

@property (nonatomic, assign, readonly) NSUInteger count;

-(void)addItem:(TSLinkedListItem*)item;
-(void)insertItem:(TSLinkedListItem*)item atIndex:(NSUInteger)index;

-(TSLinkedListItem*)itemAtIndex:(NSUInteger)index;

-(NSUInteger)indexOfItem:(TSLinkedListItem*)item;

-(void)removeItem:(TSLinkedListItem*)item;

@end
