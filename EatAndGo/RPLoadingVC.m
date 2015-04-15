//
//  RPLoadingVC.m
//  EatAndGo
//
//  Created by Kenji on 28/3/15.
//  Copyright (c) 2015 EatAndGo. All rights reserved.
//

#import "RPLoadingVC.h"
#import <EstimoteSDK/EstimoteSDK.h>
#import "SVProgressHUD.h"
#import "RPBeaconManager.h"

@interface RPLoadingVC()<RPBeaconManagerDelegate, ESTBeaconManagerDelegate, ESTUtilityManagerDelegate> {
    int _lastTableId;
    int _nearestCount;
}

@property (nonatomic, strong) ESTBeaconManager *beaconManager;
@property (nonatomic, strong) CLBeaconRegion *region;

@end

@implementation RPLoadingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.region = [[CLBeaconRegion alloc] initWithProximityUUID:ESTIMOTE_PROXIMITY_UUID identifier:@"EstimoteSampleRegion"];
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    
//    [[RPBeaconManager sharedInstance] setBeaconDelegate:self];
//    [[RPBeaconManager sharedInstance] setBeaconUpdateInterval:0.3];
//    [[RPBeaconManager sharedInstance] startRangingBeacons];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [SVProgressHUD showWithStatus:@"Searching for table..."];
    [self startRangingBeacons];
}

- (void)beaconManager:(RPBeaconManager *)manager didUpdatedBeacons:(NSArray *)beacons {
    if (beacons.count > 0) {
        
        NSDictionary *beacon = [beacons firstObject];
        if ([[beacon objectForKey:@"beacon_id"] intValue] == _lastTableId) {
            _nearestCount++;
        } else {
            _nearestCount = 0;
        }
        _lastTableId = [[beacon objectForKey:@"beacon_id"] intValue];
        
        if (_nearestCount == 4) {
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Found table: %d", _lastTableId]];
        }
    }
}

#pragma mark - ESTBeaconManager delegate

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

- (void)beaconManager:(id)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
    NSLog(@"ranging error: %@", error.localizedDescription);
}

- (void)beaconManager:(id)manager monitoringDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
    NSLog(@"monitoring error: %@", error.localizedDescription);
}

- (void)beaconManager:(id)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    NSLog(@"loading");
}


@end
