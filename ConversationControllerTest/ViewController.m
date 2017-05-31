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

#include <stdlib.h>

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
    NSIndexPath* conversationIndex = [NSIndexPath indexPathWithIndex:self.comments.count -1];
    [self.conversationCntroller conversationElementAddedAtConversationIndex:conversationIndex increaseItemsShowing:NO];
}

- (void)addComment:(Comment *)comment toIndex:(NSIndexPath *)parentConversationIndex{
    Comment* parent = [self getComment:parentConversationIndex];
    [parent.replies addObject:comment];
    
    NSIndexPath* conversationIndex = [parentConversationIndex indexPathByAddingIndex:parent.replies.count -1];
    [self.conversationCntroller conversationElementAddedAtConversationIndex:conversationIndex increaseItemsShowing:YES];
}

-(void)buildConversation{
    //[self buildConversationBig];
    //[self buildConversationNormal];
    
    [self performSelector:@selector(buildConversationStream) withObject:nil afterDelay:1.0f];
}

-(NSInteger)randomMin:(NSInteger)min max:(NSInteger)max{
    NSInteger delta = max - min;
    NSInteger r = arc4random_uniform((uint)(delta + 1));
    return min + r;
}

-(void)buildConversationBig{
    self.comments = [NSMutableArray new];
    
    Comment* comment;
    for (NSInteger i=0; i < 1000; i++) {
        NSInteger replies = [self randomMin:2 max:1000];
        comment = [self buildComment:[NSString stringWithFormat:@"Comment #%li", (long)i] nReplies:replies];
        [self.comments addObject:comment];
    }
}

-(void)buildConversationStream{
    self.comments = [NSMutableArray new];
    
    __block Comment* comment = nil;
    double delayInSeconds = 0.1;
    
    NSInteger total = 1000;
    //__block NSInteger delivered = 0;
    
    for (NSInteger i=0; i < total; i++) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //code to be executed on the main queue after delay
            NSInteger replies = [self randomMin:2 max:1000];
            comment = [self buildComment:[NSString stringWithFormat:@"Comment #%li", (long)i] nReplies:replies];
            [self.comments addObject:comment];
            
            NSLog(@"buildConversationStream delivering post #%li", (long)i);
            
            NSIndexPath* indexPath = [NSIndexPath indexPathWithIndex:i];
            [self.conversationCntroller conversationElementAddedAtConversationIndex:indexPath increaseItemsShowing:NO];
            
        });
    }
}

/*-(void)buildConversationStream{
    self.comments = [NSMutableArray new];
 
    __block Comment* comment = nil;
    double delayInSeconds = 0.1;
    
    NSInteger total = 1000;
    __block NSInteger delivered = 0;
    
    __block void (^weakBurstDispatch)() = nil;
    __block void (^burstDispatch)() = nil;
    burstDispatch = ^{
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //code to be executed on the main queue after delay
            
            NSInteger n = [self randomMin:1 max:5];;
            for (NSInteger i=0; i < n; i++) {
                NSInteger replies = [self randomMin:2 max:1000];
                comment = [self buildComment:[NSString stringWithFormat:@"Comment #%li", (long)delivered] nReplies:replies];
                [self.comments addObject:comment];
                
                NSLog(@"buildConversationStream delivering post #%li", (long)delivered);
                
                NSIndexPath* indexPath = [NSIndexPath indexPathWithIndex:delivered];
                [self.conversationCntroller conversationElementAddedAtConversationIndex:indexPath increaseItemsShowing:NO];
                delivered++;
            }
            if(delivered < total)
                weakBurstDispatch();
        });
    };
    weakBurstDispatch = burstDispatch;
    
    burstDispatch();
}*/

-(void)buildConversationNormal{
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
    NSInteger n = [self randomMin:0 max:1];
    return [self buildComment:message nReplies:nReplies hasContent:(n % 2 == 0)];
}

-(Comment*)buildComment:(NSString*)message nReplies:(NSInteger)nReplies hasContent:(BOOL)hasContent{
    Comment* comment;
    Comment* reply;
    comment = [Comment new];
    comment.message = message;
    comment.hasContent = hasContent;
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
    self.conversationCntroller.rootElementsFlow = ConversationControllerConversationFlowNewestTop;
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

- (BOOL)conversationController:(ConversationController *)controller conversationItemAtIndexHasContent:(NSIndexPath *)conversationIndex{
    Comment* comment = [self getComment:conversationIndex];
    if(comment){
        return comment.hasContent;
    }
    return NO;
}

- (UITableViewCell<ConversationTableCell> *)conversationController:(ConversationController *)controller contentCellForConversationIndex:(NSIndexPath *)conversationIndex{
    UITableViewCell<ConversationTableCell>* cell = [self.tableView dequeueReusableCellWithIdentifier:@"content"];
    //Comment* comment = [self getComment:conversationIndex];
    return cell;
}

@end
