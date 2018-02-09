//
//  SpeedCalibrationDidChangeProtocol.h
//  Sail&Win
//
//  Created by Guenter Laudahn on 29.04.15.
//  Copyright (c) 2015 Günter Laudahn. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SpeedCalibrationDidChangeProtocol <NSObject>

- (void)wertSpeedCalShDidChange:(NSString *)newSpeedCalSh wertSpeedCalCenterDidChange:(NSString *)newSpeedCalCenter wertSpeedCalBDidChange:(NSString *)newSpeedCalB wertWindDirectionDidChange:newWindDirection;

@end