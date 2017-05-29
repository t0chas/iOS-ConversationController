//
//  ConversationItem+Protected.h
//  ConversationControllerTest
//
//  Created by Alejandro Santiago on 5/26/17.
//  Copyright © 2017 Alejandro Santiago. All rights reserved.
//

#ifndef ConversationItem_Protected_h
#define ConversationItem_Protected_h

#import "ConversationItem.h"

@protocol ConversationTree <NSObject>

@property (nonatomic, strong) TSLinkedList* childs;

-(void)addChild:(ConversationItem*)item;
-(void)removeChild:(ConversationItem*)item;

@end

@interface ConversationItem (protected) <ConversationTree>

@property (nonatomic, strong) TSLinkedList* childs;

@end

#endif /* ConversationItem_Protected_h */
