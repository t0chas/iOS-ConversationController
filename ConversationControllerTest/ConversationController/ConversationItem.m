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

@property (nonatomic, strong) TSLinkedList* childs;

@property (nonatomic, strong) NSIndexPath* conversationIndex;

@property (nonatomic, assign) NSInteger showingN;

@end

@implementation ConversationItem

-(void)showMore:(NSInteger)howMany{
    self.showingN += howMany;
}

- (instancetype)initWithConversationIndex:(NSIndexPath *)conversationIndex
{
    self = [super init];
    if (self) {
        self.childs = [[TSLinkedList alloc] init];
        self.conversationIndex = conversationIndex;
        self.showingN = 3;
        self.isReplyable = YES;
    }
    return self;
}

- (void)addChild:(ConversationItem *)item{
    item.parent = self;
    [self.childs addItem:item];
}

- (void)removeChild:(ConversationItem *)item{
    if(item.parent != self)
        return;
    item.parent = nil;
    [self.childs removeItem:item];
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
