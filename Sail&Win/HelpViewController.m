//
//  HelpViewController.m
//  Sail&Win
//
//  Created by Guenter Laudahn on 30.05.14.
//  Copyright (c) 2014 Günter Laudahn. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()

@property UIButton *buttonWWW;


@end

@implementation HelpViewController


float x = 0;
int y = 0;
int dx = 0;
int dy = 0;
int ss = 0;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    

//    // Create a label and add it to the view.
//    CGRect labelFrame = CGRectMake( 10, 140, 100, 30 );
//    UILabel* label = [[UILabel alloc] initWithFrame: labelFrame];
//    [label setText: @"My Label"];
//    [label setTextColor: [UIColor orangeColor]];
//    [self.view addSubview: label];
//
    
    
    [self setsaillogoForSelectedIphone];
    
    
    }


-(void)setsaillogoForSelectedIphone
{
    //if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        
        NSLog(@"screenHeight: %f",screenHeight);
        NSLog(@"screenWidt: %f",screenWidth);
        
        if( screenHeight > 480 && screenHeight < 667 )
        {
            // iPhone 5/5s screenHeight=568 ,screenWidth=320
            NSLog(@"Saillogo for iPhone 5/5s");

            x= 200;
            y = 75;
            dx = 100;
            dy = 100;
            ss = 18;
            

        } else if ( screenHeight > 480 && screenHeight < 736 ){
            // iPhone 6/6s screenHeight=667 ,screenWidth=375
            NSLog(@"Saillogo for iPhone 6/6s");
            
            x= 230;
            y = 75;
            dx = 125;
            dy = 125;
            ss = 19;
            

        } else if ( screenHeight > 480 ){
            // iPhone 6/6s Plus screenHeight=736 ,screenWidth=414
            NSLog(@"Saillogo for iPhone 6/6s Plus");

            x= 259;
            y = 75;
            dx = 135;
            dy = 135;
            ss = 20;
            

        } else {
            // iPhone 3GS, 4, and 4S and iPod Touch 3rd and 4th generation screenHeight=480 ,screenWidth=320
            NSLog(@"Saillogo for iPhone 4/4s");
            
            x= 200;
            y = 75;
            dx = 100;
            dy = 100;
            ss = 16;

        }
        
        self.view.backgroundColor = [UIColor lightGrayColor];
        
        // _________________________________________________________________________ Button Logo Sail & Win
        
        self.buttonWWW = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.buttonWWW setFrame:CGRectMake(x, y, dx, dy)];
        [self.buttonWWW setBackgroundImage:[UIImage imageNamed:@"saillogo.png"] forState:UIControlStateNormal];
        //self.buttonWWW.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
        //[self.buttonWWW setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        //self.buttonWWW.titleLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:20];
        [self.buttonWWW setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        [self.buttonWWW setTitleShadowColor:[UIColor greenColor] forState:UIControlStateNormal];
        //[self.buttonWWW setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        //self.buttonWWW.tag = 3;
        [self.buttonWWW addTarget:self action:@selector(pressButtonWWW:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.buttonWWW];
        
        // _________________________________________________________________________ Button www Sail & Win
        
        self.buttonWWW = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.buttonWWW setFrame:CGRectMake(20, 75, 200, 30)];
        [self.buttonWWW setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.buttonWWW setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.buttonWWW.titleLabel.shadowOffset = CGSizeMake(1.0, 1.0);
        [self.buttonWWW setTitle:@"www.sail-and-win.de" forState:UIControlStateNormal];
        //self.buttonWWW.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.buttonWWW setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        //self.buttonWWW.titleLabel.numberOfLines = 2;
        self.buttonWWW.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:ss];
        //[self.buttonWWW setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.buttonWWW setTitleColor:[UIColor greenColor] forState:UIControlStateHighlighted];
        [self.buttonWWW addTarget:self action:@selector(pressButtonWWW:) forControlEvents:UIControlEventTouchUpInside];
        //self.buttonWWW.tag = 1;
        [self.view addSubview:self.buttonWWW];
    
//        // Create a button and add it to the window
//        CGRect buttonFrame = CGRectMake( 10, 75, 200, 30 );
//        UIButton *button = [[UIButton alloc] initWithFrame: buttonFrame];
//        [button setTitle: @"www.sail-and-win.de" forState: UIControlStateNormal];
//        [button setTitleColor: [UIColor redColor] forState: UIControlStateNormal];
//        [self.view addSubview: button];
//    
    }
}

//- (IBAction)pressButtonWWW:(id)sender {

-(void)pressButtonWWW:(UIButton*) sender {
    
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://www.sail-and-win.de"]];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
