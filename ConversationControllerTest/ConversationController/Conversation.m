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

@property (nonatomic, strong) NSMutableArray<ConversationItem*>* childs;

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
        self.childs = [NSMutableArray new];
    }
    return self;
}

- (void)addChild:(ConversationItem*)item{
    [self.childs addObject:item];
}

- (void)insertChild:(ConversationItem *)item atIndex:(NSUInteger)index{
    [self.childs insertObject:item atIndex:index];
    [self setChildsDirtyFromIndex:index +1];
}

- (void)removeChild:(ConversationItem *)item{
    NSUInteger index = [self.childs indexOfObject:item];
    if(index == NSNotFound)
        return;
    [self.childs removeObjectAtIndex:index];
    [self setChildsDirtyFromIndex:index];
}

-(void)setChildsDirtyFromIndex:(NSUInteger)index{
    ConversationItem* item = nil;
    for (NSUInteger i= index; i < self.childs.count; i++) {
        item = self.childs[index];
        [item setDirty];
    }
}

-(id<ConversationTree>)itemAtConversationIndex:(NSIndexPath*)conversationIndex{
    if(!conversationIndex)
        return nil;
    id<ConversationTree> item = self;
    NSMutableArray<ConversationItem*>* itemList = [item childs];
    for(NSUInteger i = 0; i < conversationIndex.length; i++){
        NSUInteger idx = [conversationIndex indexAtPosition:i];
        if(idx >= itemList.count)
            return nil;
        item = (id<ConversationTree>)[itemList objectAtIndex:idx];
        if(!item)
            return nil;
        itemList = [item childs];
        if(!itemList)
            return nil;
    }
    return item;
}

-(ConversationItem*)conversationItemAtConversationIndex:(NSIndexPath*)conversationIndex{
    id<ConversationTree> item = [self itemAtConversationIndex:conversationIndex];
    if(![item isKindOfClass:[ConversationItem class]])
        return nil;
    ConversationItem* conversationItem = (ConversationItem*)item;
    return conversationItem;
}

- (ConversationItem *)itemAtIndex:(NSUInteger)index{
    ConversationItem* item = (ConversationItem*)[self.childs objectAtIndex:index];
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
    [treeItemAtIndex insertChild:item atIndex:lastIndex];
}

@end
