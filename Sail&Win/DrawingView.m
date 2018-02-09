//
//  DrawingView.m
//  Sail&Win
//
//  Created by Guenter Laudahn on 04.06.14.
//  Copyright (c) 2014 Günter Laudahn. All rights reserved.
//

#import "DrawingView.h"

@implementation DrawingView


int x_Ship_Draw = 0; //lokale Variable Startschiff Länge Latitude
int y_Ship_Draw = 0; //lokale Variable Startschiff Breite Longitude
int x_Buoy_Draw = 0; //lokale Variable Boje Länge Latitude
int y_Buoy_Draw = 0; //lokale Variable Boje Breite Longitude
int x_Sailer_Draw = 0; //lokale Variable Segelboot Länge Latitude
int y_Sailer_Draw = 0; //lokale Variable Segelboot Breite Longitude
int x_SailerArrow_Draw = 0; //lokale Variable Segelboot ArrowLänge Latitude
int y_SailerArrow_Draw = 0; //lokale Variable Segelboot ArrowBreite Longitude
int x_Center_Draw = 0;  //lokale Variable Massstab
int y_Center_Draw = 0;  //lokale Variable Schwerpunkt Breite Longitude
int x_Target_Draw = 0; //lokale Variable für Pfeil auf bevorzugtes Ziel
int y_Target_Draw = 0; //lokale Variable für Pfeil auf bevorzugtes Ziel
int windDirection_Draw = 0; //lokale Variable für die Windrichtung
int x_WindP1_Draw = 0; //lokale Variable P1 für WindTriangle
int y_WindP1_Draw = 0; //lokale Variable P1 für WindTriangle
int x_WindP2_Draw = 0; //lokale Variable P2 für WindTriangle
int y_WindP2_Draw = 0; //lokale Variable P2 für WindTriangle
int x_bestArea_Draw = 0; //lokale Variable für Ellipse x-Kordinate
int y_bestArea_Draw = 0; //lokale Variable für Ellipse y-Kordinate
int xl_bestArea_Draw = 0; //lokale Variable für Ellipse xLänge-Kordinate
int yl_bestArea_Draw = 0; //lokale Variable für Ellipse yLänge-Kordinate
int x_Draw = 0; //lokale Variable für Größe des DrawingView
int y_Draw = 0; //lokale Variable für Größe des DrawingView



- (id)initWithFrame:(CGRect)frame
{
   NSLog(@"[Hier ist die %s Methode!", __PRETTY_FUNCTION__,  nil);
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor  = [UIColor cyanColor];
    }
    NSLog(@"x_bestArea: %d ", x_bestArea_Draw);
    
    return self;
}

- (void)update:(int)x_Ship update:(int)y_Ship update:(int)x_Buoy update:(int)y_Buoy update:(int)x_Sailer update:(int)y_Sailer update:(int)x_SailerArrow update:(int)y_SailerArrow update:(int)x_Center update:(int)y_Center update:(int)x_Target update:(int)y_Target update:(int)windDirection update:(int)x_bestArea update:(int)y_bestArea update:(int)xl_bestArea update:(int)yl_bestArea;
{
    //Übergabe der GPS-Werte an die lokalen Variablen zum Zeichnen

    x_Sailer_Draw = x_Sailer;
    y_Sailer_Draw = y_Sailer;
    x_SailerArrow_Draw = x_SailerArrow; //lokale Variable Segelboot ArrowLänge Latitude
    y_SailerArrow_Draw = y_SailerArrow; //lokale Variable Segelboot ArrowBreite Longitude
    x_Ship_Draw = x_Ship;
    y_Ship_Draw = y_Ship;
    x_Buoy_Draw = x_Buoy;
    y_Buoy_Draw = y_Buoy;
    x_Center_Draw = x_Center;
    y_Center_Draw = y_Center;
    x_Target_Draw = x_Target; //lokale Variable für Linie auf bevorzugtes Ziel
    y_Target_Draw = y_Target; //lokale Variable für Linie auf bevorzugtes Ziel
    x_bestArea_Draw = x_bestArea; //lokale Variable für Ellipse x-Kordinate
    y_bestArea_Draw = y_bestArea; //lokale Variable für Ellipse y-Kordinate
    xl_bestArea_Draw = xl_bestArea; //lokale Variable für Ellipse xLänge-Kordinate
    yl_bestArea_Draw = yl_bestArea; //lokale Variable für Ellipse yLänge-Kordinate
    windDirection_Draw = windDirection;
    x_Draw = 240; //lokale Variable für Größe des DrawingView
    y_Draw = 240; //lokale Variable für Größe des DrawingView  noch für iPhone 4 setzen
    
        //NSLog(@"x_bestArea: %d ", x_bestArea_Draw);
    
//NSLog(@" xSa: %d ySa: %d  xTa: %d yTarget: %d xCenter: %d yCenter: %d windDirection_Draw: %d", x_Sailer_Draw, y_Sailer_Draw , x_Target_Draw, y_Target_Draw , x_Center_Draw, y_Center_Draw, windDirection_Draw);

    [self countWindTriangle];
    [self setNeedsDisplay];
    
    //NSLog(@"[°°°B01]Hier wird der Go Button gedrückt: %s", __PRETTY_FUNCTION__, nil);
    // NSLog(@"---------------- Hier: %s--------------------------", __PRETTY_FUNCTION__, nil);
     //NSLog(@"--------------------------------------------------------------");
     //NSLog(@"--------------------------------------------------------------");

}

-(void)countWindTriangle

{
    double xP1 = 0; //lokale Variable für das StartDreieck
    double yP1 = 0; //lokale Variable für das StartDreieck
    double xP2 = 0; //lokale Variable für das StartDreieck
    double yP2 = 0; //lokale Variable für das StartDreieck
    double hypoThenuse = 0; //lokale Variable hypoThenuse für die Verbindung zwischen P1 und P2
    
//WindTriangle setzen
    hypoThenuse = 2 * x_Draw * sqrt(2); //Länge der Verbindungslinie von P1 und P2
    xP1 = hypoThenuse / 2 + x_Target_Draw; //lokale Variable   //bei Wind aus Norden ( 0° ) ist die Spitze nach oben, in Nordrichtung
    yP1 = hypoThenuse / 2 + y_Target_Draw; //lokale Variable
    xP2 = (-1) * hypoThenuse / 2 + x_Target_Draw; //lokale Variable
    yP2 = hypoThenuse / 2 + y_Target_Draw; //lokale Variable
    //x' = xTa + cosq * (x - xTa) - sinq * (y - yTa) berechnen des um windDirection_Draw WindTriangle
    //y' = yTa + sinq * (x - xTa) + cosq * (y - yTa)
    x_WindP1_Draw = x_Target_Draw + cos(windDirection_Draw /180.0 * M_PI) * (xP1 - x_Target_Draw) - sin(windDirection_Draw /180.0 * M_PI) * (yP1 - y_Target_Draw);
    y_WindP1_Draw = y_Target_Draw + sin(windDirection_Draw /180.0 * M_PI) * (xP1 - x_Target_Draw) + cos(windDirection_Draw /180.0 * M_PI) * (yP1 - y_Target_Draw);
    x_WindP2_Draw = x_Target_Draw + cos(windDirection_Draw /180.0 * M_PI) * (xP2 - x_Target_Draw) - sin(windDirection_Draw /180.0 * M_PI) * (yP2 - y_Target_Draw);
    y_WindP2_Draw = y_Target_Draw + sin(windDirection_Draw /180.0 * M_PI) * (xP2 - x_Target_Draw) + cos(windDirection_Draw /180.0 * M_PI) * (yP2 - y_Target_Draw);
}



- (void)drawRect:(CGRect)rect // wird automatisch aufgerufen, wenn neu gezeichnet werden soll
{
    
//Vorbereitung zum Zeichnen  siehe Draw2D
CGContextRef context = UIGraphicsGetCurrentContext();                           // Bereich festlegen, in dem die Grafik erstellt wird
    CGContextSetLineWidth(context, 2.0);                                        // Linienbreite einstellen
    CGGradientRef gradient;
    CGColorSpaceRef colorspace;
    CGFloat locations[2] = { 0.0, 1.0};
    NSArray *colors = @[(id)[UIColor whiteColor].CGColor, (id)[UIColor redColor].CGColor];
    colorspace = CGColorSpaceCreateDeviceRGB();
    gradient = CGGradientCreateWithColors(colorspace, (CFArrayRef)colors, locations);
    CGPoint startPoint, endPoint;
    CGFloat startRadius, endRadius;
    
    
    
/// bestArea wird gezeichnet
    

    
    //NSLog(@"yl_bestArea_Draw: %d",yl_bestArea_Draw);
    
    
    // Die Linien- und Füllfarbe setzen
    CGContextSetStrokeColorWithColor(context, [UIColor brownColor].CGColor);
    CGContextSetFillColorWithColor(context, [UIColor greenColor].CGColor);
    
    //Die Linienstärke und Art setzen
    CGContextSetLineWidth(context, 8);
    //CGFloat dashes[] = {5,10};
    //CGContextSetLineDash(context, 0.0, dashes, 2);
    
    //NSLog(@"yl_bestArea_Draw %d",yl_bestArea_Draw);
    
    CGRect  borderRect = CGRectMake(x_Target_Draw - yl_bestArea_Draw, y_Target_Draw - yl_bestArea_Draw, 2 * yl_bestArea_Draw, 2 * yl_bestArea_Draw);
    
    // Eine Ellipse hier einen Kreis zeichnen
    CGContextFillEllipseInRect(context, borderRect);
    CGContextStrokeEllipseInRect(context, borderRect);
    
    
    
//    CGContextSetStrokeColorWithColor(context, [UIColor greenColor].CGColor);
//    CGContextSetLineWidth(context, 20);
//    CGContextBeginPath(context);
//    CGContextMoveToPoint(context, x_Ship_Draw, y_Ship_Draw);
//    //CGContextAddLineToPoint(context, 200, 100);
//    CGContextAddQuadCurveToPoint(context,x_Sailer_Draw, y_Sailer_Draw, x_Buoy_Draw, y_Buoy_Draw);
//    CGContextStrokePath(context);
    
    
/// Abdeckung wird gezeichnet
    
    
  
    
    
/// WindTriangle wird gezeichnet
    
//    NSLog(@"x_Target_Draw: %d ", x_Target_Draw);
//    NSLog(@"y_Target_Draw: %d ", y_Target_Draw);
//    NSLog(@"x_WindP1_Draw: %d ", x_WindP1_Draw);
//    NSLog(@"y_WindP1_Draw: %d ", y_WindP1_Draw);
//    NSLog(@"x_WindP2_Draw: %d ", x_WindP2_Draw);
//    NSLog(@"y_WindP2_Draw: %d ", y_WindP2_Draw);


    //CGContextRef context = UIGraphicsGetCurrentContext();                       // Bereich festlegen, in dem die Grafik erstellt wird
    CGContextMoveToPoint(context, x_Target_Draw, y_Target_Draw);                                    // Startpunkt einstellen (x,y)
    CGContextAddLineToPoint(context, x_WindP1_Draw , y_WindP1_Draw);                                 // Linie zum Punkt einstellen (x,y)
    CGContextAddLineToPoint(context, x_WindP2_Draw , y_WindP2_Draw);                                 // Linie zum Punkt einstellen (x,y)
    CGContextSetFillColorWithColor(context,[UIColor yellowColor].CGColor);         // Farbe einstellen mittels UIColor class
    CGContextFillPath(context);
    //CGContextStrokePath(context);
    

//    CGContextSetLineWidth(context, 2.0);
//    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
//    CGContextMoveToPoint(context, x_Target_Draw, y_Target_Draw);
//    CGContextAddLineToPoint(context, x_WindP2_Draw , y_WindP2_Draw);
    CGContextStrokePath(context);
    
    

/// Startlinie wird gezeichnet
    CGContextSetLineWidth(context, 6.0);
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    CGFloat dashArray[] = {1,1};
    CGContextSetLineDash(context, 0, dashArray, 1);
    CGContextMoveToPoint(context, x_Ship_Draw, y_Ship_Draw);
    CGContextAddLineToPoint(context, x_Buoy_Draw, y_Buoy_Draw);
    CGContextStrokePath(context);
    
//
//// Schiff wird gezeichnet:
//
//CGContextSetStrokeColorWithColor(context,[UIColor redColor].CGColor);
//CGContextMoveToPoint(context, 10 + x_Ship_Draw, 0 + y_Ship_Draw);
//CGContextAddLineToPoint(context,  15 + x_Ship_Draw, 5 + y_Ship_Draw);
//CGContextAddLineToPoint(context, 15 + x_Ship_Draw, 12 + y_Ship_Draw);
//CGContextAddLineToPoint(context, 10 + x_Ship_Draw, 25 + y_Ship_Draw);
//CGContextAddLineToPoint(context, 5 + x_Ship_Draw, 12 + y_Ship_Draw);
//CGContextAddLineToPoint(context, 5 + x_Ship_Draw, 5 + y_Ship_Draw);
//CGContextAddLineToPoint(context, 10 + x_Ship_Draw, 0 + y_Ship_Draw);
//CGContextStrokePath(context);

    
///Schiff wird gezeichnet
    colorspace = CGColorSpaceCreateDeviceRGB();
    gradient = CGGradientCreateWithColors(colorspace, (CFArrayRef)colors, locations);
    startPoint.x = x_Ship_Draw;
    startPoint.y = y_Ship_Draw - 20 ;
    endPoint.x = x_Ship_Draw;
    endPoint.y = y_Ship_Draw;
    startRadius = 1;
    endRadius = 10;
    CGContextDrawRadialGradient (context, gradient, startPoint, startRadius, endPoint, endRadius,0);

/// Boje wird gezeichnet
    //CGGradientRef gradient;
    //CGColorSpaceRef colorspace;
    //CGFloat locations[2] = { 0.0, 1.0};
    //NSArray *colors = @[(id)[UIColor whiteColor].CGColor, (id)[UIColor blueColor].CGColor];
    colorspace = CGColorSpaceCreateDeviceRGB();
    gradient = CGGradientCreateWithColors(colorspace, (CFArrayRef)colors, locations);
    //CGPoint startPoint, endPoint;
    //CGFloat startRadius, endRadius;
    startPoint.x = 0 + x_Buoy_Draw;
    startPoint.y = - 10 + y_Buoy_Draw;
    endPoint.x = 0 + x_Buoy_Draw;
    endPoint.y = 0 + y_Buoy_Draw;
    startRadius = 0;
    endRadius = 3;
    CGContextDrawRadialGradient (context, gradient, startPoint, startRadius, endPoint, endRadius,0);

    
// Center wird gezeichnet
//    //CGGradientRef gradient;
//    //CGColorSpaceRef colorspace;
//    //CGFloat locations[2] = { 0.0, 1.0};
//    //NSArray *colors = @[(id)[UIColor whiteColor].CGColor, (id)[UIColor blueColor].CGColor];
//    colorspace = CGColorSpaceCreateDeviceRGB();
//    gradient = CGGradientCreateWithColors(colorspace, (CFArrayRef)colors, locations);
//    //CGPoint startPoint, endPoint;
//    //CGFloat startRadius, endRadius;
//    startPoint.x = 0 + X_Center_Draw;
//    startPoint.y = 0 + Y_Center_Draw;
//    endPoint.x = 0 + X_Center_Draw;
//    endPoint.y = 0 + Y_Center_Draw;
//    startRadius = 0;
//    endRadius = 3;
//    CGContextDrawRadialGradient (context, gradient, startPoint, startRadius, endPoint, endRadius,0);

/// Zielsymbol wird gezeichnet
    
    CGContextSetAlpha(context, 1);
    CGContextFillEllipseInRect(context, CGRectMake(x_Target_Draw - 5, y_Target_Draw - 5, 10.0, 10.0));
    CGContextStrokeEllipseInRect(context, CGRectMake(x_Target_Draw - 5, y_Target_Draw - 5, 10.0, 10.0));
    
    
///Segler wird gezeichnet
    colorspace = CGColorSpaceCreateDeviceRGB();
    gradient = CGGradientCreateWithColors(colorspace, (CFArrayRef)colors, locations);
    startPoint.x = x_Sailer_Draw;
    startPoint.y = y_Sailer_Draw;
    endPoint.x = x_Sailer_Draw;
    endPoint.y = y_Sailer_Draw;
    startRadius = 1;
    endRadius = 3;
    CGContextDrawRadialGradient (context, gradient, startPoint, startRadius, endPoint, endRadius,0);
 
// Linie zum bevorzugten Ziel wird gezeichnet

    
CGContextSetLineWidth(context, 1.0);
CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
//CGFloat dashArray[] = {1,1};
CGContextSetLineDash(context, 0, dashArray, 4);
CGContextMoveToPoint(context, x_Sailer_Draw, y_Sailer_Draw);
CGContextAddLineToPoint(context, x_Target_Draw, y_Target_Draw);
CGContextStrokePath(context);

// Coursepfeil wird gezeichnet
    
    //NSLog(@"X_SailerArrow_Draw= %d Y_SailerArrow_Draw= %d", X_SailerArrow_Draw, Y_SailerArrow_Draw);
    
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    //CGFloat dashArray[] = {1,1};
    CGContextSetLineDash(context, 0, dashArray, 0);
    CGContextMoveToPoint(context, x_Sailer_Draw, y_Sailer_Draw);
    CGContextAddLineToPoint(context, x_SailerArrow_Draw, y_SailerArrow_Draw);
    CGContextStrokePath(context);

}

@end
