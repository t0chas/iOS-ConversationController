//
//  ReplyCell.h
//  ConversationControllerTest
//
//  Created by Alejandro Santiago on 12/29/16.
//  Copyright © 2016 Alejandro Santiago. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ViewController.h"
#import "ConversationController.h"

@interface ReplyCell : UITableViewCell <ConversationTableCell>

@property (nonatomic, weak) ViewController* vc;

@property (nonatomic, strong) IBOutlet UITextField* textField;

@property (nonatomic, weak) ConversationController* controller;
@property (nonatomic, weak) NSIndexPath* conversationIndex;
@property (nonatomic, weak) NSIndexPath* displayIndex;

@end
