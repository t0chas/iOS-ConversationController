//
//  ExpandCell.m
//  ConversationControllerTest
//
//  Created by Alejandro Santiago on 12/29/16.
//  Copyright © 2016 Alejandro Santiago. All rights reserved.
//

#import "ExpandCell.h"

@implementation ExpandCell

-(IBAction)expandConversation:(id)sender{
    [self.controller expandConversationAtIndex:self.conversationIndex byNItems:3];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
