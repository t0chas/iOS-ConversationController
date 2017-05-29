//
//  Conversation.m
//  ConversationControllerTest
//
//  Created by Alejandro Santiago on 5/26/17.
//  Copyright © 2017 Alejandro Santiago. All rights reserved.
//

#import "Conversation.h"
#import "ConversationItem+Protected.h"

@interface Conversation ()

@property (nonatomic, strong) TSLinkedList* childs;

@end

@interface Conversation (ConversationTree) <ConversationTree>

@end

@implementation Conversation

- (NSUInteger)count{
    return self.childs.count;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.childs = [[TSLinkedList alloc] init];
    }
    return self;
}

- (void)addChild:(ConversationItem*)item{
    [self.childs addItem:item];
}

- (void)removeChild:(ConversationItem *)item{
    [self.childs removeItem:item];
}

-(id<ConversationTree>)itemAtConversationIndex:(NSIndexPath*)conversationIndex{
    if(!conversationIndex)
        return nil;
    id<ConversationTree> item = self;
    TSLinkedList* itemList = [item childs];
    for(NSUInteger i = 0; i < conversationIndex.length; i++){
        NSUInteger idx = [conversationIndex indexAtPosition:i];
        if(idx >= itemList.count)
            return nil;
        item = (id<ConversationTree>)[itemList itemAtIndex:idx];
        if(!item)
            return nil;
        itemList = [item childs];
        if(!itemList)
            return nil;
    }
    return item;
}

-(void)insertItem:(ConversationItem *)item atConversationIndex:(NSIndexPath *)conversationIndex{
    if(!item || !conversationIndex)
        return;
    NSIndexPath* parentConversationIndex = [conversationIndex indexPathByRemovingLastIndex];
    NSUInteger lastIndex = [conversationIndex indexAtPosition:conversationIndex.length -1];
    id<ConversationTree> treeItemAtIndex = [self itemAtConversationIndex:parentConversationIndex];
    if(!treeItemAtIndex)
        return;
    TSLinkedList* childs = [treeItemAtIndex childs];
    [childs insertItem:item atIndex:lastIndex];
    for(NSUInteger idx = lastIndex +1; idx < childs.count; idx++){
        ConversationItem* item = (ConversationItem*)[childs itemAtIndex:idx];
#warning TODO [item setDirty];
        //[item setDirty];
    }
}

@end
