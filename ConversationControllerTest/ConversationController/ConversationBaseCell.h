//
//  ConversationBaseCell.h
//  ConversationControllerTest
//
//  Created by Alejandro Santiago on 12/28/16.
//  Copyright © 2016 Alejandro Santiago. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ConversationController.h"

@interface ConversationBaseCell : UITableViewCell <ConversationTableCell>

@property (nonatomic, weak) ConversationController* controller;
@property (nonatomic, weak) NSIndexPath* conversationIndex;
@property (nonatomic, weak) NSIndexPath* displayIndex;

@end
