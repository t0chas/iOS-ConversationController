//
//  ConversationItem.m
//  ConversationControllerTest
//
//  Created by Alejandro Santiago on 12/28/16.
//  Copyright © 2016 Alejandro Santiago. All rights reserved.
//

#import "ConversationItem.h"

@interface ConversationItem ()

@property (nonatomic, assign) NSInteger showingN;

@end

@implementation ConversationItem

-(void)showMore:(NSInteger)howMany{
    self.showingN += howMany;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.showingN = 3;
        self.isReplyable = YES;
    }
    return self;
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
