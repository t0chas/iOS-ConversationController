//
//  CCDisplayMappingItem.m
//  ConversationControllerTest
//
//  Created by Alejandro Santiago on 5/29/17.
//  Copyright © 2017 Alejandro Santiago. All rights reserved.
//

#import "CCDisplayMappingItem.h"
#import <UIKit/UIKit.h>

@interface CCDisplayMappingItem ()

@property (nonatomic, assign) BOOL isExpandConversationCell;
@property (nonatomic, assign) BOOL isReplyToConversationCell;
@property (nonatomic, strong) NSIndexPath* conversationIndex;
@property (nonatomic, strong) NSIndexPath* displayIndex;

@end

@implementation CCDisplayMappingItem

+ (instancetype)mappingWithConversationIndex:(NSIndexPath *)conversationIndex displayRow:(NSInteger)row displaySection:(NSInteger)section{
    NSIndexPath* displayIndex = [NSIndexPath indexPathForRow:row inSection:section];
    return [self mappingWithConversationIndex:conversationIndex displayIndex:displayIndex];
}

+ (instancetype)mappingWithConversationIndex:(NSIndexPath *)conversationIndex displayIndex:(NSIndexPath *)displayIndex{
    CCDisplayMappingItem* mapping = [[CCDisplayMappingItem alloc] init];
    mapping.conversationIndex = conversationIndex;
    mapping.displayIndex = displayIndex;
    return mapping;
}

+ (instancetype)mappingWithExpandConversationIndex:(NSIndexPath *)conversationIndex displayRow:(NSInteger)row displaySection:(NSInteger)section{
    CCDisplayMappingItem* mapping = [self mappingWithConversationIndex:conversationIndex displayRow:row displaySection:section];
    mapping.isExpandConversationCell = YES;
    return mapping;
}

+ (instancetype)mappingWithReplyConversationIndex:(NSIndexPath *)conversationIndex displayRow:(NSInteger)row displaySection:(NSInteger)section{
    CCDisplayMappingItem* mapping = [self mappingWithConversationIndex:conversationIndex displayRow:row displaySection:section];
    mapping.isReplyToConversationCell = YES;
    return mapping;
}

@end

