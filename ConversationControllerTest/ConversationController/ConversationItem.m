//
//  ConversationItem.m
//  ConversationControllerTest
//
//  Created by Alejandro Santiago on 12/28/16.
//  Copyright © 2016 Alejandro Santiago. All rights reserved.
//

#import "ConversationItem.h"

@interface ConversationItem ()

@property (nonatomic, weak) ConversationItem* parent;

@property (nonatomic, strong) NSMutableArray<ConversationItem*>* childs;

@property (nonatomic, strong) NSIndexPath* conversationIndex;

@property (nonatomic, assign) NSInteger showingN;

@property (nonatomic, strong) NSIndexPath* displayIndex;
@property (nonatomic, strong) NSIndexPath* displayContentIndex;
@property (nonatomic, strong) NSIndexPath* displayExpandIndex;
@property (nonatomic, strong) NSIndexPath* displayReplyIndex;
@property (nonatomic, copy) NSArray<NSIndexPath*>* displayChildIndexes;

@end

@implementation ConversationItem

-(void)showMore:(NSInteger)howMany{
    self.showingN += howMany;
}

- (instancetype)initWithConversationIndex:(NSIndexPath *)conversationIndex
{
    self = [super init];
    if (self) {
        self.childs = [NSMutableArray new];
        self.conversationIndex = conversationIndex;
        self.showingN = 3;
        self.isReplyable = YES;
    }
    return self;
}

- (void)addChild:(ConversationItem *)item{
    item.parent = self;
    [self.childs addObject:item];
}

- (void)insertChild:(ConversationItem *)item atIndex:(NSUInteger)index{
    item.parent = self;
    [self.childs insertObject:item atIndex:index];
    [self setChildsDirtyFromIndex:index +1];
}

- (void)removeChild:(ConversationItem *)item{
    if(item.parent != self)
        return;
    item.parent = nil;
    NSUInteger index = [self.childs indexOfObject:item];
    if(index == NSNotFound)
        return;
    [self.childs removeObjectAtIndex:index];
    [self setChildsDirtyFromIndex:index];
}

- (ConversationItem *)itemAtIndex:(NSUInteger)index{
    ConversationItem* item = (ConversationItem*)[self.childs objectAtIndex:index];
    return item;
}

-(void)setChildsDirtyFromIndex:(NSUInteger)index{
    ConversationItem* item = nil;
    for (NSUInteger i= index; i < self.childs.count; i++) {
        item = self.childs[index];
        [item setDirty];
    }
}

- (void)setDirty{
    self.conversationIndex = [self.parent conversationIndexOfChild:self];
    //What happens with the display mappings???
    //they are offset now!!!
    //Conversation might need to handle both, structure and mappings (as they have a two way binding)
    [self setChildsDirtyFromIndex:0];
}

-(NSIndexPath*)conversationIndexOfChild:(ConversationItem*)childItem{
    if(!self.conversationIndex)
        return nil;
    NSUInteger childIdx = [self.childs indexOfObject:childItem];
    if(childIdx == NSNotFound)
        return nil;
    NSIndexPath* childConversationIndex = [self.conversationIndex indexPathByAddingIndex:childIdx];
    return childConversationIndex;
}

-(NSArray<NSIndexPath*>*)displayIndexes{
    NSMutableArray<NSIndexPath*>* indexes = [NSMutableArray new];
    if(self.displayIndex)
        [indexes addObject:self.displayIndex];
    if(self.hasContent && self.displayContentIndex)
        [indexes addObject:self.displayContentIndex];
    if(self.displayExpandIndex)
        [indexes addObject:self.displayExpandIndex];
    if(self.displayChildIndexes && self.displayChildIndexes.count)
       [indexes addObjectsFromArray:self.displayChildIndexes];
    if(self.displayReplyIndex)
        [indexes addObject:self.displayReplyIndex];
    return indexes;
}

- (NSInteger)conversationLevel{
    return self.conversationIndex.length -1;
}

- (NSInteger)childCount{
    if(!self.childs)
        return 0;
    return self.childs.count;
}

- (BOOL)hasChilds{
    return self.childCount > 0;
}

- (BOOL)isExpanded{
    return self.showingN >= self.childCount;
}

@end
