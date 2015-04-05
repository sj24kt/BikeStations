//
//  BikeStation.h
//  CodeChallenge3
//
//  Created by Sherrie Jones on 4/4/15.
//  Copyright (c) 2015 Mobile Makers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface BikeStation : MKPointAnnotation

@property NSNumber *availableBikes;
@property NSNumber *availableDocks;
@property NSNumber *totalDocks;
@property NSString *location;
@property NSString *streetAddress;
@property NSString *stationName;
@property CLLocationDistance distance;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary andLocation:(CLLocation *)location;

@end
