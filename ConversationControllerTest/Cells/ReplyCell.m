//
//  ReplyCell.m
//  ConversationControllerTest
//
//  Created by Alejandro Santiago on 12/29/16.
//  Copyright © 2016 Alejandro Santiago. All rights reserved.
//

#import "ReplyCell.h"

@interface ReplyCell ()

@end

@implementation ReplyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)addComment:(id)sender{
    Comment* comment = [Comment new];
    comment.message = self.textField.text;
    [self.vc addComment:comment toIndex:self.conversationIndex];
}

@end
