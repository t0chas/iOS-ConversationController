//
//  TSLinkedListItem.h
//  ConversationControllerTest
//
//  Created by Alejandro Santiago on 5/26/17.
//  Copyright © 2017 Alejandro Santiago. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSLinkedListItem : NSObject

@property (nonatomic, strong) TSLinkedListItem* prev;
@property (nonatomic, strong) TSLinkedListItem* next;

@end
