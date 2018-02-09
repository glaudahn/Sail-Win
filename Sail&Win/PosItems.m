//
//  PosItems.m
//  Sail&Win
//
//  Created by Guenter Laudahn on 31.05.14.
//  Copyright (c) 2014 Günter Laudahn. All rights reserved.
//

#import "PosItems.h"

@implementation PosItems

-(id)init
{
    self = [super init];
    if (self)
    {
        self.longitudeSailer =  @"longitudeSailer";                             //__________________ NSString-Wert LongitudeSailer
        self.latitudeSailer =  @"latitudeSailer";                               //__________________ NSString-Wert LatitudeSailer
        self.longitudeShip =  @"not set";                                       //______________________ NSString-Wert LongitudeShip
        self.latitudeShip =  @"not set";                                        //______________________ NSString-Wert Latitudeship
        self.longitudeBuoy =  @"not set";                                       //______________________ NSString-Wert LongitudeBuoy
        self.latitudeBuoy =  @"not set";                                        //______________________ NSString-Wert LatitudeBuoy
        self.longitudeTarget =  @"not set";                                     //__________________ NSString-Wert LongitudeTarget
        self.latitudeTarget =  @"not set";                                      //__________________ NSString-Wert LatitudesTarget
        self.remainTime =  @"not set";                                          //__________________ NSString-Wert remainTime
        self.disTarget = @"not set";                                            //__________________ NSString-Wert disTarget
        self.estimateTime =  @"not set";                                        //______________________ NSString-Wert estimateTime
        self.speedToTarget =  @"not set";                                       //______________________ NSString-Wert speedToTarget
        self.speed = @"not set";                                                //______________________ NSString-Wert speed Segler
        self.course = @"not set";                                               //___________________________NSString-Wert course
        self.setStartLabel =  @"not set";                                       //_________________ NSString-Wert startLabel
        self.setShipPositionLabel =  @"not set";                                //_____________ NSString-Wert setShipPositionLabel
        self.setBuoyPositionLabel =  @"not set";                                //_____________ NSString-Wert setBuoyPositionLabel
        self.setCountDownLabel =  @"not set";                                   //______________ NSString-Wert setCountDownLabel
        self.horizontalAccuracy =  @"not set";                                  //______________ NSString-Wert TimeStamp
        self.preferredSide =  @"Center";                                        //______________ NSString-Wert preferredSide;
        self.leer =  @"....";                                                   //______________ NSString-Wert preferredSide;
        self.SpeedCalSh = @"?";                                                //______________ NSString-Wert SpeedCalSh;
        self.SpeedCalCenter = @"?";                                            //______________ NSString-Wert SpeedCalCenter;
        self.SpeedCalB = @"?";                                                 //______________ NSString-Wert SpeedCalB;
        self.windDegree = @"?";                                                //______________ NSString-Wert windDegree;
   }
    return self;
}

@end
