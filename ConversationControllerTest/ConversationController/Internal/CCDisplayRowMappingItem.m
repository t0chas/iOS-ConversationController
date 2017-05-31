//
//  CCDisplayMappingItem.m
//  ConversationControllerTest
//
//  Created by Alejandro Santiago on 5/29/17.
//  Copyright © 2017 Alejandro Santiago. All rights reserved.
//

#import "CCDisplayRowMappingItem.h"
#import <UIKit/UIKit.h>

#import "CCDisplaySectionMapping.h"

@interface CCDisplayRowMappingItem ()

@property (nonatomic, assign) BOOL isContentConversationCell;
@property (nonatomic, assign) BOOL isExpandConversationCell;
@property (nonatomic, assign) BOOL isReplyToConversationCell;
@property (nonatomic, strong) NSIndexPath* conversationIndex;

@property (nonatomic, weak) CCDisplaySectionMapping* parent;
@property (nonatomic, assign) NSInteger row;

@property (nonatomic, strong) NSIndexPath* displayIndex;

-(void)isRowMappingForSectionMapping:(CCDisplaySectionMapping*)sectionMapping atRow:(NSInteger)row;

@end

@implementation CCDisplayRowMappingItem

-(void)isRowMappingForSectionMapping:(CCDisplaySectionMapping *)sectionMapping atRow:(NSInteger)row{
    self.parent = sectionMapping;
    self.row = row;
    self.displayIndex = [NSIndexPath indexPathForRow:self.row inSection:self.parent.section];
}

+(instancetype)mappingItemForConversationIndex:(NSIndexPath *)conversationIndex{
    CCDisplayRowMappingItem* item = [[CCDisplayRowMappingItem alloc] init];
    item.isContentConversationCell = NO;
    item.isExpandConversationCell = NO;
    item.isReplyToConversationCell = NO;
    item.conversationIndex = conversationIndex;
    return item;
}

+ (instancetype)contentMappingItemForConversationIndex:(NSIndexPath *)conversationIndex{
    CCDisplayRowMappingItem* item = [self mappingItemForConversationIndex:conversationIndex];
    item.isContentConversationCell = YES;
    return item;
}

+(instancetype)replyMappingItemForConversationIndex:(NSIndexPath *)conversationIndex{
    CCDisplayRowMappingItem* item = [self mappingItemForConversationIndex:conversationIndex];
    item.isReplyToConversationCell = YES;
    return item;
}

+(instancetype)expandMappingItemForConversationIndex:(NSIndexPath *)conversationIndex{
    CCDisplayRowMappingItem* item = [self mappingItemForConversationIndex:conversationIndex];
    item.isExpandConversationCell = YES;
    return item;
}

@end

