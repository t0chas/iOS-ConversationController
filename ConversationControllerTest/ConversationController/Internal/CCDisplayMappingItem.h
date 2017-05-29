//
//  CCDisplayMappingItem.h
//  ConversationControllerTest
//
//  Created by Alejandro Santiago on 5/29/17.
//  Copyright © 2017 Alejandro Santiago. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSLinkedListItem.h"

@interface CCDisplayMappingItem : TSLinkedListItem

@property (nonatomic, assign, readonly) BOOL isExpandConversationCell;
@property (nonatomic, assign, readonly) BOOL isReplyToConversationCell;
@property (nonatomic, strong, readonly) NSIndexPath* conversationIndex;
@property (nonatomic, strong, readonly) NSIndexPath* displayIndex;

/*+(instancetype)mappingWithConversationIndex:(NSIndexPath*)conversationIndex displayIndex:(NSIndexPath*)displayIndex;
+(instancetype)mappingWithConversationIndex:(NSIndexPath*)conversationIndex displayRow:(NSInteger)row displaySection:(NSInteger)section;
+(instancetype)mappingWithExpandConversationIndex:(NSIndexPath*)conversationIndex  displayRow:(NSInteger)row displaySection:(NSInteger)section;
+(instancetype)mappingWithReplyConversationIndex:(NSIndexPath*)conversationIndex  displayRow:(NSInteger)row displaySection:(NSInteger)section;
 //*/

@end
