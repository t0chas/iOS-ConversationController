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

@property (nonatomic, weak) UITableView* tableView;
@property (nonatomic, assign) NSInteger levels;

@property (nonatomic, strong) Conversation* conversation;

@property (nonatomic, strong) CCDisplayMapping* displayMapping;

@property (nonatomic, strong) NSOperationQueue* operationQueue;

@end

@implementation ConversationController

- (instancetype)initWithTableView:(UITableView *)tableView levels:(NSInteger)levels
{
    self = [super init];
    if (self) {
        self.conversation = [[Conversation alloc] init];
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 2;
        
        self.levels = levels;
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
-(void)expandConversationAtIndex:(NSIndexPath*)conversationIndex byNItems:(NSInteger)nItems{
    NSBlockOperation* structureOperation = [NSBlockOperation blockOperationWithBlock:^{
        ConversationItem* item = [self.conversation conversationItemAtConversationIndex:conversationIndex];
        if(!item)
            return;
        [item showMore:nItems];
    }];
    
    NSBlockOperation* mappingOperation = [NSBlockOperation blockOperationWithBlock:^{
        [self collapseSectionForConversationIndex:conversationIndex];
    }];
    [mappingOperation addDependency:structureOperation];
    [mappingOperation setCompletionBlock:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            CCDisplaySectionMapping* sectionMapping = nil;
            sectionMapping = [self sectionMappingForConversationIndex:conversationIndex];
            if(!sectionMapping)
                return;
            if(!self.tableView)
                return;
            NSIndexSet* indexSet = [NSIndexSet indexSetWithIndex:sectionMapping.section];
            @try {
                [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
            } @catch (NSException *exception) {
                NSLog(@"%@", exception);
            } @finally {

            }
        }];//*/
    }];
    [self.operationQueue addOperation:structureOperation];
    [self.operationQueue addOperation:mappingOperation];
}

#pragma mark Conversation tree structure
-(void)loadConversation{
    if(!self.delegate)
        return;
    NSBlockOperation* structureOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSInteger rootItemCount = [self.delegate numRootItemsConversationController:self];
        NSIndexPath* conversationIndex = [[NSIndexPath alloc] init];
        
        NSIndexPath* childConversationIndex = nil;
        for (NSUInteger i =0; i < rootItemCount; i++) {
            childConversationIndex = [conversationIndex indexPathByAddingIndex:i];
            ConversationItem* child = [self loadItemAtIndex:childConversationIndex];
            @synchronized (self.conversation) {
                [self.conversation addChild:child];
            }
        }
    }];
    NSOperation* mappingOperation = [self collapseConversationOperation];
    [mappingOperation addDependency:structureOperation];
    
    [self.operationQueue addOperation:structureOperation];
    [self.operationQueue addOperation:mappingOperation];
}

/*-(void)conversationElementAddedAtRoot{
    NSUInteger count = 0;
    @synchronized (self.conversation) {
        count = self.conversation.count;
    }
    NSIndexPath* conversationIndex = [[NSIndexPath alloc] initWithIndex:count];
    [self conversationElementAddedAtConversationIndex:conversationIndex];
}*/

-(void)conversationElementAddedAtConversationIndex:(NSIndexPath*)conversationIndex increaseItemsShowing:(BOOL)increaseItemsShowing{
    if(!conversationIndex)
        return;
    NSBlockOperation* structureOperation = [NSBlockOperation blockOperationWithBlock:^{
        ConversationItem* item = [self loadItemAtIndex:conversationIndex];
        @synchronized (self.conversation) {
            [self.conversation insertItem:item atConversationIndex:conversationIndex];
            
            if(increaseItemsShowing && item.parent){
                ConversationItem* parent = item.parent;
                [parent showMore:1];
            }
        }
    }];
    
    //Reload (re-collapse) entire section mapping
    NSOperation* mappingOperation = [self collapseConversationOperation];
    [mappingOperation addDependency:structureOperation];
    
    [self.operationQueue addOperation:structureOperation];
    [self.operationQueue addOperation:mappingOperation];
}

-(ConversationItem*)loadItemAtIndex:(NSIndexPath*)conversationIndex{
    if(!self.delegate)
        return nil;
    ConversationItem* item = [[ConversationItem alloc] initWithConversationIndex:conversationIndex];
    
    if([self.delegate respondsToSelector:@selector(conversationController:canReplyToConversationItemAtIndex:)]){
        item.isReplyable = [self.delegate conversationController:self canReplyToConversationItemAtIndex:item.conversationIndex];
    }
    
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

#pragma mark helper functions
-(NSInteger)sectionNumberForConversationIndex:(NSIndexPath*)conversationIndex{
    if(!conversationIndex || conversationIndex.length == 0)
        return -1;
    NSInteger rootIdx = [conversationIndex indexAtPosition:0];
    NSInteger section = 0;
    
    if(self.rootElementsFlow == ConversationControllerConversationFlowDefault){
        section = rootIdx;
    }else{
        NSInteger rootCount = 0;
        @synchronized (self.conversation) {
            rootCount = self.conversation.count;
        }
        section = rootCount - rootIdx - 1;
    }
    return section;
}

-(NSInteger)rootIndexFromSection:(NSInteger)section{
    NSInteger rootIdx = 0;
    if(self.rootElementsFlow == ConversationControllerConversationFlowDefault){
        rootIdx = section;
    }else{
        rootIdx = self.conversation.count - section - 1;
    }
    return rootIdx;
}

-(CCDisplaySectionMapping*)sectionMappingForSection:(NSInteger)section{
    NSInteger rootIdx = [self rootIndexFromSection:section];
    CCDisplaySectionMapping* sectionMapping = [self.displayMapping sectionMappingAtIndex:rootIdx];
    return sectionMapping;
}

-(CCDisplaySectionMapping*)sectionMappingForConversationIndex:(NSIndexPath*)indexPath{
    if(!indexPath)
        return nil;
    NSInteger rootIdx = [indexPath indexAtPosition:0];
    CCDisplaySectionMapping* sectionMapping = [self.displayMapping sectionMappingAtIndex:rootIdx];
    return sectionMapping;
}

-(CCDisplayRowMappingItem*)mappingFromDisplayIndex:(NSIndexPath*)displayIndex{
    if(!self.displayMapping)
        return nil;
    CCDisplaySectionMapping* sectionMapping = [self sectionMappingForSection:displayIndex.section];
    CCDisplayRowMappingItem* item = [sectionMapping rowMappingAtRow:displayIndex.row];
    return item;
}

-(CCDisplayRowMappingItem*)mappingFromConversationIndex:(NSIndexPath*)conversationIndex{
    if(!self.displayMapping)
        return nil;
    ConversationItem* item = [self.conversation conversationItemAtConversationIndex:conversationIndex];
    if(!item)
        return nil;
    if(!item.displayIndex)
        return nil;
    CCDisplayRowMappingItem* rowMapping = [self mappingFromDisplayIndex:item.displayIndex];
    return rowMapping;
}

#pragma mark Display tree structure
-(NSOperation*)collapseConversationOperation{
    NSBlockOperation* collapseOperation = [NSBlockOperation blockOperationWithBlock:^{
        if(!self.displayMapping){
            self.displayMapping = [[CCDisplayMapping alloc] init];
        }
        [self.displayMapping clear];
        NSOperation* collapseSectionsOperation = [self collapseConversation:self.conversation intoDisplayMapping:self.displayMapping];
        [self.operationQueue addOperation:collapseSectionsOperation];
        [collapseSectionsOperation waitUntilFinished];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if(!self.tableView)
                return;
            [self.tableView reloadData];
        }];
        
    }];
    return collapseOperation;
}

-(NSOperation*)collapseConversation:(Conversation*)conversation intoDisplayMapping:(CCDisplayMapping*)displayMapping{
    if(!conversation)
        return nil;
    if(!displayMapping)
        return nil;
    
    NSBlockOperation* collapseOperation = [[NSBlockOperation alloc] init];
    //[collapseOperation addExecutionBlock:^{
        
    for (NSInteger i =0; i< conversation.count; i++) {
            ConversationItem* item = [conversation itemAtIndex:i];
            NSInteger section = [self sectionNumberForConversationIndex:item.conversationIndex];
            CCDisplaySectionMapping* sectionMapping = [[CCDisplaySectionMapping alloc] initWithSection:section];
            [displayMapping insertSectionMapping:sectionMapping atIndex:i];
            [collapseOperation addExecutionBlock:^{
                [self collapseSectionForConversationIndex:item.conversationIndex];
            }];
    }
        
    //}];
    return collapseOperation;
}

-(void)collapseSectionForConversationIndex:(NSIndexPath*)conversationIndex
{
    NSInteger rootIdx = [conversationIndex indexAtPosition:0];
    NSIndexPath* rootConversationIndex = [NSIndexPath indexPathWithIndex:rootIdx];
    CCDisplaySectionMapping* sectionMapping = nil;
    sectionMapping = [self sectionMappingForConversationIndex:conversationIndex];
    if(!sectionMapping){   
        NSInteger section = [self sectionNumberForConversationIndex:conversationIndex];
        sectionMapping = [[CCDisplaySectionMapping alloc] initWithSection:section];
        [self.displayMapping insertSectionMapping:sectionMapping atIndex:rootIdx];
    }
    [sectionMapping clear];
    ConversationItem* rootConversationItem = [self.conversation conversationItemAtConversationIndex:rootConversationIndex];
    [self collapseConversationItem:rootConversationItem intoSectionMapping:sectionMapping];
    
    /*[[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if(!self.tableView)
            return;
        NSIndexSet* indexSet = [NSIndexSet indexSetWithIndex:sectionMapping.section];
        @try {
            [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
        } @catch (NSException *exception) {
            NSLog(@"%@", exception);
        } @finally {
            
        }
    }];//*/
}

/*-(NSOperation*)collapseConversation:(Conversation*)conversation intoDisplayMapping:(CCDisplayMapping*)displayMapping{
    if(!conversation)
        return nil;
    if(!displayMapping)
        return nil;
    
    NSBlockOperation* collapseOperation = [[NSBlockOperation alloc] init];
    for (NSInteger i =0; i< conversation.count; i++) {
        [collapseOperation addExecutionBlock:^{
            ConversationItem* item = [conversation itemAtIndex:i];
            NSInteger section = [self sectionNumberForConversationIndex:item.conversationIndex];
            CCDisplaySectionMapping* sectionMapping = [[CCDisplaySectionMapping alloc] initWithSection:section];
            [self collapseConversationItem:item intoSectionMapping:sectionMapping];
            [displayMapping insertSectionMapping:sectionMapping atIndex:i];
        }];
    }
    return collapseOperation;
}//*/

-(void)collapseConversationItem:(ConversationItem*)conversationItem intoSectionMapping:(CCDisplaySectionMapping*)sectionMapping{
    if(!conversationItem)
        return;
    if(!sectionMapping)
        return;
    
    CCDisplayRowMappingItem* rowMappingItem = [CCDisplayRowMappingItem mappingItemForConversationIndex:conversationItem.conversationIndex];
    NSInteger row = sectionMapping.count;
    [sectionMapping insertRowMapping:rowMappingItem atRow:row];
    conversationItem.displayIndex = rowMappingItem.displayIndex;
    
    NSInteger level = conversationItem.conversationLevel;
    
    if(conversationItem.hasChilds){
        if(!conversationItem.isExpanded){
            CCDisplayRowMappingItem* expandItem = [CCDisplayRowMappingItem expandMappingItemForConversationIndex:conversationItem.conversationIndex];
            row = sectionMapping.count;
            [sectionMapping insertRowMapping:expandItem atRow:row];
            conversationItem.displayExpandIndex = expandItem.displayIndex;
        }
        if(conversationItem.showingN > 0){
            NSInteger maxItems = MIN(conversationItem.showingN, conversationItem.childCount);
            NSInteger base = conversationItem.childCount - maxItems;
            for (NSUInteger i = 0; i < maxItems; i++) {
                NSInteger childIdx = base + i;
                ConversationItem* childItem = [conversationItem itemAtIndex:childIdx];
                [self collapseConversationItem:childItem intoSectionMapping:sectionMapping];
            }
        }
    }
    
#if DEBUG
    NSLog(@"item: %@ isReplyable: %li", conversationItem.conversationIndex, (long)conversationItem.isReplyable);
#endif
    if(conversationItem.isReplyable && level < self.levels -1){
        CCDisplayRowMappingItem* replyItem = [CCDisplayRowMappingItem replyMappingItemForConversationIndex:conversationItem.conversationIndex];
        row = sectionMapping.count;
        [sectionMapping insertRowMapping:replyItem atRow:row];
        conversationItem.displayReplyIndex = replyItem.displayIndex;
    }
}

#pragma mark NOT USED
//They are here just for future reference, currently we are going to opt to reload the entire mappings with multithreading fashion

-(NSIndexPath*)previousConversationIndex:(NSIndexPath*)conversationIndex{
    if(!conversationIndex)
        return nil;
    NSInteger length = conversationIndex.length;
    if(length == 0)
        return nil;
    NSUInteger lastIdx = [conversationIndex indexAtPosition:length -1];
    NSIndexPath* previousIdx = nil;
    if(lastIdx > 0){
        previousIdx = [[conversationIndex indexPathByRemovingLastIndex] indexPathByAddingIndex:lastIdx -1];
        return previousIdx;
    }else{
        previousIdx = [conversationIndex indexPathByRemovingLastIndex];
    }
    return previousIdx;
}

#pragma mark Display methods
-(void)processCell:(UITableViewCell<ConversationTableCell>*)cell withConversationMappingItem:(CCDisplayRowMappingItem*)rowMappingItem{
    cell.controller = self;
    cell.conversationIndex = rowMappingItem.conversationIndex;
    cell.displayIndex = rowMappingItem.displayIndex;
}

-(void)refreshDisplayAtConversationIndex:(NSIndexPath*)conversationIndex{
    CCDisplayRowMappingItem* item = [self mappingFromConversationIndex:conversationIndex];
    if(!item)
        return;
    if(!item.displayIndex)
        return;
#warning might need to reload other dependent cells (reply, expand and so on)
    if(!self.tableView)
        return;
    [self.tableView reloadRowsAtIndexPaths:@[item.displayIndex] withRowAnimation:UITableViewRowAnimationFade];
}

/*

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
 */

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
    CCDisplaySectionMapping* sectionMapping = [self sectionMappingForSection:section];
    if(!sectionMapping)
        return 0;
    return sectionMapping.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CCDisplayRowMappingItem* item = [self mappingFromDisplayIndex:indexPath];
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
        CCDisplayRowMappingItem* item = [self mappingFromDisplayIndex:indexPath];
        [self.delegate conversationController:self prefetchDataForConversationIndex:item.conversationIndex isReply:item.isReplyToConversationCell isExpandConversation:item.isExpandConversationCell];
    }
}

#pragma mark UITableViewDelegate

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //return UITableViewAutomaticDimension;
//}

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
    CCDisplayRowMappingItem* item = [self mappingFromDisplayIndex:indexPath];
    if (item && self.delegate && [self.delegate respondsToSelector:@selector(conversationController:estimatedHeightForConversationIndex:)]) {
        return [self.delegate conversationController:self estimatedHeightForConversationIndex:item.conversationIndex];
    }
    if(self.tableView.estimatedRowHeight > 0)
        return self.tableView.estimatedRowHeight;
    return 44.0f;
}

@end
