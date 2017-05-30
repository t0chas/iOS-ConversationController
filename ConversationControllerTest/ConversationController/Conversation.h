//
//  Conversation.h
//  ConversationControllerTest
//
//  Created by Alejandro Santiago on 5/26/17.
//  Copyright © 2017 Alejandro Santiago. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConversationItem.h"
#import "TSLinkedList.h"

@interface Conversation : NSObject

@property (nonatomic, assign, readonly) NSUInteger count;

-(void)addChild:(ConversationItem*)item;
-(void)insertChild:(ConversationItem*)item atIndex:(NSUInteger)index;
-(void)removeChild:(ConversationItem*)item;

-(void)insertItem:(ConversationItem*)item atConversationIndex:(NSIndexPath*)conversationIndex;

-(ConversationItem*)itemAtIndex:(NSUInteger)index;

-(ConversationItem*)conversationItemAtConversationIndex:(NSIndexPath*)conversationIndex;

@end
