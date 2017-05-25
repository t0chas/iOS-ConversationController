//
//  ConversationController.h
//  ConversationControllerTest
//
//  Created by Alejandro Santiago on 12/28/16.
//  Copyright © 2016 Alejandro Santiago. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//#import "ConversationItemIndex.h"

@interface NSIndexPath (ConversationController)

-(NSInteger)conversationLevel;

@end

@class ConversationController;

@protocol ConversationTableCell <NSObject>

@property (nonatomic, weak) ConversationController* controller;
@property (nonatomic, weak) NSIndexPath* conversationIndex;
@property (nonatomic, weak) NSIndexPath* displayIndex;

@end

@protocol ConversationControllerDelegate <NSObject>

-(NSInteger)numRootItemsConversationController:(ConversationController*)controller;
-(NSInteger)conversationController:(ConversationController*)controller numItemsForIndex:(NSIndexPath*)conversationIndex;

-(UITableViewCell<ConversationTableCell>*)conversationController:(ConversationController*) controller expandConversationCellForConversationIndex:(NSIndexPath*)conversationIndex;

-(UITableViewCell<ConversationTableCell>*)conversationController:(ConversationController*) controller replyCellForConversationIndex:(NSIndexPath*)conversationIndex;

-(UITableViewCell<ConversationTableCell>*)conversationController:(ConversationController*) controller cellAtConversationIndex:(NSIndexPath*)conversationIndex;

@end

@interface ConversationController : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) id<ConversationControllerDelegate> delegate;
@property (nonatomic, weak) UITableView* tableView;

- (instancetype)initWithLevels:(NSInteger)levels;

-(void)expandConversationAtIndex:(NSIndexPath*)conversationIndex byNItems:(NSInteger)nItems;
-(void)conversationElementAddedAtRoot;
-(void)conversationElementAddedAtParentConversationIndex:(NSIndexPath*)conversationIndex;

@end
