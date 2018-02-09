//
//  DrawingView.h
//  Sail&Win
//
//  Created by Guenter Laudahn on 04.06.14.
//  Copyright (c) 2014 Günter Laudahn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawingView : UIView

- (void)update:(int)x_Ship update:(int)y_Ship update:(int)x_Buoy update:(int)y_Buoy update:(int)x_Sailer update:(int)y_Sailer update:(int)x_SailerArrow update:(int)y_SailerArrow update:(int)x_Center update:(int)y_Center update:(int)x_Target update:(int)y_Target update:(int)windDirection update:(int)x_bestArea update:(int)y_bestArea update:(int)xl_bestArea update:(int)yl_bestArea;

@end
