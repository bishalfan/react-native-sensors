//  Barometer.m


#import "Barometer.h"
#import <React/RCTBridge.h>
#import <React/RCTEventDispatcher.h>
#import <CoreMotion/CoreMotion.h>
#import "Utils.h"

@implementation Barometer

@synthesize bridge = _bridge;

RCT_EXPORT_MODULE();

- (id) init {
    self = [super init];
    NSLog(@"Barometer");

    if (self) {
        self->_altimeter = [[CMAltimeter alloc] init];
        self->logLevel = 0;
    }
    return self;
}

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"Barometer"];
}

+ (BOOL)requiresMainQueueSetup
{
    return NO;
}

RCT_REMAP_METHOD(isAvailable,
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
    return [self isAvailableWithResolver:resolve
                                rejecter:reject];
}

- (void) isAvailableWithResolver:(RCTPromiseResolveBlock) resolve
                        rejecter:(RCTPromiseRejectBlock) reject {

    if ([CMAltimeter isRelativeAltitudeAvailable])
    {
        resolve(@YES);
    }
    else
    {
        reject(@"-1", @"Barometer is not available", nil);
    }
}

RCT_EXPORT_METHOD(setUpdateInterval:(double) interval) {
    NSLog(@"Can not set update interval for barometer, doing nothing");
}

RCT_EXPORT_METHOD(setLogLevel:(int) level) {
    if (level > 0) {
        NSLog(@"setLogLevel: %f", level);
    }

    self->logLevel = level;
}

RCT_EXPORT_METHOD(getUpdateInterval:(RCTResponseSenderBlock) cb) {
    NSLog(@"getUpdateInterval is not meaningul for a barometer sensor");
    cb(@[[NSNull null], [NSNumber numberWithDouble:0.0]]);
}

RCT_EXPORT_METHOD(startUpdates) {
    if (self->logLevel > 0) {
        NSLog(@"startUpdates/startRelativeAltitudeUpdates");
    }

    [self->_altimeter startRelativeAltitudeUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAltitudeData * _Nullable altitudeData, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error while getting sensor data");
        }

        if (altitudeData) {
            if (self->logLevel > 1) {
                NSLog(@"Updated altitue value: %f, %f, %f", altitudeData.pressure.doubleValue, altitudeData.timestamp, [Utils sensorTimestampToEpochMilliseconds:altitudeData.timestamp]);
            }

            [self sendEventWithName:@"Barometer" body:@{
                @"pressure" : @(altitudeData.pressure.doubleValue * 10.0),
                @"timestamp" : [NSNumber numberWithDouble:[Utils sensorTimestampToEpochMilliseconds:altitudeData.timestamp]]
            }];
        }

    }];
}

RCT_EXPORT_METHOD(stopUpdates) {
    if(self->logLevel > 0) {
        NSLog(@"stopUpdates");
    }

    [self->_altimeter stopRelativeAltitudeUpdates];
}

@end
