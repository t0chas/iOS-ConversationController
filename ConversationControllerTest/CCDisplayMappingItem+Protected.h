//
//  CCDisplayMappingItem+Protected.h
//  ConversationControllerTest
//
//  Created by Alejandro Santiago on 5/29/17.
//  Copyright © 2017 Alejandro Santiago. All rights reserved.
//

#ifndef CCDisplayMappingItem_Protected_h
#define CCDisplayMappingItem_Protected_h

#import "CCDisplayMappingItem.h"

@interface CCDisplayMappingItem (protected)

@property (nonatomic, assign) BOOL isExpandConversationCell;
@property (nonatomic, assign) BOOL isReplyToConversationCell;
@property (nonatomic, strong) NSIndexPath* conversationIndex;
@property (nonatomic, strong) NSIndexPath* displayIndex;

@end

#endif /* CCDisplayMappingItem_Protected_h */
