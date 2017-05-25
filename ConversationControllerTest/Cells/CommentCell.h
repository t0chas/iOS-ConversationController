//
//  CommentCell.h
//  ConversationControllerTest
//
//  Created by Alejandro Santiago on 12/29/16.
//  Copyright © 2016 Alejandro Santiago. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ConversationController.h"

@interface CommentCell : UITableViewCell  <ConversationTableCell>

@property (nonatomic, strong) IBOutlet UILabel* label;

@property (nonatomic, weak) ConversationController* controller;
@property (nonatomic, weak) NSIndexPath* conversationIndex;
@property (nonatomic, weak) NSIndexPath* displayIndex;

@end
