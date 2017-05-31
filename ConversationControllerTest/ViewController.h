//
//  ViewController.h
//  ConversationControllerTest
//
//  Created by Alejandro Santiago on 12/28/16.
//  Copyright © 2016 Alejandro Santiago. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Comment : NSObject

@property (nonatomic, strong) NSString* message;
@property (nonatomic, assign) BOOL hasContent;
@property (nonatomic, strong) NSMutableArray<Comment*>* replies;

@end

@interface ViewController : UIViewController

- (void)addComment:(Comment *)comment toIndex:(NSIndexPath *)parentConversationIndex;

@end

