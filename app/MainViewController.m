//
//  ViewController.m
//  app
//
//  Created by Joel Oliveira on 16/04/14.
//  Copyright (c) 2014 Notificare. All rights reserved.
//

#import "MainViewController.h"
#import "IIViewDeckController.h"
#import "AppDelegate.h"
#import "Configuration.h"
#import "NotificarePushLib.h"



@interface MainViewController ()

@end

@implementation MainViewController


- (AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (NotificarePushLib *)notificare {
    return (NotificarePushLib *)[[self appDelegate] notificarePushLib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 40)];
    [title setText:@"Notificare"];
    [title setFont:LATO_LIGHT_FONT(20)];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setTextColor:ICONS_COLOR];
    [[self navigationItem] setTitleView:title];
    
    [self setPageControlUsed:NO];
    
    [self setupNavigationBar];

    [self setActivityIndicatorView:[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
    
    [[self activityIndicatorView]  setCenter:CGPointMake( self.view.frame.size.width /2-5, self.view.frame.size.height /2-5)];
    [[self activityIndicatorView]  setContentMode:UIViewContentModeCenter];
    [[self activityIndicatorView] setHidden:NO];
    [[self activityIndicatorView] startAnimating];
    
    [self setLoadingView:[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)]];
    [[self loadingView] setBackgroundColor:[UIColor whiteColor]];
    [[self loadingView] addSubview:[self activityIndicatorView]];
    
    
    //For iOS6
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
        [[[self navigationController] navigationBar] setTintColor:MAIN_COLOR];
        
        
        [[UIBarButtonItem appearance] setBackgroundImage:[UIImage imageNamed:@"Transparent"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearance] setBackgroundImage:[UIImage imageNamed:@"Transparent"] forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];
        
    } else {
        
        [[[self navigationController] navigationBar] setBarTintColor:MAIN_COLOR];
    }
    

    [[self view] setBackgroundColor:WILD_SAND_COLOR];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBadge) name:@"incomingNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registeredDevice) name:@"registeredDevice" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startedLocationUpdates) name:@"startedLocationUpdate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupNavigationBar) name:@"rangingBeacons" object:nil];
    
    [self showTutorial];
}

-(void)registeredDevice{

    CGRect frame = self.scrollView.frame;
    [[self scrollView] setContentOffset:CGPointMake(frame.size.width * 1, 0) animated:NO];
    
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    [settings setBool:YES forKey:@"tutorialUserRegistered"];
    [settings synchronize];
    
    [self performSelector:@selector(hideLoadingView) withObject:nil afterDelay:1.0];
}

-(void)hideLoadingView{
    [[self loadingView] removeFromSuperview];
}

-(void)showLoadingView{
    [[self view] addSubview:[self loadingView]];
}

-(void)startedLocationUpdates{
    
    CGRect frame = self.scrollView.frame;
    [[self scrollView] setContentOffset:CGPointMake(frame.size.width * 2, 0) animated:NO];
    [[self scrollView] setScrollEnabled:NO];
    
    [self performSelector:@selector(hideLoadingView) withObject:nil afterDelay:1.0];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    
    if([settings boolForKey:@"tutorialUserRegistered"] && [[self notificare] checkLocationUpdates]){
        [self startedLocationUpdates];
        [self showLoadingView];
    }
    
    if([settings boolForKey:@"tutorialUserRegistered"] && ![[self notificare] checkLocationUpdates]){
        [self registeredDevice];
        [self showLoadingView];
    }
    
    
}





-(void)showTutorial{
    

    [self setViewsArray:[NSMutableArray array]];
    
    PageOneViewController * pageOne = [[PageOneViewController alloc] initWithNibName:@"PageOneViewController" bundle:nil];
    
    PageTwoViewController * pageTwo = [[PageTwoViewController alloc] initWithNibName:@"PageTwoViewController" bundle:nil];
    
    PageThreeViewController * pageThree = [[PageThreeViewController alloc] initWithNibName:@"PageThreeViewController" bundle:nil];
    
    [self setPageOneController:pageOne];
    [self setPageTwoController:pageTwo];
    [self setPageThreeController:pageThree];
    
    [[self viewsArray] addObject:[self pageOneController]];
    [[self viewsArray] addObject:[self pageTwoController]];
    [[self viewsArray] addObject:[self pageThreeController]];
    
    // a page is the width of the scroll view
    [[self scrollView] setPagingEnabled:YES];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * [[self viewsArray] count], self.scrollView.frame.size.height);
    [[self scrollView] setShowsHorizontalScrollIndicator:NO];
    [[self scrollView] setShowsVerticalScrollIndicator:NO];
    [[self scrollView] setScrollsToTop:NO];
    [[self scrollView] setDelegate:self];
    [[self scrollView] setScrollEnabled:NO];
    
    [[self pageControl] setNumberOfPages:[[self viewsArray] count]];
    [[self pageControl] setCurrentPage:0];
    
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
    
    [[self scrollView] setBackgroundColor:WILD_SAND_COLOR];
}



-(void)setupNavigationBar{
    int count = [[[self appDelegate] notificarePushLib] myBadge];
    
    if(count > 0){
        [[self buttonIcon] setTintColor:ICONS_COLOR];
        [[self badgeButton] addTarget:[self viewDeckController] action:@selector(toggleLeftView) forControlEvents:UIControlEventTouchUpInside];

        NSString * badge = [NSString stringWithFormat:@"%i", count];
        [[self badgeNr] setText:badge];
        
        UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithCustomView:[self badge]];
        [leftButton setTarget:[self viewDeckController]];
        [leftButton setAction:@selector(toggleLeftView)];
        [leftButton setTintColor:ICONS_COLOR];
        [[self navigationItem] setLeftBarButtonItem:leftButton];
    } else {
        
        UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"LeftMenuIcon"] style:UIBarButtonItemStylePlain target:[self viewDeckController] action:@selector(toggleLeftView)];
        [leftButton setTintColor:ICONS_COLOR];
        [[self navigationItem] setLeftBarButtonItem:leftButton];
        
    }
    
    
    
    UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"RightMenuIcon"] style:UIBarButtonItemStylePlain target:[self viewDeckController] action:@selector(toggleRightView)];
    

    [rightButton setTintColor:ICONS_COLOR];
    
    if([[[self appDelegate] beacons] count] > 0){
        [[self navigationItem] setRightBarButtonItem:rightButton];
    } else {
        [[self navigationItem] setRightBarButtonItem:nil];
    }
    
    
    
}

-(void)changeBadge{
    
    [self setupNavigationBar];
    
}



- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if ([self pageControlUsed]) {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
    
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    [[self pageControl] setCurrentPage:page];
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self setPageControlUsed:NO];
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self setPageControlUsed:NO];
}

- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0){
        return;
    }
    if (page >= [[self viewsArray] count]){
        return;
    }
    
    
    
    // replace the placeholder if necessary
    
    if ((NSNull *)[[self viewsArray] objectAtIndex:page] == [NSNull null]) {
        [[self viewsArray] replaceObjectAtIndex:page withObject:[[self viewsArray] objectAtIndex:page]];
    }
    // add the controller's view to the scroll view
    if ([[self viewsArray] objectAtIndex:page] != nil) {
        CGRect frame = self.scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        [[[self viewsArray] objectAtIndex:page] view].frame = frame;
        [[self scrollView] addSubview:[[[self viewsArray] objectAtIndex:page] view]];
    }
    
    
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
