//
//  SetShipPositionViewController.m
//  Sail&Win
//
//  Created by Guenter Laudahn on 30.05.14.
//  Copyright (c) 2014 Günter Laudahn. All rights reserved.
//

#import "SetShipPositionViewController.h"

@interface SetShipPositionViewController ()

@property (strong, nonatomic) IBOutlet UILabel *longitudeLabel;                 // Property Label zur Anzeige der Longitude
@property (strong, nonatomic) IBOutlet UILabel *latitudeLabel;                  // Property Label zur Anzeige der Latitude
@property (strong, nonatomic) IBOutlet UITextField *longitudeText;              // Property Text zur Anzeige der Longitude
@property (strong, nonatomic) IBOutlet UITextField *latitudeText;               // Property Text zur Anzeige der Latitude
@property (strong, nonatomic) IBOutlet UITextField *preferredSideText;          // Property Text zur Anzeige der preferredSide
@property (weak, nonatomic) IBOutlet UITextField *setShipPositionLabel;         // Property Text zur Anzeige des Labels
@property (weak, nonatomic) IBOutlet UISwitch *shipStartlinePositionSwitch;     // Property Switch zum Umschalten Kurs auf Startschiff oder Mitte
- (IBAction)setShipPositionPressed:(id)sender;                                  // Button SetShipPosition
@end

@implementation SetShipPositionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.longitudeLabel.text = self.contentLongitude;                           // GPS Label werden aus PosItems gesetzt
    self.latitudeLabel.text = self.contentLatitude;
    self.longitudeText.text = self.contentLongitudeShip;                        // GPS Texte werden aus PosItems gesetzt
    self.latitudeText.text = self.contentLatitudeShip;
    self.preferredSideText.text = self.contentprefferedSide;                    // die bevorzugte Seite in die Anzeige schreiben
    int wert = [self.longitudeText.text intValue];                              // wenn GPS Text nicht 0, grün, sonst rot
    if (wert == 0)
    {
        self.setShipPositionLabel.backgroundColor = [UIColor redColor];
    } else
        (self.setShipPositionLabel.backgroundColor = [UIColor greenColor]);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.shipStartlinePositionSwitch addTarget:self action:@selector(switchToShip:)
                               forControlEvents:UIControlEventValueChanged];    // Switch mit dem View verbinden
    
    if ([self.contentprefferedSide  isEqual:@"StartShip"])                         // wenn Startschiff die bevorzugte Seite ist dann Switch on, sonst off
    {
        [self.shipStartlinePositionSwitch setOn:YES animated:YES];               // Switch auf aus stellen zur Anzeige
    } else {
        [self.shipStartlinePositionSwitch setOn:NO animated:YES];               // Switch auf ein stellen zur Anzeige
    }
    
}

- (IBAction)setShipPositionPressed:(id)sender
{
    self.longitudeText.text = self.contentLongitude;        //__________________ GPS Texte werden aus GPS Label gesetzt
    self.latitudeText.text = self.contentLatitude;
        
    int wert = [self.longitudeText.text intValue];          //__________________ wenn GPS Text nicht 0, grün, sonst rot
    if (wert == 0)
    {
        self.setShipPositionLabel.backgroundColor = [UIColor redColor];
    } else
        (self.setShipPositionLabel.backgroundColor = [UIColor greenColor]);
}

- (IBAction)doneButtonPressed:(id)sender
{
    // Die aktuellen Werte aus dem Textfeldern holen.
    NSString *newText1 = self.longitudeText.text;
    NSString *newText2 = self.latitudeText.text;
    NSString *newText3 = self.preferredSideText.text;
    // Die Werte über eine Methode an den Eltern-View-Controlller, übergeben.
    [self.parentVC longShipDidChange:newText1 latiShipDidChange:newText2 prefSideDidChange:newText3];
}
// Switchcheck, um Schalter entsprechend der  auf aus stellen zur Anzeige


// Switch
- (void)switchToShip:(UISwitch *)switchStatus
{
    if ([switchStatus isOn]) {
        self.preferredSideText.text = @"StartShip";
    } else {
        self.preferredSideText.text = @"Center";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
