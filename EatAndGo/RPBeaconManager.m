//
//  RPBeaconManager.m
//  BleScan
//
//  Created by Kenji on 28/3/15.
//  Copyright (c) 2015 Kenji. All rights reserved.
//

#import "RPBeaconManager.h"
#import <EstimoteSDK/EstimoteSDK.h>

static NSDictionary *AllMyBeacons;
static float BeaconUpdateInterval;

@interface RPBeaconManager()<ESTBeaconManagerDelegate, ESTUtilityManagerDelegate>
{
    NSTimeInterval _lastUpdate;
}

@property (nonatomic, strong) ESTBeaconManager *beaconManager;
@property (nonatomic, strong) CLBeaconRegion *region;

@property (nonatomic, strong) NSMutableDictionary *beaconsDistances;
@property (nonatomic, strong) NSMutableDictionary *beaconsMedians;
@property (nonatomic, strong) NSArray *sortedBeaconsList;

@end

@implementation RPBeaconManager

+ (id)sharedInstance {
    BeaconUpdateInterval = 1.0;
    static RPBeaconManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[RPBeaconManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.region = [[CLBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID identifier:@"EstimoteSampleRegion"];
        self.beaconManager = [[ESTBeaconManager alloc] init];
        self.beaconManager.delegate = self;
        
        if (AllMyBeacons == nil) {
            AllMyBeacons = @{
                             @"18933-21670" : @{@"beacon_id" : @(0), @"name" : @"Table 01"},
                             @"33271-30927" : @{@"beacon_id" : @(1), @"name" : @"Table 02"},
                             @"53725-36531" : @{@"beacon_id" : @(2), @"name" : @"Table 03"}
                             };
        }
        
        self.beaconsDistances = [[NSMutableDictionary alloc] init];
        self.beaconsMedians = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                               @(9999), @"18933-21670",
                               @(9999), @"33271-30927",
                               @(9999), @"53725-36531", nil];
    }
    return self;
}

- (void)startRangingBeacons {
    if ([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.beaconManager requestAlwaysAuthorization];
        [self.beaconManager startRangingBeaconsInRegion:self.region];
    }
    else if ([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
        [self.beaconManager startRangingBeaconsInRegion:self.region];
    }
    else if ([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        NSLog(@"You have denied access to location services. Change this in app settings.");
    }
    else if ([ESTBeaconManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
        NSLog(@"You have no access to location services.");
    }
}

- (void)stopRangingBeacons {
    [self.beaconManager stopRangingBeaconsInRegion:self.region];
}

- (void)setBeaconUpdateInterval:(CGFloat)interval {
    if (interval >= 0.2) {
        BeaconUpdateInterval = interval;
    }
}

- (NSArray *)getBeacons {
    return self.sortedBeaconsList;
}

#pragma mark - ESTBeaconManager delegate

- (void)beaconManager:(id)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
    NSLog(@"ranging error: %@", error.localizedDescription);
}

- (void)beaconManager:(id)manager monitoringDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
    NSLog(@"monitoring error: %@", error.localizedDescription);
}

- (void)beaconManager:(id)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    // update beacons median
    for (CLBeacon *beacon in beacons) {
        NSString *iden = [NSString stringWithFormat:@"%d-%d", [beacon.major intValue], [beacon.minor intValue]];
        if ([AllMyBeacons objectForKey:iden]) {
            // calculate median & sort the array
            if ([self.beaconsDistances objectForKey:iden] == nil) {
                [self.beaconsDistances setObject:[NSMutableArray array] forKey:iden];
            }
            NSMutableArray *values = [self.beaconsDistances objectForKey:iden];
            if (beacon.accuracy >= 0.0) {
                [values addObject:[NSNumber numberWithFloat:(float)beacon.accuracy]];
                if (values.count > 10) {
                    [values removeObjectAtIndex:0];
                }
            }
            CGFloat median = [RPBeaconManager getMedian:values];
            [self.beaconsMedians setObject:@(median) forKey:iden];
        }
    }
    // sort
    NSMutableArray *sorted = [[NSMutableArray alloc] init];
    for (NSString *key in AllMyBeacons) {
        NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
                              [[AllMyBeacons objectForKey:key] objectForKey:@"beacon_id"], @"beacon_id",
                              [self.beaconsMedians objectForKey:key], @"median", nil];
        [sorted addObject:info];
    }
    [sorted sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDictionary *dict1 = obj1;
        NSDictionary *dict2 = obj2;
        if ([[dict1 objectForKey:@"median"] floatValue] <  [[dict2 objectForKey:@"median"] floatValue]) {
            return NSOrderedAscending;
        }
        else if ([[dict1 objectForKey:@"median"] floatValue] > [[dict2 objectForKey:@"median"] floatValue]) {
            return NSOrderedDescending;
        }
        else {
            return NSOrderedSame;
        }
    }];
    self.sortedBeaconsList = sorted;
    // update
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if (now - _lastUpdate > BeaconUpdateInterval) {
        _lastUpdate = now;
        if (self.beaconDelegate && [self.beaconDelegate respondsToSelector:@selector(beaconManager:didUpdatedBeacons:)]) {
            [self.beaconDelegate beaconManager:self didUpdatedBeacons:sorted];
        }
    }
}

#pragma mark - Helper

+ (CGFloat)getMedian:(NSArray *)values {
    if (values.count <= 0) {
        return -1.0;
    } else {
        CGFloat median = 0.0;
        for (NSNumber *value in values) {
            median += [value floatValue];
        }
        return (median / values.count);
    }
}

@end
