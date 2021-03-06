//
//  PageTwoViewController.m
//  app
//
//  Created by Joel Oliveira on 02/12/14.
//  Copyright (c) 2014 Notificare. All rights reserved.
//

#import "PageTwoViewController.h"
#import "AppDelegate.h"
#import "NotificarePushLib.h"
#import "PageThreeViewController.h"

@interface PageTwoViewController ()

@property (nonatomic, assign) BOOL done;

@end

@implementation PageTwoViewController

- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (NotificarePushLib *)notificare {
    return (NotificarePushLib *)[[self appDelegate] notificarePushLib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[self view] setBackgroundColor:WILD_SAND_COLOR];
    
    [[self message] setText:LSSTRING(@"tutorial_text_page_two")];
    [[self message] setFont:LATO_LIGHT_FONT(19)];
    [[self message] setTextColor:MAIN_COLOR];
    [[self message] setNumberOfLines:7];
    
    
    [[self welcome] setText:LSSTRING(@"tutorial_title_page_two")];
    [[self welcome] setFont:LATO_FONT(24)];
    [[self welcome] setTextColor:MAIN_COLOR];
    [[self welcome] setNumberOfLines:1];
    
    [[self button] setTitle:LSSTRING(@"tutorial_button_page_two") forState:UIControlStateNormal];
    
    [self setPageThreeController:[[PageThreeViewController alloc] initWithNibName:@"PageThreeViewController" bundle:nil]];
    
    [[self navigationItem] setHidesBackButton:YES];
    [[self navigationItem] setLeftBarButtonItem:nil];
    [[self navigationItem] setRightBarButtonItem:nil];
    [[self navigationItem] setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]]];
    
    [[[self navigationController] navigationBar] setBarTintColor:MAIN_COLOR];
    
    
    [[self view] setBackgroundColor:WILD_SAND_COLOR];
}

-(IBAction)startLocationUpdates:(id)sender{
    
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    if([settings boolForKey:@"tutorialUserRegistered"]){
        [[self notificare] startLocationUpdates];
        [[self button] setUserInteractionEnabled:NO];
    } else {
        APP_ALERT_DIALOG(@"You need to enable push notifications for this app first.");
    }

}


-(void)startedLocationUpdates{
    
    if(![self done]){
        [[self navigationController] pushViewController:[self pageThreeController] animated:YES];
        [self setDone:YES];
    }

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [[self navigationItem] setHidesBackButton:YES];
    [[self navigationItem] setLeftBarButtonItem:nil];
    [[self navigationItem] setRightBarButtonItem:nil];
    [[self navigationItem] setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startedLocationUpdates) name:@"startedLocationUpdate" object:nil];
    
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"startedLocationUpdate"
                                                  object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
