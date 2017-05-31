//
//  ConversationController.m
//  ConversationControllerTest
//
//  Created by Alejandro Santiago on 12/28/16.
//  Copyright © 2016 Alejandro Santiago. All rights reserved.
//

#import "ConversationController.h"
#import "Conversation.h"
#import "ConversationItem+Protected.h"
#import "CCDisplayMapping.h"

#pragma mark NSIndexPath (ConversationController)

@implementation NSIndexPath (ConversationController)

- (NSInteger)conversationLevel{
    return self.length -1;
}

-(BOOL)isSection{
    return self.length == 1;
}

@end

#pragma mark ConversationController - internal
typedef NS_ENUM(NSInteger, CCConversationOperation) {
    CCConversationOperationUnknown,
    CCConversationOperationItemAdded,
    CCConversationOperationItemRemoved
};

@interface CCConversationChange : NSObject

@property (nonatomic, assign, readonly) CCConversationOperation operation;
@property (nonatomic, assign) BOOL completed;
@property (nonatomic, strong) NSIndexPath* conversationIndex;
@property (nonatomic, strong) ConversationItem* conversationItem;

@end

@interface CCConversationChangeItemAdded : CCConversationChange

@property (nonatomic, assign) BOOL increaseItemsShowing;

@end

@interface CCConversationChangesBuffer : NSObject

@property (atomic, strong) NSMutableArray<CCConversationChange*>* changes;

@end

@implementation CCConversationChange

@end

@implementation CCConversationChangeItemAdded

- (CCConversationOperation)operation{
    return CCConversationOperationItemAdded;
}

@end

@implementation CCConversationChangesBuffer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.changes = [NSMutableArray new];
    }
    return self;
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

@property (atomic, strong) CCConversationChangesBuffer* changesBuffer;

@end

@implementation ConversationController

- (instancetype)initWithTableView:(UITableView *)tableView levels:(NSInteger)levels
{
    self = [super init];
    if (self) {
        self.conversation = [[Conversation alloc] init];
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 1;
        
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
    
    NSBlockOperation* mappingOperation = [[NSBlockOperation alloc] init];
    __weak NSBlockOperation* weakMappingOperation = mappingOperation;
    [mappingOperation addExecutionBlock:^{
        [self collapseSectionForConversationIndex:conversationIndex currentOperation:weakMappingOperation];
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
    NSOperation* mappingOperation = [self collapseConversationOperationCompletion:^{
        [self refreshDisplay];
    }];
    [mappingOperation addDependency:structureOperation];
    
    [self.operationQueue addOperation:structureOperation];
    [self.operationQueue addOperation:mappingOperation];
}

-(void)conversationElementAddedAtConversationIndex:(NSIndexPath*)conversationIndex increaseItemsShowing:(BOOL)increaseItemsShowing{
    if(!conversationIndex)
        return;
    @synchronized (self) {
        if(self.changesBuffer && self.operationQueue.operationCount > 0){
            [self.operationQueue cancelAllOperations];
        }
        
        CCConversationChangeItemAdded* itemAdded = [[CCConversationChangeItemAdded alloc] init];
        itemAdded.conversationIndex = conversationIndex;
        itemAdded.increaseItemsShowing = increaseItemsShowing;
        
        if(!self.changesBuffer){
            self.changesBuffer = [[CCConversationChangesBuffer alloc] init];
        }
        [self.changesBuffer.changes addObject:itemAdded];
        
        [self processChangesBuffer];
    }
}

-(void)processChangesBuffer{
    if(!self.changesBuffer){
        return;
    }
    
    NSArray<CCConversationChange*>* changes = [self.changesBuffer.changes copy];
    NSBlockOperation* structureOperation = [[NSBlockOperation alloc] init];
    __weak NSBlockOperation* weakStructureOperation = structureOperation;
    [structureOperation addExecutionBlock:^{
        for (CCConversationChange* change in changes) {
            if([weakStructureOperation isCancelled])
                break;
            if(change.completed)
                continue;
            if([change isKindOfClass:[CCConversationChangeItemAdded class]]){
                CCConversationChangeItemAdded* itemAdded = (CCConversationChangeItemAdded*)change;
                itemAdded.conversationItem = [self processConversationElementAddedAtConversationIndex:itemAdded.conversationIndex increaseItemsShowing:itemAdded.increaseItemsShowing];
                itemAdded.completed = YES;
            }
        }
    }];
    
    //Reload (re-collapse) entire section mapping
    NSOperation* mappingOperation = [self collapseConversationOperationCompletion:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if(self.changesBuffer.changes.count != changes.count){
                return;
            }
            if(!self.tableView)
                return;
            
            @try {
                [self.tableView beginUpdates];
                for (CCConversationChange* change in changes) {
                    if(!change.conversationItem)
                        continue;
                    ConversationItem* item = change.conversationItem;
                    NSIndexPath* conversationIndex = item.conversationIndex;
                    if(change.operation == CCConversationOperationItemAdded){
                        if([conversationIndex isSection]){
                            NSUInteger section = [item.displayIndex indexAtPosition:0];
                            NSIndexSet* indexSet = [NSIndexSet indexSetWithIndex:section];
                            UITableViewRowAnimation rowAnimation = self.rootElementsFlow == ConversationControllerConversationFlowNewestTop? UITableViewRowAnimationAutomatic: UITableViewRowAnimationTop;
                            [self.tableView insertSections:indexSet withRowAnimation:rowAnimation];
                        }else{
                            NSArray* indexes = [item displayIndexes];
                            if(indexes && indexes.count > 0)
                                [self.tableView insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationTop];
                        }
                    }
                }
                [self.tableView endUpdates];
            } @catch (NSException *exception) {
                NSLog(@"processChangesBuffer Exception:\n%@\n\n%@\n-------------------------------", exception, exception.callStackSymbols);
            } @finally {
                self.changesBuffer = nil;
            }
        }];
    }];
    [mappingOperation addDependency:structureOperation];
    
    [self.operationQueue addOperation:structureOperation];
    [self.operationQueue addOperation:mappingOperation];
}

-(ConversationItem*)processConversationElementAddedAtConversationIndex:(NSIndexPath*)conversationIndex increaseItemsShowing:(BOOL)increaseItemsShowing{
    ConversationItem* item = [self loadItemAtIndex:conversationIndex];
    @synchronized (self.conversation) {
        [self.conversation insertItem:item atConversationIndex:conversationIndex];
        
        if(increaseItemsShowing && item.parent){
            ConversationItem* parent = item.parent;
            [parent showMore:1];
        }
    }
    return item;
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
    return [self collapseConversationOperationCompletion:nil];
}

-(NSOperation*)collapseConversationOperationCompletion:(void(^)())completion{
    NSBlockOperation* collapseOperation = [[NSBlockOperation alloc] init];
    [collapseOperation addExecutionBlock:^{
        if(!self.displayMapping){
            self.displayMapping = [[CCDisplayMapping alloc] init];
        }
        [self.displayMapping clear];
        NSOperation* collapseSectionsOperation = [self collapseConversation:self.conversation intoDisplayMapping:self.displayMapping];
        __weak NSOperation* weakCollapseSectionsOperation = collapseSectionsOperation;
        [collapseSectionsOperation setCompletionBlock:^{
            if([weakCollapseSectionsOperation isCancelled])
                return;
            if(completion)
                completion();
        }];
        [self.operationQueue addOperation:collapseSectionsOperation];
    }];
    return collapseOperation;
}

-(NSOperation*)collapseConversation:(Conversation*)conversation intoDisplayMapping:(CCDisplayMapping*)displayMapping{
    if(!conversation)
        return nil;
    if(!displayMapping)
        return nil;
    
    NSBlockOperation* collapseOperation = [[NSBlockOperation alloc] init];
    __weak NSBlockOperation* weakCollapseOperation = collapseOperation;
    //[collapseOperation addExecutionBlock:^{
        
    for (NSInteger i =0; i< conversation.count; i++) {
            ConversationItem* item = [conversation itemAtIndex:i];
            NSInteger section = [self sectionNumberForConversationIndex:item.conversationIndex];
            CCDisplaySectionMapping* sectionMapping = [[CCDisplaySectionMapping alloc] initWithSection:section];
            [displayMapping insertSectionMapping:sectionMapping atIndex:i];
            [collapseOperation addExecutionBlock:^{
                [self collapseSectionForConversationIndex:item.conversationIndex currentOperation:weakCollapseOperation];
            }];
    }
        
    //}];
    return collapseOperation;
}

-(void)collapseSectionForConversationIndex:(NSIndexPath*)conversationIndex currentOperation:(__weak NSOperation*)currentOperation
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
    [self collapseConversationItem:rootConversationItem intoSectionMapping:sectionMapping currentOperation:currentOperation];
}

-(NSArray<NSIndexPath*>*)collapseConversationItem:(ConversationItem*)conversationItem intoSectionMapping:(CCDisplaySectionMapping*)sectionMapping currentOperation:(__weak NSOperation*)currentOperation{
    if(!conversationItem)
        return nil;
    if(!sectionMapping)
        return nil;
    if(currentOperation && [currentOperation isCancelled])
        return nil;
    NSMutableArray<NSIndexPath*>* displayIndexes = [[NSMutableArray alloc] init];
    
    CCDisplayRowMappingItem* rowMappingItem = [CCDisplayRowMappingItem mappingItemForConversationIndex:conversationItem.conversationIndex];
    NSInteger row = sectionMapping.count;
    [sectionMapping insertRowMapping:rowMappingItem atRow:row];
    conversationItem.displayIndex = rowMappingItem.displayIndex;
    [displayIndexes addObject:conversationItem.displayIndex];
    
    NSInteger level = conversationItem.conversationLevel;
    
    if(conversationItem.hasChilds){
        if(!conversationItem.isExpanded){
            CCDisplayRowMappingItem* expandItem = [CCDisplayRowMappingItem expandMappingItemForConversationIndex:conversationItem.conversationIndex];
            row = sectionMapping.count;
            [sectionMapping insertRowMapping:expandItem atRow:row];
            conversationItem.displayExpandIndex = expandItem.displayIndex;
            [displayIndexes addObject:expandItem.displayIndex];
        }
        if(conversationItem.showingN > 0){
            NSInteger maxItems = MIN(conversationItem.showingN, conversationItem.childCount);
            NSInteger base = conversationItem.childCount - maxItems;
            
            NSMutableArray<NSIndexPath*>* allChildIndexes = [[NSMutableArray alloc] init];
            
            for (NSUInteger i = 0; i < maxItems; i++) {
                NSInteger childIdx = base + i;
                ConversationItem* childItem = [conversationItem itemAtIndex:childIdx];
                NSArray<NSIndexPath*>* childIndexes = [self collapseConversationItem:childItem intoSectionMapping:sectionMapping currentOperation:currentOperation];
                [allChildIndexes addObjectsFromArray:childIndexes];
            }
            
            conversationItem.displayChildIndexes = allChildIndexes;
            if(allChildIndexes.count > 0)
                [displayIndexes addObjectsFromArray:allChildIndexes];
        }
    }
    
#if DEBUG
    //NSLog(@"item: %@ isReplyable: %li", conversationItem.conversationIndex, (long)conversationItem.isReplyable);
#endif
    if(conversationItem.isReplyable && level < self.levels -1){
        CCDisplayRowMappingItem* replyItem = [CCDisplayRowMappingItem replyMappingItemForConversationIndex:conversationItem.conversationIndex];
        row = sectionMapping.count;
        [sectionMapping insertRowMapping:replyItem atRow:row];
        conversationItem.displayReplyIndex = replyItem.displayIndex;
        [displayIndexes addObject:replyItem.displayIndex];
    }
    return displayIndexes;
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

-(void)refreshDisplay{
    
    void(^reloadTable)() = ^{
        if(!self.tableView)
            return;
        [self.tableView reloadData];
    };
    
    NSOperationQueue* currentQueue = [NSOperationQueue currentQueue];
    NSOperationQueue* mainQueue = [NSOperationQueue mainQueue];
    if([mainQueue isEqual:currentQueue]){
        reloadTable();
    }else{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            reloadTable();
        }];
    }
}

-(void)refreshDisplayAtConversationIndex:(NSIndexPath*)conversationIndex{
    CCDisplayRowMappingItem* item = [self mappingFromConversationIndex:conversationIndex];
    if(!item)
        return;
    if(!item.displayIndex)
        return;
    
    void(^reloadTable)() = ^{
#warning might need to reload other dependent cells (reply, expand and so on)
        if(!self.tableView)
            return;
        [self.tableView reloadRowsAtIndexPaths:@[item.displayIndex] withRowAnimation:UITableViewRowAnimationFade];
    };
    
    NSOperationQueue* currentQueue = [NSOperationQueue currentQueue];
    NSOperationQueue* mainQueue = [NSOperationQueue mainQueue];
    if([mainQueue isEqual:currentQueue]){
        reloadTable();
    }else{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            reloadTable();
        }];
    }
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(!self.delegate)
        return 0;
    if(!self.displayMapping)
        return 0;
#if DEBUG
    NSLog(@"ConversationController numberOfSectionsInTableView: %li", self.displayMapping.count);
#endif
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
#if DEBUG
    NSLog(@"ConversationController numberOfSectionsInTableView: %li", sectionMapping.count);
#endif
    return sectionMapping.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CCDisplayRowMappingItem* item = [self mappingFromDisplayIndex:indexPath];
    if(!item)
        return [[UITableViewCell alloc] init];
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
        if(!item)
            continue;
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
