//
//  CCDisplayMapping.m
//  ConversationControllerTest
//
//  Created by Alejandro Santiago on 5/29/17.
//  Copyright © 2017 Alejandro Santiago. All rights reserved.
//

#import "CCDisplayMapping.h"
#import "TSLinkedList.h"

@interface CCDisplayMapping ()

@property (nonatomic, strong) TSLinkedList* childs; //sections

@end

@implementation CCDisplayMapping

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.childs = [[TSLinkedList alloc] init];
    }
    return self;
}

@end
