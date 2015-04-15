//
//  RPBeaconManager.h
//  BleScan
//
//  Created by Kenji on 28/3/15.
//  Copyright (c) 2015 Kenji. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RPBeaconManager;

@protocol RPBeaconManagerDelegate <NSObject>

- (void)beaconManager:(RPBeaconManager *)manager didUpdatedBeacons:(NSArray *)beacons;

@end

@interface RPBeaconManager : NSObject

@property (nonatomic, assign) id<RPBeaconManagerDelegate> beaconDelegate;

+ (id)sharedInstance;

- (void)startRangingBeacons;
- (void)stopRangingBeacons;

- (void)setBeaconUpdateInterval:(CGFloat)interval;
- (NSArray *)getBeacons;

@end
