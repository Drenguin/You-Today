//
//  TodayViewController.h
//  You Today
//
//  Created by Patrick Mc Gartoll on 9/3/11.
//  Copyright 2011 Drenguin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import "MapKit/MapKit.h"
#import "TouchXML.h"
#import "LocationGetter.h"
#import "ICB_WeatherConditions.h"
#import "DRWeatherTableViewCell.h"
#import "DRNewsTableViewCell.h"
#import "MWFeedParser.h"
#import "NSString+HTML.h"
#import "TouchDetectingScrollView.h"

@interface TodayViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, LocationGetterDelegate, MKReverseGeocoderDelegate, UIScrollViewDelegate, MWFeedParserDelegate> {
    EKEventStore *store;
    NSArray *events;
    CLLocation *lastKnownLocation;
    NSString *currentConditions, *currentCity;
    NSUInteger currentTemp, highTemp, lowTemp;
    UIImage *currentWeatherImage;
    BOOL weatherDataLoaded;
    DRWeatherTableViewCell *weatherCell;
    
    CGFloat timerCount;
    
    // Parsing
	MWFeedParser *feedParser;
	NSMutableArray *parsedItems;
	
	// Displaying
	NSArray *itemsToDisplay;
	NSDateFormatter *formatter;
    
    UIActivityIndicatorView *newsActivityIndicator;
    
}
@property (nonatomic, retain) IBOutlet UITableView *mainDisplayTableView;
@property (nonatomic, retain) IBOutlet TouchDetectingScrollView *scrollView;
@property (nonatomic, retain) NSArray *itemsToDisplay;

-(void)setUpNews;
-(void)setUpLocationGetting;
-(void)setUpCalendarInformation;
- (void)showWeatherFor:(NSString *)query;
-(void)updateWeatherInformation:(ICB_WeatherConditions *)weather;

@end
