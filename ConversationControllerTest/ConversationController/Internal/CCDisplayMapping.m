//
//  CCDisplayMapping.m
//  ConversationControllerTest
//
//  Created by Alejandro Santiago on 5/29/17.
//  Copyright © 2017 Alejandro Santiago. All rights reserved.
//

#import "CCDisplayMapping.h"
//#import "TSLinkedList.h"
#import "CCDisplaySectionMapping.h"

@interface CCDisplayMapping ()

//@property (nonatomic, strong) TSLinkedList* childs; //sections
@property (nonatomic, strong) NSMutableArray<CCDisplaySectionMapping*>* childs; //sections

@end

@implementation CCDisplayMapping

- (NSInteger)count{
    if(!self.childs)
        return 0;
    return self.childs.count;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //self.childs = [[TSLinkedList alloc] init];
        self.childs = [NSMutableArray new];
    }
    return self;
}

- (void)dealloc{
    [self clear];
    self.childs = nil;
}

-(void)addSectionMapping:(CCDisplaySectionMapping*)sectionMapping{
    if(!self.childs)
        return;
    //sectionMapping.parent = self;
    @synchronized (self) {
        [self.childs addObject:sectionMapping];
    }
}

- (void)insertSectionMapping:(CCDisplaySectionMapping *)sectionMapping atIndex:(NSUInteger)index{
    if(!self.childs)
        return;
    //sectionMapping.parent = self;
    @synchronized (self) {
        [self.childs insertObject:sectionMapping atIndex:index];
    }
#warning TODO setDirty
}

- (CCDisplaySectionMapping *)sectionMappingAtIndex:(NSInteger)index{
    CCDisplaySectionMapping* sectionMapping = nil;
    @synchronized (self) {
        if(!self.childs)
            return nil;
        if(index >= self.childs.count)
            return nil;
        sectionMapping = (CCDisplaySectionMapping*)[self.childs objectAtIndex:index];
    }
    return sectionMapping;
}

-(void)clear{
    if(self.childs)
        [self.childs removeAllObjects];
}

@end
