//
//  CCDisplayMappingItem+Protected.h
//  ConversationControllerTest
//
//  Created by Alejandro Santiago on 5/29/17.
//  Copyright © 2017 Alejandro Santiago. All rights reserved.
//

#ifndef CCDisplayMappingItem_Protected_h
#define CCDisplayMappingItem_Protected_h

#import "CCDisplayRowMappingItem.h"
#import "CCDisplaySectionMapping.h"

@interface CCDisplayRowMappingItem (protected)

-(void)isRowMappingForSectionMapping:(CCDisplaySectionMapping*)sectionMapping atRow:(NSInteger)row;

@end

#endif /* CCDisplayMappingItem_Protected_h */
