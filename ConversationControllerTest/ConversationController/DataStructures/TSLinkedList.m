//
//  TSLinkedList.m
//  ConversationControllerTest
//
//  Created by Alejandro Santiago on 5/26/17.
//  Copyright © 2017 Alejandro Santiago. All rights reserved.
//

#import "TSLinkedList.h"
@interface TSLinkedListItem()
{
    @public TSLinkedListItem* _prev;
    @public TSLinkedListItem* _next;
}

@end

@implementation TSLinkedListItem


@end

@interface TSLinkedList ()

@property (nonatomic, assign) NSUInteger count;

@property (nonatomic, strong) TSLinkedListItem* first;
@property (nonatomic, strong) TSLinkedListItem* last;

@end

@implementation TSLinkedList

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.count = 0;
    }
    return self;
}

/*-(void)cleanItem:(TSLinkedListItem*)item{
    if(!item)
        return;
    item->_next = nil;
    item->_prev = nil;
}*/

- (void)addItem:(TSLinkedListItem *)item{
    if(!item)
        return;
    item->_next = nil;
    item->_prev = nil;
    
    self->_count++;
    if(!self->_first && !self->_last){
        self->_first = item;
        self->_last = item;
    }else{
        self->_last->_next = item;
        item->_prev = self->_last;
        self->_last = item;
    }
}

- (void)insertItem:(TSLinkedListItem *)item atIndex:(NSUInteger)index{
    if(!item)
        return;
    item->_next = nil;
    item->_prev = nil;
    
    if(index >= self.count){
        [self addItem:item];
        return;
    }
    
    TSLinkedListItem* itemAtIdx = [self itemAtIndex:index];
    item->_prev = itemAtIdx->_prev;
    if(itemAtIdx->_prev)
        itemAtIdx->_prev->_next = item;
    if(index == 0){
        self->_first = item;
    }
    
    item.next = itemAtIdx;
    itemAtIdx.prev = item;
    self->_count = self->_count + 1;
}

- (TSLinkedListItem*)itemAtIndex:(NSUInteger)index{
    if(index >= self->_count)
        return nil;
    TSLinkedListItem* item = self->_first;
    for (NSUInteger i = 0; i < index; i = i + 1) {
        item = item->_next;
    }
    return item;
}

- (NSUInteger)indexOfItem:(TSLinkedListItem *)item{
    if(!item)
        return NSNotFound;
    if(self->_first == item)
        return 0;
    if(self->_last == item)
        return self->_count -1;
    TSLinkedListItem* loopItem = self->_first;
    NSUInteger idx = 0;
    while (loopItem != nil) {
        if(loopItem == item)
            return idx;
        loopItem = loopItem->_next;
        idx++;
    }
    return NSNotFound;
}

- (void)removeItem:(TSLinkedListItem *)item{
    if(!item)
        return;
    if(!item->_prev && !item->_next)
        return;
    /*if(self.first == item && self.last == item){
        self.last = nil;
        self.first = nil;
        self.count = 0;
        [self cleanItem:item];
        return;
    }//*/
    if(self->_last == item){
        self->_last = item->_prev;
        if(self->_last)
            self->_last->_next = nil;
    }
    if(self.first == item){
        self->_first = item->_next;
        if(self->_first)
            self->_first->_prev = nil;
    }
    
    if(item->_prev)
        item->_prev->_next = item->_next;
    if(item->_next)
        item->_next->_prev = item->_prev;
    
    item->_next = nil;
    item->_prev = nil;
    
    self->_count--;
    return;
}

@end
