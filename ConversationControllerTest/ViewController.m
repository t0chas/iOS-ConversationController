//
//  ViewController.m
//  ConversationControllerTest
//
//  Created by Alejandro Santiago on 12/28/16.
//  Copyright © 2016 Alejandro Santiago. All rights reserved.
//

#import "ViewController.h"

#import "ConversationController.h"
#import "ReplyCell.h"
#import "CommentCell.h"
#import "ExpandCell.h"

@implementation Comment

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.replies = [NSMutableArray new];
    }
    return self;
}

@end

@interface ViewController () <ConversationControllerDelegate>

@property(nonatomic,strong) ConversationController* conversationCntroller;
@property(nonatomic, strong) IBOutlet UITableView* tableView;

@property (nonatomic, strong) NSMutableArray<Comment*>* comments;

@property (weak, nonatomic) IBOutlet UITextField *txtNewComment;

- (IBAction)addComment:(id)sender;


@end

@implementation ViewController

- (IBAction)addComment:(id)sender{
    Comment* newComment = [Comment new];
    newComment.message = self.txtNewComment.text;
    [self.comments addObject:newComment];
    [self.conversationCntroller conversationElementAddedAtRoot];
}

- (void)addComment:(Comment *)comment toIndex:(NSIndexPath *)parentConversationIndex{
    Comment* parent = [self getComment:parentConversationIndex];
    [parent.replies addObject:comment];
    [self.conversationCntroller conversationElementAddedAtParentConversationIndex:parentConversationIndex];
}

-(void)buildConversation{
    self.comments = [NSMutableArray new];
    
    Comment* comment;
    Comment* reply;
    /*
    comment = [Comment new];
    comment.message = @"Root 1";
    [self.comments addObject:comment];
    
    reply = [Comment new];
    reply.message = @"reply 1";
    [comment.replies addObject:reply];
    reply = [Comment new];
    reply.message = @"reply 2";
    [comment.replies addObject:reply];
    reply = [Comment new];
    reply.message = @"reply 3";
    [comment.replies addObject:reply];
    reply = [Comment new];
    reply.message = @"reply 4";
    [comment.replies addObject:reply];
    reply = [Comment new];
    reply.message = @"reply 5";
    [comment.replies addObject:reply];
    
    comment = [Comment new];
    comment.message = @"Root 2";
    [self.comments addObject:comment];
    
    reply = [Comment new];
    reply.message = @"reply 1";
    [comment.replies addObject:reply];*/
    
    comment = [self buildComment:@"Root 1" nReplies:5];
    [self.comments addObject:comment];
    
    comment = [self buildComment:@"Root 2" nReplies:1];
    [self.comments addObject:comment];
    
    comment = [self buildComment:@"Root 3" nReplies:0];
    [self.comments addObject:comment];
    
    comment = [self buildComment:@"Comment 1" nReplies:20];
    [self.comments addObject:comment];
    
    comment = [self buildComment:@"Comment 2" nReplies:3];
    [self.comments addObject:comment];
}

-(Comment*)buildComment:(NSString*)message nReplies:(NSInteger)nReplies{
    Comment* comment;
    Comment* reply;
    comment = [Comment new];
    comment.message = message;
    for(int i=0; i< nReplies; i++){
        reply = [Comment new];
        reply.message = [NSString stringWithFormat:@"\t %@ - reply %d", comment.message, i];
        [comment.replies addObject:reply];
    }
    return comment;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildConversation];
    self.conversationCntroller = [[ConversationController alloc] initWithTableView:self.tableView levels:2];
    self.conversationCntroller.delegate = self;
}


- (void)viewWillAppear:(BOOL)animated{
    //[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ConversationControllerDelegate

-(NSInteger)numRootItemsConversationController:(ConversationController*)controller{
    return self.comments.count;
}

-(Comment*)getComment:(NSIndexPath*)conversationIndex{
    NSArray<Comment*>* comments = self.comments;
    Comment* comment;
    for(int i=0; i< conversationIndex.length; i++){
        NSInteger idx = [conversationIndex indexAtPosition:i];
        comment = [comments objectAtIndex:idx];
        comments = comment.replies;
    }
    return comment;
}

-(NSInteger)conversationController:(ConversationController*)controller numItemsForIndex:(NSIndexPath*)conversationIndex{
    NSArray<Comment*>* comments = self.comments;
    Comment* comment;
    for(int i=0; i< conversationIndex.length; i++){
        NSInteger idx = [conversationIndex indexAtPosition:i];
        comment = [comments objectAtIndex:idx];
        comments = comment.replies;
    }
    if(comments)
        return comments.count;
    return 0;
}

-(UITableViewCell<ConversationTableCell>*)conversationController:(ConversationController*) controller expandConversationCellForConversationIndex:(NSIndexPath*)conversationIndex{
    UITableViewCell<ConversationTableCell>* cell = [self.tableView dequeueReusableCellWithIdentifier:@"expand"];
    return cell;
}

-(UITableViewCell<ConversationTableCell>*)conversationController:(ConversationController*) controller replyCellForConversationIndex:(NSIndexPath*)conversationIndex{
    Comment* comment = [self getComment:conversationIndex];
    ReplyCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"reply"];
    cell.vc = self;
    cell.textField.text = [NSString stringWithFormat:@"Reply to %@", comment.message];
    return cell;
}

-(UITableViewCell<ConversationTableCell>*)conversationController:(ConversationController*) controller cellAtConversationIndex:(NSIndexPath*)conversationIndex{
    UITableViewCell<ConversationTableCell>* cell = [self.tableView dequeueReusableCellWithIdentifier:@"level1"];
    Comment* comment = [self getComment:conversationIndex];
    cell.textLabel.text = comment.message;
    return cell;
}

@end
