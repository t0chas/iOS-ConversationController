//
//  TSLinkedList.m
//  ConversationControllerTest
//
//  Created by Alejandro Santiago on 5/26/17.
//  Copyright © 2017 Alejandro Santiago. All rights reserved.
//

#import "TSLinkedList.h"

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

-(void)cleanItem:(TSLinkedListItem*)item{
    if(!item)
        return;
    item.next = nil;
    item.prev = nil;
}

- (void)addItem:(TSLinkedListItem *)item{
    if(!item)
        return;
    [self cleanItem:item];
    self.count++;
    if(!self.first && !self.last){
        self.first = item;
        self.last = item;
    }else{
        self.last.next = item;
        item.prev = self.last;
        self.last = item;
    }
}

- (void)insertItem:(TSLinkedListItem *)item atIndex:(NSUInteger)index{
    if(!item)
        return;
    [self cleanItem:item];
    if(index >= self.count){
        [self addItem:item];
        return;
    }
    TSLinkedListItem* itemAtIdx = [self itemAtIndex:index];

    item.prev = itemAtIdx.prev;
    if(itemAtIdx.prev)
        itemAtIdx.prev.next = item;
    if(index == 0){
        self.first = item;
    }
    
    item.next = itemAtIdx;
    itemAtIdx.prev = item;
    self.count++;
}

- (TSLinkedListItem*)itemAtIndex:(NSUInteger)index{
    if(index >= self.count)
        return nil;
    TSLinkedListItem* item = self.first;
    for (int i = 0; i < index; i++) {
        item = item.next;
    }
    return item;
}

- (NSUInteger)indexOfItem:(TSLinkedListItem *)item{
    if(!item)
        return NSNotFound;
    if(self.first == item)
        return 0;
    if(self.last == item)
        return self.count -1;
    TSLinkedListItem* loopItem = self.first;
    NSUInteger idx = 0;
    while (loopItem != nil) {
        if(loopItem == item)
            return idx;
        loopItem = loopItem.next;
        idx++;
    }
    return NSNotFound;
}

- (void)removeItem:(TSLinkedListItem *)item{
    if(!item)
        return;
    /*if(self.first == item && self.last == item){
        self.last = nil;
        self.first = nil;
        self.count = 0;
        [self cleanItem:item];
        return;
    }//*/
    if(self.last == item){
        self.last = item.prev;
        if(self.last)
            self.last.next = nil;
    }
    if(self.first == item){
        self.first = item.next;
        if(self.first)
            self.first.prev = nil;
    }
    
    if(item.prev)
        item.prev.next = item.next;
    if(item.next)
        item.next.prev = item.prev;
    
    [self cleanItem:item];
    self.count--;
    return;
}

@end
