//
//  RPNetworkUtil.m
//  EatAndGo
//
//  Created by Kenji on 28/3/15.
//  Copyright (c) 2015 EatAndGo. All rights reserved.
//

#import "RPNetworkUtil.h"

#define BASE_URL @"http://10.13.112.244/respay/index.php/respay/"

@interface RPNetworkUtil()

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;

@end

@implementation RPNetworkUtil

+ (id)sharedInstance {
    static RPNetworkUtil *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[RPNetworkUtil alloc] init];
        instance.manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
        instance.manager.responseSerializer.acceptableContentTypes = [instance.manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
        ((AFJSONResponseSerializer *)instance.manager.responseSerializer).readingOptions = NSJSONReadingAllowFragments;
        
    });
    return instance;
}

- (void)getFoodsWithCompletion:(RPCompletionBlock)completionBlock {
    [self.manager GET:@"get_foods" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionBlock(operation.response, responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(operation.response, nil, error);
    }];
}

- (void)orderFood:(NSInteger)foodId table:(NSInteger)tableId quantity:(NSInteger)quantity comment:(NSString *)comment withCompletion:(RPCompletionBlock)completionBlock {
    NSDictionary *params = @{@"food_id" : @(foodId), @"table_id" : @(tableId), @"quantity" : @(quantity), @"comment" : comment};
    [self.manager POST:@"order_foods" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionBlock(operation.response, responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(operation.response, nil, error);
    }];
}

- (void)viewOrdersOfTable:(NSInteger)tableId withCompletion:(RPCompletionBlock)completionBlock {
    NSDictionary *params = @{@"table_id" : @(tableId)};
    [self.manager POST:@"view_orders" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionBlock(operation.response, responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(operation.response, nil, error);
    }];
}

@end
