//
//  ConversationController.m
//  ConversationControllerTest
//
//  Created by Alejandro Santiago on 12/28/16.
//  Copyright © 2016 Alejandro Santiago. All rights reserved.
//

#import "ConversationController.h"
#import "Conversation.h"
#import "ConversationItem.h"
#import "CCDisplayMapping.h"

#pragma mark NSIndexPath (ConversationController)

@implementation NSIndexPath (ConversationController)

- (NSInteger)conversationLevel{
    return self.length -1;
}

@end

#pragma mark ConversationController
//ConversationDisplayMapping - section
//  ConversationDisplayMappingItem - rows
@interface ConversationController ()

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, assign) NSInteger levels;

@property (nonatomic, strong) Conversation* conversation;

@property (nonatomic, strong) NSMutableArray<ConversationItem*>* rootLevel;
@property (nonatomic, strong) CCDisplayMapping* displayMapping;

@end

@implementation ConversationController

- (instancetype)initWithTableView:(UITableView *)tableView levels:(NSInteger)levels
{
    self = [super init];
    if (self) {
        self.conversation = [[Conversation alloc] init];
        self.levels = levels;
        self.rootLevel = [NSMutableArray new];
        self.tableView = tableView;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.prefetchDataSource = self;
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

#pragma mark public methods

#pragma mark Conversation tree structure
-(void)loadConversation{
    if(!self.delegate)
        return;
    NSInteger rootItemCount = [self.delegate numRootItemsConversationController:self];
    NSIndexPath* conversationIndex = [[NSIndexPath alloc] init];
    
    NSIndexPath* childConversationIndex = nil;
    for (NSUInteger i =0; i < rootItemCount; i++) {
        childConversationIndex = [conversationIndex indexPathByAddingIndex:i];
        ConversationItem* child = [self loadItemAtIndex:childConversationIndex];
        [self.conversation addChild:child];
    }
    [self collapseConversation];
}

-(void)conversationElementAddedAtRoot{
    NSUInteger count = self.conversation.count;
    NSIndexPath* conversationIndex = [[NSIndexPath alloc] initWithIndex:count];
    [self conversationElementAddedAtParentConversationIndex:conversationIndex];
}

-(void)conversationElementAddedAtParentConversationIndex:(NSIndexPath*)conversationIndex{
    if(!conversationIndex)
        return;
    ConversationItem* item = [self loadItemAtIndex:conversationIndex];
    [self.conversation insertItem:item atConversationIndex:conversationIndex];
}

-(ConversationItem*)loadItemAtIndex:(NSIndexPath*)conversationIndex{
    if(!self.delegate)
        return nil;
    ConversationItem* item = [[ConversationItem alloc] initWithConversationIndex:conversationIndex];
    
    NSInteger level = [conversationIndex conversationLevel];
    if(level < self.levels -1){
        NSInteger childCount = [self.delegate conversationController:self numItemsForIndex:conversationIndex];
        NSIndexPath* childConversationIndex = nil;
        for (NSUInteger i =0; i < childCount; i++) {
            childConversationIndex = [conversationIndex indexPathByAddingIndex:i];
            ConversationItem* child = [self loadItemAtIndex:childConversationIndex];
            [item addChild:child];
        }
    }
    return item;
}


#pragma mark Display tree structure
-(void)collapseConversation{
    /*self.displayMapping = [NSMutableArray new];
    for(int i=0; i< self.rootLevel.count; i++){
        ConversationItem* rootItem = [self rootItemForSection:i];
        NSMutableArray<ConversationMappingItem*>* sectionMapping = [NSMutableArray new];
        [self collapseConversationItem:rootItem section:i sectionMapping:sectionMapping];
        [self.displayMapping addObject:sectionMapping];
    }*/
}

/*-(void)expandConversationAtIndex:(NSIndexPath*)conversationIndex byNItems:(NSInteger)nItems{
    ConversationItem* item = [self conversationItemAtIndex:conversationIndex];
    if(!item)
        return;
    [item showMore:nItems];
    [self updateSectionMappingForIndex:conversationIndex];
    [self updateTableSectionForIndex:conversationIndex];
}

-(void)conversationElementAddedAtRoot{
    [self conversationElementAddedAtRootIndex:self.rootLevel.count];
}

-(void)conversationElementAddedAtRootIndex:(NSInteger)index{
    NSIndexPath* conversationIndex = [NSIndexPath indexPathWithIndex:index];
    ConversationItem* item = [self loadItemAtIndex:conversationIndex];
    [self.rootLevel addObject:item];
    [self.displayMapping addObject:[NSMutableArray new]];
    [self updateSectionMappingForIndex:conversationIndex];
    
    NSInteger section = [self sectionNumberForRootIndex:index];
    NSIndexSet* set = [NSIndexSet indexSetWithIndex:section];
    
    [self.tableView beginUpdates];
    [self.tableView insertSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

-(void)conversationElementAddedAtParentConversationIndex:(NSIndexPath*)conversationIndex{
    if(conversationIndex.length == 0){
        [self conversationElementAddedAtRoot];
        return;
    }
    NSIndexPath* parentIndex = [conversationIndex indexPathByRemovingLastIndex];
    ConversationItem* parentItem = [self conversationItemAtIndex:parentIndex];
    if(!parentItem)
        return;
    ConversationItem* chidlItem = [self loadItemAtIndex:conversationIndex];
    [parentItem.childs addObject:chidlItem];
    [parentItem showMore:1];
    [self updateSectionMappingForIndex:parentIndex];
    
    ConversationMappingItem* mapping = [self mappingFromConversationIndex:conversationIndex];
    if(!mapping)
        return;
    [self.tableView beginUpdates];
    NSArray* indexes = @[ mapping.displayIndex ];
    [self.tableView insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
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
    NSInteger section = [self sectionNumberForRootIndex:rootLevelIdx];
    [self collapseConversationItem:rootItem section:section sectionMapping:sectionMapping];
}

-(void)updateTableSectionForIndex:(NSIndexPath*)conversationIndex{
    NSInteger rootLevelIdx = [conversationIndex indexAtPosition:0];
    NSInteger section = [self sectionNumberForRootIndex:rootLevelIdx];
    NSInteger numOfSectionsInTable = self.tableView.numberOfSections;
    if(section >= numOfSectionsInTable)
        return;
    if(section < 0)
        return;
    NSIndexSet* set = [NSIndexSet indexSetWithIndex:section];
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

-(NSMutableArray<ConversationItem*>*)loadItemsParentIndex:(NSIndexPath*)parentIndex itemCount:(NSInteger)itemCount{
    NSMutableArray<ConversationItem*>* items = [NSMutableArray new];
    for(int i=0; i < itemCount; i++){
        NSIndexPath* converstationIndex = [parentIndex indexPathByAddingIndex:i];
        ConversationItem* item = [self loadItemAtIndex:converstationIndex];
        [items addObject:item];
    }
    return items;
}

-(NSInteger)sectionNumberForRootIndex:(NSInteger)rootIdx{
    NSInteger section = 0;
    NSInteger rootCount = self.rootLevel.count;
    if(self.rootElementsFlow == ConversationControllerConversationFlowDefault){
        section = rootIdx;
    }else{
        section = rootCount - rootIdx - 1;
    }
    return section;
}

-(NSInteger)rootIndexFromSectionNumber:(NSInteger)section{
    NSInteger rootIdx = 0;
    if(self.rootElementsFlow == ConversationControllerConversationFlowDefault){
        rootIdx = section;
    }else{
        rootIdx = self.rootLevel.count - section - 1;
    }
    return rootIdx;
}

-(ConversationItem*)rootItemForSection:(NSInteger)section{
    NSInteger rootIdx = [self rootIndexFromSectionNumber:section];
    ConversationItem* rootItem = [self.rootLevel objectAtIndex:rootIdx];
    return rootItem;
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
    if([self.delegate respondsToSelector:@selector(conversationController:canReplyToConversationItemAtIndex:)]){
        item.isReplyable = [self.delegate conversationController:self canReplyToConversationItemAtIndex:item.conversationIndex];
    }
    NSLog(@"item: %@ isReplyable: %li", item.conversationIndex, (long)item.isReplyable);
    if(item.isReplyable && level < self.levels -1){
        ConversationMappingItem* replyItem = [ConversationMappingItem mappingWithReplyConversationIndex:item.conversationIndex displayRow:sectionMapping.count displaySection:section];
        [sectionMapping addObject:replyItem];
    }
}

-(NSArray<ConversationMappingItem*>*)sectionMappingForSection:(NSInteger)section{
    NSInteger rootIdx = [self rootIndexFromSectionNumber:section];
    NSArray<ConversationMappingItem*>* sectionMapping = [self.displayMapping objectAtIndex:rootIdx];
    return sectionMapping;
}

-(ConversationMappingItem*)mappingFromDisplayIndex:(NSIndexPath*)displayIndex{
    if(!self.displayMapping)
        return nil;
    NSArray<ConversationMappingItem*>* sectionMapping = [self sectionMappingForSection:displayIndex.section];
    ConversationMappingItem* item = [sectionMapping objectAtIndex:displayIndex.row];
#warning This is a Hack due to -collapseConversationItem:section: when invocked from -updateSectionMappingForIndex: will leave the other sections with a wrong section number. a linked list with recursive section evaluation or reindexing is required.
    if(item)
        item.displayIndex = displayIndex;
    return item;
}

-(ConversationMappingItem*)mappingFromConversationIndex:(NSIndexPath*)conversationIndex{
    if(!self.displayMapping)
        return nil;
    NSInteger rootIdx = [conversationIndex indexAtPosition:0];
    NSArray<ConversationMappingItem*>* sectionMapping = [self.displayMapping objectAtIndex:rootIdx];
    for (ConversationMappingItem* item in sectionMapping) {
        if([item.conversationIndex isEqual:conversationIndex]){
            return item;
        }
    }
    return nil;
}
                                                                     

-(void)processCell:(UITableViewCell<ConversationTableCell>*)cell withConversationMappingItem:(ConversationMappingItem*)mappingItem{
    cell.controller = self;
    cell.conversationIndex = mappingItem.conversationIndex;
    cell.displayIndex = mappingItem.displayIndex;
}

-(void)refreshDisplayAtConversationIndex:(NSIndexPath*)conversationIndex{
    ConversationMappingItem* item = [self mappingFromConversationIndex:conversationIndex];
    if(!item)
        return;
    if(!item.displayIndex)
        return;
    [self.tableView reloadRowsAtIndexPaths:@[item.displayIndex] withRowAnimation:UITableViewRowAnimationFade];
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
    NSArray<ConversationMappingItem*>* sectionMapping = [self sectionMappingForSection:section];
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
    if(!cell)
        return [[UITableViewCell alloc] init];
    return cell;
}

#pragma mark UITableViewDataSourcePrefetching
- (void)tableView:(UITableView *)tableView prefetchRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths{
    if(!self.delegate)
        return;
    if(![self.delegate respondsToSelector:@selector(conversationController:prefetchDataForConversationIndex:isReply:isExpandConversation:)])
        return;
    for (NSIndexPath* indexPath in indexPaths) {
        ConversationMappingItem* item = [self mappingFromDisplayIndex:indexPath];
        [self.delegate conversationController:self prefetchDataForConversationIndex:item.conversationIndex isReply:item.isReplyToConversationCell isExpandConversation:item.isExpandConversationCell];
    }
}

#pragma mark UITableViewDelegate

/*- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewAutomaticDimension;
}*/

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if(self.delegate && [self.delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]){
        [self.delegate scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(self.delegate && [self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]){
        [self.delegate scrollViewDidScroll:scrollView];
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ConversationMappingItem* item = [self mappingFromDisplayIndex:indexPath];
    if (item && self.delegate && [self.delegate respondsToSelector:@selector(conversationController:estimatedHeightForConversationIndex:)]) {
        return [self.delegate conversationController:self estimatedHeightForConversationIndex:item.conversationIndex];
    }
    if(self.tableView.estimatedRowHeight > 0)
        return self.tableView.estimatedRowHeight;
    return 44.0f;
}

@end
