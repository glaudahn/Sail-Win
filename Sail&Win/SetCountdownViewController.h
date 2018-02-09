//
//  SetCountdownViewController.h
//  Sail&Win
//
//  Created by Guenter Laudahn on 30.05.14.
//  Copyright (c) 2014 Günter Laudahn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MasterViewController.h"
#import "SetCountdownDidChangeProtocol.h"


@interface SetCountdownViewController : UIViewController

@property (strong, nonatomic) NSString *contentRemainTimeMinutes;  //__________ NSString-Wert RemainTime
@property (strong, nonatomic) NSString *contentRemainTimeHours;    //__________ NSString-Wert RemainTime
@property (strong, nonatomic) NSString *contentRemainTimeLabel;    //______ NSString-Wert RemainTimeLabel

@property (strong, nonatomic) id <SetCountdownDidChangeProtocol> parentVC;    //_____ Property zur Rückgabe an den Eltern VC

@end
