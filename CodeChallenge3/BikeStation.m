//
//  BikeStation.m
//  CodeChallenge3
//
//  Created by Sherrie Jones on 4/4/15.
//  Copyright (c) 2015 Mobile Makers. All rights reserved.
//

#import "BikeStation.h"

@implementation BikeStation

- (instancetype)initWithDictionary:(NSDictionary *)dictionary andLocation:(CLLocation *)location {
    if (self = [super init]) {
        self.availableBikes = dictionary[@"availableBikes"];
        self.availableDocks = dictionary[@"availableDocks"];
        self.totalDocks = dictionary[@"totalDocks"];

        self.location = dictionary[@"location"];
        self.streetAddress = dictionary[@"stAddress1"];
        self.stationName = dictionary[@"stationName"];

        self.title = dictionary[@"stAddress1"];
        self.subtitle = [NSString stringWithFormat:@"Available bikes: %@", [dictionary[@"availableBikes"] stringValue]];

        self.coordinate = CLLocationCoordinate2DMake([dictionary[@"latitude"] doubleValue], [dictionary[@"longitude"] doubleValue]);

        CLLocation *stationLocation = [[CLLocation alloc] initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];

        self.distance = [stationLocation distanceFromLocation:location];
    }
    return self;
}

@end
