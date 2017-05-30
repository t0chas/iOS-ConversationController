//
//  CCDisplaySectionMapping.m
//  ConversationControllerTest
//
//  Created by Alejandro Santiago on 5/29/17.
//  Copyright © 2017 Alejandro Santiago. All rights reserved.
//

#import "CCDisplaySectionMapping.h"
//#import "TSLinkedList.h"
#import "CCDisplayRowMappingItem+Protected.h"

@interface CCDisplaySectionMapping () //sections

@property (nonatomic, assign) NSInteger section;

//@property (nonatomic, strong) TSLinkedList* childs; //rows
@property (nonatomic, strong) NSMutableArray<CCDisplayRowMappingItem*>* childs; //rows

@end

@implementation CCDisplaySectionMapping

- (NSInteger)count{
    if(!self.childs)
        return 0;
    return self.childs.count;
}

- (instancetype)initWithSection:(NSInteger)section
{
    self = [super init];
    if (self) {
        self.section = section;
        //self.childs = [[TSLinkedList alloc] init];
        self.childs = [NSMutableArray new];
    }
    return self;
}

- (void)dealloc{
    [self clear];
    self.childs = nil;
}

- (void)insertRowMapping:(CCDisplayRowMappingItem *)rowMapping atRow:(NSInteger)row{
    if(!rowMapping)
        return;
    //[self.childs insertItem:rowMapping atIndex:row];
    [self.childs insertObject:rowMapping atIndex:row];
    [rowMapping isRowMappingForSectionMapping:self atRow:row];
}

-(CCDisplayRowMappingItem*)rowMappingAtRow:(NSInteger)row{
    CCDisplayRowMappingItem* rowMapping = (CCDisplayRowMappingItem*)[self.childs objectAtIndex:row];
    return rowMapping;
}

- (void)clear{
    if(self.childs)
        [self.childs removeAllObjects];
}

@end
