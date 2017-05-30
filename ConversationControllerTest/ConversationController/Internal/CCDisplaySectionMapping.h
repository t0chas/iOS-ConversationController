//
//  CCDisplaySectionMapping.h
//  ConversationControllerTest
//
//  Created by Alejandro Santiago on 5/29/17.
//  Copyright © 2017 Alejandro Santiago. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSLinkedListItem.h"
#import "CCDisplayRowMappingItem.h"

@interface CCDisplaySectionMapping : NSObject /*TSLinkedListItem*/

@property (nonatomic, assign, readonly) NSInteger section;
@property (nonatomic, assign, readonly) NSInteger count;

- (instancetype)initWithSection:(NSInteger)section;

-(void)insertRowMapping:(CCDisplayRowMappingItem*)rowMapping atRow:(NSInteger)row;

-(CCDisplayRowMappingItem*)rowMappingAtRow:(NSInteger)row;

-(void)clear;

@end
