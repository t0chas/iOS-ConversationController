//
//  CCDisplayMappingItem.h
//  ConversationControllerTest
//
//  Created by Alejandro Santiago on 5/29/17.
//  Copyright © 2017 Alejandro Santiago. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSLinkedListItem.h"

@interface CCDisplayRowMappingItem : NSObject /*TSLinkedListItem*/

@property (nonatomic, assign, readonly) BOOL isContentConversationCell;
@property (nonatomic, assign, readonly) BOOL isExpandConversationCell;
@property (nonatomic, assign, readonly) BOOL isReplyToConversationCell;
@property (nonatomic, strong, readonly) NSIndexPath* conversationIndex;
@property (nonatomic, strong, readonly) NSIndexPath* displayIndex;

+(instancetype)mappingItemForConversationIndex:(NSIndexPath *)conversationIndex;
+(instancetype)contentMappingItemForConversationIndex:(NSIndexPath *)conversationIndex;
+(instancetype)replyMappingItemForConversationIndex:(NSIndexPath *)conversationIndex;
+(instancetype)expandMappingItemForConversationIndex:(NSIndexPath *)conversationIndex;

@end
