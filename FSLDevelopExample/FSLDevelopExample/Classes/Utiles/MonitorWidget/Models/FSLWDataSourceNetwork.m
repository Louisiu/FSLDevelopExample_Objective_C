//
//  FSLWDataSourceNetwork.m
//  FSLDevelopExample
//
//  Created by Fingal Liu on 2019/5/31.
//  Copyright © 2019 Fingal Liu. All rights reserved.
//

#import "FSLWDataSourceNetwork.h"
#include <ifaddrs.h>
#include <net/if.h>

@implementation MDSNetworkData

- (instancetype)initWithUpSpeed:(float)upSpeed downSpeed:(float)downSpeed {
    
    self = [super init];
    
    if (self) {
        _upSpeed = upSpeed;
        
        _downSpeed = downSpeed;
    }
    return self;
}

+ (instancetype)modelWithUpSpeed:(float)upSpeed downSpeed:(float)downSpeed {
    
    return [[MDSNetworkData alloc] initWithUpSpeed:upSpeed downSpeed:downSpeed];
}

@end

@interface FSLWDataSourceNetwork()

@property (assign,nonatomic) uint32_t historySent;

@property (assign,nonatomic) uint32_t historyRecived;

@property (nonatomic, assign) u_int32_t kWiFiSent;

@property (nonatomic, assign) u_int32_t kWiFiReceived;

@property (nonatomic, assign) u_int32_t kWWANSent;

@property (nonatomic, assign) u_int32_t kWWANReceived;

@property(nonatomic, strong) MDSNetworkData *lastStatusData;

@end

@implementation FSLWDataSourceNetwork

- (void)timerTick {
    
    [self getNetflow];
}

- (void)getNetflow {
    
    BOOL   success;
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    const struct if_data *networkStatisc;
    self.kWiFiSent = 0;
    self.kWiFiReceived = 0;
    self.kWWANSent = 0;
    self.kWWANReceived = 0;
    NSString *name = @"";
    success = getifaddrs(&addrs) == 0;
    
    if (success) {
        
        cursor = addrs;
        while (cursor != NULL) {
            name = [NSString stringWithFormat:@"%s",cursor->ifa_name];
            // names of interfaces: en0 is WiFi ,pdp_ip0 is WWAN
            if (cursor->ifa_addr->sa_family == AF_LINK) {
                if ([name hasPrefix:@"en"]) {
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    
                    self.kWiFiSent+=networkStatisc->ifi_obytes;
                    self.kWiFiReceived+=networkStatisc->ifi_ibytes;
                }
                
                if ([name hasPrefix:@"pdp_ip"]) {
                    
                    networkStatisc = (const struct if_data *) cursor->ifa_data;
                    self.kWWANSent+=networkStatisc->ifi_obytes;
                    self.kWWANReceived+=networkStatisc->ifi_ibytes;
                }
            }
            cursor = cursor->ifa_next;
        }
        freeifaddrs(addrs);
    }
    //第一次不统计
    if (_lastStatusData == nil) {
        _lastStatusData = [MDSNetworkData new];
        self.historySent = self.kWiFiSent + self.kWWANSent;
        self.historyRecived = self.kWiFiReceived + self.kWWANReceived;
    } else {
        uint32_t nowSent = (self.kWiFiSent + self.kWWANSent - self.historySent);
        uint32_t nowRecived = (self.kWiFiReceived + self.kWWANReceived - self.historyRecived);
        
        float upUsage = nowSent /1024.0 / 1024.0;
        
        float downUsage = nowRecived / 1024.0 / 1024.0;
        
        float upSpeed = upUsage - self.lastStatusData.upSpeed;
        
        float downSpeed = downUsage - self.lastStatusData.downSpeed;
        
        upSpeed = upSpeed >= 0 ? upSpeed : 0;
        
        downSpeed = downSpeed >= 0 ? downSpeed : 0;
        
        self.lastStatusData.upSpeed = upUsage;
        
        self.lastStatusData.downSpeed = downUsage;
        
        MDSNetworkData *cData = [MDSNetworkData modelWithUpSpeed:upSpeed downSpeed:downSpeed];
        [self addDataSource:cData];
    }
}

- (void)addDataSource:(MDSNetworkData *)object {
    
    if (object && [object isKindOfClass:MDSNetworkData.class]) {
        
        [super addDataSource:[self isUsingUpSpeedKey]?@(object.upSpeed):@(object.downSpeed)];
        return;
    }
    [super addDataSource:object];
}

- (BOOL)isUsingUpSpeedKey {
    
    return [_usingValueKey isEqualToString:@"upSpeed"];
}

- (MDSNetworkData *)lastStatusData {
    
    if (!_lastStatusData) {
        
        _lastStatusData = [MDSNetworkData new];
    }
    return _lastStatusData;
}

@end
