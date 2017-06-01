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

typedef NS_ENUM(NSInteger, ConversationControllerConversationFlow) {
    ConversationControllerConversationFlowDefault,
    ConversationControllerConversationFlowNewestTop
};

@interface NSIndexPath (ConversationController)

-(NSInteger)conversationLevel;
-(BOOL)isSection;

@end

@class ConversationController;

@protocol ConversationTableCell <NSObject>

@property (nonatomic, weak) ConversationController* controller;
@property (nonatomic, weak) NSIndexPath* conversationIndex;
@property (nonatomic, weak) NSIndexPath* displayIndex;

@end

@protocol ConversationControllerDelegate <NSObject, UIScrollViewDelegate>

-(NSInteger)numRootItemsConversationController:(ConversationController*)controller;
-(NSInteger)conversationController:(ConversationController*)controller numItemsForIndex:(NSIndexPath*)conversationIndex;

-(UITableViewCell<ConversationTableCell>*)conversationController:(ConversationController*) controller expandConversationCellForConversationIndex:(NSIndexPath*)conversationIndex;

-(UITableViewCell<ConversationTableCell>*)conversationController:(ConversationController*) controller cellAtConversationIndex:(NSIndexPath*)conversationIndex;

@optional
-(BOOL)conversationController:(ConversationController*) controller conversationItemAtIndexHasContent:(NSIndexPath*)conversationIndex;

-(UITableViewCell<ConversationTableCell>*)conversationController:(ConversationController*) controller contentCellForConversationIndex:(NSIndexPath*)conversationIndex;

-(BOOL)conversationController:(ConversationController*) controller canReplyToConversationItemAtIndex:(NSIndexPath*)conversationIndex;

-(UITableViewCell<ConversationTableCell>*)conversationController:(ConversationController*) controller replyCellForConversationIndex:(NSIndexPath*)conversationIndex;

-(CGFloat)conversationController:(ConversationController*) controller estimatedHeightForConversationIndex:(NSIndexPath *)conversationIndex;

-(void)conversationController:(ConversationController*) controller prefetchDataForConversationIndex:(NSIndexPath*)conversationIndex isContent:(BOOL)isContent isReply:(BOOL)isReply isExpandConversation:(BOOL)isExpand;

@end

@interface ConversationController : NSObject <UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching>

@property (nonatomic, weak) id<ConversationControllerDelegate> delegate;
@property (nonatomic, weak, readonly) UITableView* tableView;
@property (nonatomic, assign) ConversationControllerConversationFlow rootElementsFlow;

- (instancetype)initWithTableView:(UITableView*)tableView levels:(NSInteger)levels;

-(void)expandConversationAtIndex:(NSIndexPath*)conversationIndex byNItems:(NSInteger)nItems;
//-(void)conversationElementAddedAtRoot;
-(void)conversationElementAddedAtConversationIndex:(NSIndexPath*)conversationIndex increaseItemsShowing:(BOOL)increaseItemsShowing;

-(void)refreshDisplayAtConversationIndex:(NSIndexPath*)conversationIndex;
-(void)refreshDisplayForContentAtConversationIndex:(NSIndexPath*)conversationIndex;

@end
