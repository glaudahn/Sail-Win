//
//  setCountdownDidChangeProtocol.h
//  Sail&Win
//
//  Created by Guenter Laudahn on 11.06.14.
//  Copyright (c) 2014 Günter Laudahn. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SetCountdownDidChangeProtocol <NSObject>

- (void)werteCountDownDidChange:(NSString *)newRemainTimeMinutes;

@end
