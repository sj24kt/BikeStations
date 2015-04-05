//
//  BikeData.m
//  CodeChallenge3
//
//  Created by Sherrie Jones on 4/4/15.
//  Copyright (c) 2015 Mobile Makers. All rights reserved.
//

#import "BikeData.h"
#import "BikeStation.h"

@implementation BikeData

- (void)getBikeStationLocation:(CLLocation *)location {
    NSURL *url = [NSURL URLWithString:@"http://www.divvybikes.com/stations/json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

        NSDictionary *bikeDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];

        NSArray *bikeStationArray = bikeDictionary[@"stationBeanList"];
        NSMutableArray *bikeStationMutableArray = [NSMutableArray new];

        for (NSDictionary *stationDict in bikeStationArray) {
            BikeStation *station = [[BikeStation alloc] initWithDictionary:stationDict andLocation:location];
            [bikeStationMutableArray addObject:station];
        }

        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];
        NSArray *sortArray = [bikeStationMutableArray sortedArrayUsingDescriptors:@[descriptor]];

        [self.delegate getArrayOfBikes:[[NSArray arrayWithArray:sortArray]mutableCopy]];
    }];
}

@end
