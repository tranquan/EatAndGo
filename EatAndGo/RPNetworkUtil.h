//
//  RPNetworkUtil.h
//  EatAndGo
//
//  Created by Kenji on 28/3/15.
//  Copyright (c) 2015 EatAndGo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface RPNetworkUtil : NSObject

typedef void (^RPCompletionBlock)(NSHTTPURLResponse *response, id data, NSError *error);

+ (id)sharedInstance;

- (void)getFoodsWithCompletion:(RPCompletionBlock)completionBlock;

- (void)orderFood:(NSInteger)foodId table:(NSInteger)tableId quantity:(NSInteger)quantity comment:(NSString *)comment withCompletion:(RPCompletionBlock)completionBlock;

- (void)viewOrdersOfTable:(NSInteger)tableId withCompletion:(RPCompletionBlock)completionBlock;

@end
