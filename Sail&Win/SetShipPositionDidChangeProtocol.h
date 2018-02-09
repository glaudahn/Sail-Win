//
//  setShipPositionDidChangeProtocol.h
//  Sail&Win
//
//  Created by Guenter Laudahn on 04.06.14.
//  Copyright (c) 2014 Günter Laudahn. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SetShipPositionDidChangeProtocol <NSObject>

- (void)longShipDidChange:(NSString *)newLongitude latiShipDidChange:(NSString *)newLatitude prefSideDidChange:(NSString *)newPreferredSide;

@end
