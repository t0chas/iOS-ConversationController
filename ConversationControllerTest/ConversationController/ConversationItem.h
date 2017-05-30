//
//  ConversationItem.h
//  ConversationControllerTest
//
//  Created by Alejandro Santiago on 12/28/16.
//  Copyright © 2016 Alejandro Santiago. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSLinkedList.h"

@interface ConversationItem : NSObject /*TSLinkedListItem*/

@property (nonatomic, weak, readonly) ConversationItem* parent;

@property (nonatomic, strong, readonly) NSIndexPath* conversationIndex;
//@property (nonatomic, strong) NSMutableArray<ConversationItem*>* childs;

@property (nonatomic, assign, readonly) NSInteger conversationLevel;

@property (nonatomic, assign, readonly) NSInteger showingN;
@property (nonatomic, assign, readonly) NSInteger childCount;
@property (nonatomic, assign, readonly) BOOL hasChilds;
@property (nonatomic, assign, readonly) BOOL isExpanded;
@property (nonatomic, assign) BOOL isReplyable;

- (instancetype)initWithConversationIndex:(NSIndexPath*)conversationIndex;

-(void)showMore:(NSInteger)howMany;


-(void)addChild:(ConversationItem*)item;
-(void)removeChild:(ConversationItem*)item;
-(void)insertChild:(ConversationItem*)item atIndex:(NSUInteger)index;

- (ConversationItem *)itemAtIndex:(NSUInteger)index;

-(void)setDirty;

-(NSArray<NSIndexPath*>*)displayIndexes;

@end
