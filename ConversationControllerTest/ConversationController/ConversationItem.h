//
//  ConversationItem.h
//  ConversationControllerTest
//
//  Created by Alejandro Santiago on 12/28/16.
//  Copyright © 2016 Alejandro Santiago. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConversationItem : NSObject

@property (nonatomic, strong) NSIndexPath* conversationIndex;
@property (nonatomic, strong) NSMutableArray<ConversationItem*>* childs;

@property (nonatomic, assign, readonly) NSInteger conversationLevel;

@property (nonatomic, assign, readonly) NSInteger showingN;
@property (nonatomic, assign, readonly) NSInteger childCount;
@property (nonatomic, assign, readonly) BOOL hasChilds;
@property (nonatomic, assign, readonly) BOOL isExpanded;


-(void)showMore:(NSInteger)howMany;


@end
