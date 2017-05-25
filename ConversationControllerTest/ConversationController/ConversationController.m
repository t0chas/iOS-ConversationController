//
//  ConversationController.m
//  ConversationControllerTest
//
//  Created by Alejandro Santiago on 12/28/16.
//  Copyright © 2016 Alejandro Santiago. All rights reserved.
//

#import "ConversationController.h"
#import "ConversationItem.h"

#pragma mark NSIndexPath (ConversationController)

@implementation NSIndexPath (ConversationController)

- (NSInteger)conversationLevel{
    return self.length -1;
}

@end

#pragma mark ConversationMappingItem

@interface ConversationMappingItem : NSObject

@property (nonatomic, assign, readonly) BOOL isExpandConversationCell;
@property (nonatomic, assign, readonly) BOOL isReplyToConversationCell;
@property (nonatomic, strong, readonly) NSIndexPath* conversationIndex;
@property (nonatomic, strong, readonly) NSIndexPath* displayIndex;

+(ConversationMappingItem*)mappingWithConversationIndex:(NSIndexPath*)conversationIndex displayIndex:(NSIndexPath*)displayIndex;
+(ConversationMappingItem*)mappingWithConversationIndex:(NSIndexPath*)conversationIndex displayRow:(NSInteger)row displaySection:(NSInteger)section;
+(ConversationMappingItem*)mappingWithExpandConversationIndex:(NSIndexPath*)conversationIndex  displayRow:(NSInteger)row displaySection:(NSInteger)section;
+(ConversationMappingItem*)mappingWithReplyConversationIndex:(NSIndexPath*)conversationIndex  displayRow:(NSInteger)row displaySection:(NSInteger)section;

@end

@interface ConversationMappingItem ()

@property (nonatomic, assign) BOOL isExpandConversationCell;
@property (nonatomic, assign) BOOL isReplyToConversationCell;
@property (nonatomic, strong) NSIndexPath* conversationIndex;
@property (nonatomic, strong) NSIndexPath* displayIndex;

@end

@implementation ConversationMappingItem


+ (ConversationMappingItem *)mappingWithConversationIndex:(NSIndexPath *)conversationIndex displayRow:(NSInteger)row displaySection:(NSInteger)section{
    NSIndexPath* displayIndex = [NSIndexPath indexPathForRow:row inSection:section];
    return [self mappingWithConversationIndex:conversationIndex displayIndex:displayIndex];
}

+ (ConversationMappingItem *)mappingWithConversationIndex:(NSIndexPath *)conversationIndex displayIndex:(NSIndexPath *)displayIndex{
    ConversationMappingItem* mapping = [ConversationMappingItem new];
    mapping.conversationIndex = conversationIndex;
    mapping.displayIndex = displayIndex;
    return mapping;
}

+ (ConversationMappingItem *)mappingWithExpandConversationIndex:(NSIndexPath *)conversationIndex displayRow:(NSInteger)row displaySection:(NSInteger)section{
    ConversationMappingItem* mapping = [self mappingWithConversationIndex:conversationIndex displayRow:row displaySection:section];
    mapping.isExpandConversationCell = YES;
    return mapping;
}

+ (ConversationMappingItem *)mappingWithReplyConversationIndex:(NSIndexPath *)conversationIndex displayRow:(NSInteger)row displaySection:(NSInteger)section{
    ConversationMappingItem* mapping = [self mappingWithConversationIndex:conversationIndex displayRow:row displaySection:section];
    mapping.isReplyToConversationCell = YES;
    return mapping;
}


@end

#pragma mark ConversationController

@interface ConversationController ()

@property (nonatomic, assign) NSInteger levels;
@property (nonatomic, strong) NSMutableArray<ConversationItem*>* rootLevel;
@property (nonatomic, strong) NSMutableArray<NSMutableArray<ConversationMappingItem*>*>* displayMapping;

@end

@implementation ConversationController

- (instancetype)initWithLevels:(NSInteger)levels
{
    self = [super init];
    if (self) {
        self.levels = levels;
        self.rootLevel = [NSMutableArray new];
    }
    return self;
}

- (void)setDelegate:(id<ConversationControllerDelegate>)delegate{
    _delegate = delegate;
    if(_delegate)
    {
        [self loadConversation];
    }
}

-(void)expandConversationAtIndex:(NSIndexPath*)conversationIndex byNItems:(NSInteger)nItems{
    ConversationItem* item = [self conversationItemAtIndex:conversationIndex];
    if(!item)
        return;
    [item showMore:nItems];
    [self updateSectionMappingForIndex:conversationIndex];
    [self updateTableSectionForIndex:conversationIndex];
}

-(void)conversationElementAddedAtRoot{
    //[self loadConversation];
    NSIndexPath* conversationIndex = [NSIndexPath indexPathWithIndex:self.rootLevel.count];
    ConversationItem* item = [self loadItemAtIndex:conversationIndex];
    [self.rootLevel addObject:item];
    [self.displayMapping addObject:[NSMutableArray new]];
    [self updateSectionMappingForIndex:conversationIndex];
    
    NSInteger rootLevelIdx = [conversationIndex indexAtPosition:0];
    NSIndexSet* set = [NSIndexSet indexSetWithIndex:rootLevelIdx];
    [self.tableView insertSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)conversationElementAddedAtParentConversationIndex:(NSIndexPath*)conversationIndex{
    if(conversationIndex.length == 0){
        [self conversationElementAddedAtRoot];
        return;
    }
    [self rebuildConversationAtIndex:conversationIndex];
}

-(void)conversationElementRemovedAtConversationIndex:(NSIndexPath*)conversationIndex{
    NSIndexPath* parentIndex = [conversationIndex indexPathByRemovingLastIndex];
    [self rebuildConversationAtIndex:parentIndex];
}

-(void)updateSectionMappingForIndex:(NSIndexPath*)conversationIndex{
    NSInteger rootLevelIdx = [conversationIndex indexAtPosition:0];
    NSMutableArray<ConversationMappingItem*>* sectionMapping = [self.displayMapping objectAtIndex:rootLevelIdx];
    [sectionMapping removeAllObjects];
    ConversationItem* rootItem = [self.rootLevel objectAtIndex:rootLevelIdx];
    [self collapseConversationItem:rootItem section:rootLevelIdx sectionMapping:sectionMapping];
}

-(void)updateTableSectionForIndex:(NSIndexPath*)conversationIndex{
    NSInteger rootLevelIdx = [conversationIndex indexAtPosition:0];
    NSInteger numOfSectionsInTable = self.tableView.numberOfSections;
    if(rootLevelIdx >= numOfSectionsInTable)
        return;
    NSIndexSet* set = [NSIndexSet indexSetWithIndex:rootLevelIdx];
    [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)rebuildConversationAtIndex:(NSIndexPath*)conversationIndex{
    ConversationItem* item = [self conversationItemAtIndex:conversationIndex];
    if(!item)
        return;
    NSInteger childCount = [self.delegate conversationController:self numItemsForIndex:conversationIndex];
    if(item.childCount == childCount)
        return;
#warning ConversationItem rebuild Cache shall use a propper ID or hash to identify elements
    NSMutableDictionary<NSIndexPath*, ConversationItem*>* cache = [NSMutableDictionary new];
    for (ConversationItem* chidlItem in item.childs) {
        [cache setObject:chidlItem forKey:chidlItem.conversationIndex];
    }
    
    [item.childs removeAllObjects];
    
    for(int i=0; i < childCount; i++){
        NSIndexPath* childIndex = [conversationIndex indexPathByAddingIndex:i];
        ConversationItem* chidlItem = [cache objectForKey:childIndex];
        if(!chidlItem){
            chidlItem = [self loadItemAtIndex:childIndex];
        }
        [item.childs addObject:chidlItem];
    }
    
    [self updateSectionMappingForIndex:conversationIndex];
    [self updateTableSectionForIndex:conversationIndex];
}

-(ConversationItem*)conversationItemAtIndex:(NSIndexPath*)conversationIndex{
    ConversationItem* item;
    NSArray<ConversationItem*>* items = self.rootLevel;
    for(int i=0; i< conversationIndex.length; i++){
        item = [items objectAtIndex:[conversationIndex indexAtPosition:i]];
        items = item.childs;
    }
    return item;
}

-(void)loadConversation{
    if(!self.delegate)
        return;
    NSInteger rootItemCount = [self.delegate numRootItemsConversationController:self];
    NSIndexPath* conversationIndex = [[NSIndexPath alloc] init];
    NSMutableArray<ConversationItem*>* items = [self loadItemsParentIndex:conversationIndex itemCount:rootItemCount];
    self.rootLevel = items;
    [self collapseConversation];
}

-(NSMutableArray<ConversationItem*>*)loadItemsParentIndex:(NSIndexPath*)parentIndex itemCount:(NSInteger)itemCount{
    NSMutableArray<ConversationItem*>* items = [NSMutableArray new];
    for(int i=0; i < itemCount; i++){
        NSIndexPath* converstationIndex = [parentIndex indexPathByAddingIndex:i];
        ConversationItem* item = [self loadItemAtIndex:converstationIndex];
        [items addObject:item];
    }
    return items;
}

-(ConversationItem*)loadItemAtIndex:(NSIndexPath*)converstationIndex{
    if(!self.delegate)
        return nil;
    ConversationItem* item = [ConversationItem new];
    item.conversationIndex = converstationIndex;
    NSMutableArray<ConversationItem*>* items = [NSMutableArray new];
    NSInteger level = [converstationIndex conversationLevel];
    if(level < self.levels -1){
        NSInteger childCount = [self.delegate conversationController:self numItemsForIndex:converstationIndex];
        items = [self loadItemsParentIndex:converstationIndex itemCount:childCount];
    }
    item.childs = items;
    return item;
}

-(void)collapseConversation{
    self.displayMapping = [NSMutableArray new];
    for(int i=0; i< self.rootLevel.count; i++){
        NSMutableArray<ConversationMappingItem*>* sectionMapping = [NSMutableArray new];
        ConversationItem* rootItem = [self.rootLevel objectAtIndex:i];
        [self collapseConversationItem:rootItem section:i sectionMapping:sectionMapping];
        [self.displayMapping addObject:sectionMapping];
    }
}

-(void)collapseConversationItem:(ConversationItem*) item section:(NSInteger)section sectionMapping:(NSMutableArray<ConversationMappingItem*>*)sectionMapping{
    ConversationMappingItem* itemMapping = [ConversationMappingItem mappingWithConversationIndex:item.conversationIndex displayRow:sectionMapping.count displaySection:section];
    [sectionMapping addObject:itemMapping];
    if(item.hasChilds && item.showingN > 0){
        if(!item.isExpanded){
            ConversationMappingItem* expandItem = [ConversationMappingItem mappingWithExpandConversationIndex:item.conversationIndex displayRow:sectionMapping.count displaySection:section];
            [sectionMapping addObject:expandItem];
        }
        NSInteger maxItems = MIN(item.showingN, item.childCount);
        NSInteger base = item.childCount - maxItems;
        for(int i=0; i< maxItems; i++){
            NSInteger childIdx = base + i;
            ConversationItem* childItem = item.childs[childIdx];
            [self collapseConversationItem:childItem section:section sectionMapping:sectionMapping];
        }
    }
    NSInteger level = item.conversationLevel;
    if(level < self.levels -1){
        ConversationMappingItem* replyItem = [ConversationMappingItem mappingWithReplyConversationIndex:item.conversationIndex displayRow:sectionMapping.count displaySection:section];
        [sectionMapping addObject:replyItem];
    }
}

-(ConversationMappingItem*)mappingFromDisplayIndex:(NSIndexPath*)displayIndex{
    if(!self.displayMapping)
        return nil;
    NSArray* sectionMapping = [self.displayMapping objectAtIndex:displayIndex.section];
    ConversationMappingItem* item = [sectionMapping objectAtIndex:displayIndex.row];
    return item;
}

-(void)processCell:(UITableViewCell<ConversationTableCell>*)cell withConversationMappingItem:(ConversationMappingItem*)mappingItem{
    cell.controller = self;
    cell.conversationIndex = mappingItem.conversationIndex;
    cell.displayIndex = mappingItem.displayIndex;
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(!self.delegate)
        return 0;
    if(!self.displayMapping)
        return 0;
    return self.displayMapping.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(!self.delegate)
        return 0;
    if(!self.displayMapping)
        return 0;
    NSArray* sectionMapping = [self.displayMapping objectAtIndex:section];
    return sectionMapping.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ConversationMappingItem* item = [self mappingFromDisplayIndex:indexPath];
    UITableViewCell<ConversationTableCell>* cell;
    if(item.isExpandConversationCell){
        cell = [self.delegate conversationController:self expandConversationCellForConversationIndex:item.conversationIndex];
        [self processCell:cell withConversationMappingItem:item];
        return cell;
    }
    if(item.isReplyToConversationCell){
        cell = [self.delegate conversationController:self replyCellForConversationIndex:item.conversationIndex];
        [self processCell:cell withConversationMappingItem:item];
        return cell;
    }
    cell = [self.delegate conversationController:self cellAtConversationIndex:item.conversationIndex];
    [self processCell:cell withConversationMappingItem:item];
    return cell;
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}

@end
