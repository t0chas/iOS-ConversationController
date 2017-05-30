//
//  CCDisplayMapping.h
//  ConversationControllerTest
//
//  Created by Alejandro Santiago on 5/29/17.
//  Copyright © 2017 Alejandro Santiago. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCDisplaySectionMapping.h"

@interface CCDisplayMapping : NSObject

@property (nonatomic, assign, readonly) NSInteger count;

-(void)addSectionMapping:(CCDisplaySectionMapping*)sectionMapping;
-(void)insertSectionMapping:(CCDisplaySectionMapping*)sectionMapping atIndex:(NSUInteger)index;

-(CCDisplaySectionMapping*)sectionMappingAtIndex:(NSInteger)index;

-(void)clear;

@end
