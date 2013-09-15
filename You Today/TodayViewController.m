//
//  TodayViewController.m
//  You Today
//
//  Created by Patrick Mc Gartoll on 9/3/11.
//  Copyright 2011 Drenguin. All rights reserved.
//

#import "TodayViewController.h"
#import "DetailTableViewController.h"
#import "DRNewsView.h"


@implementation TodayViewController
@synthesize mainDisplayTableView, scrollView, itemsToDisplay;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc t hat aren't in use.
}

#pragma mark - View lifecycle
-(void)viewWillAppear:(BOOL)animated
{
    mainDisplayTableView.dataSource = self;
    mainDisplayTableView.delegate = self;
    UIImage *bg = [UIImage imageNamed:@"TableBG.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:bg];
    [mainDisplayTableView setBackgroundView:imageView];
    [imageView release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    timerCount = 0.0f;
    
    self.title = @"You Today";
    
    [self setUpNews];
    [self setUpLocationGetting];
    [self setUpCalendarInformation];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)setUpNews
{
   
    
    scrollView = [[TouchDetectingScrollView alloc] initWithFrame:CGRectMake(0, 380, 320, 40)];
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.backgroundColor = [UIColor clearColor];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TickerOrangeBG.png"]];
    imageView.center = CGPointMake(160.0f, 400.0f);
    [self.view addSubview:imageView];
    [imageView release];
    
    newsActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    newsActivityIndicator.center = CGPointMake(160, 400);
    [newsActivityIndicator startAnimating];
    [self.view addSubview:newsActivityIndicator];
    
    [[self view] addSubview:scrollView];
    
    formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle:NSDateFormatterShortStyle];
	[formatter setTimeStyle:NSDateFormatterShortStyle];
	parsedItems = [[NSMutableArray alloc] init];
	self.itemsToDisplay = [NSArray array];
	
	
	// Parse
	NSURL *feedURL = [NSURL URLWithString:@"http://news.google.com/?output=rss"];
	feedParser = [[MWFeedParser alloc] initWithFeedURL:feedURL];
	feedParser.delegate = self;
	feedParser.feedParseType = ParseTypeFull; // Parse feed info and all items
	feedParser.connectionType = ConnectionTypeAsynchronously;
	[feedParser parse];
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(tick) userInfo:nil repeats:YES];
    [runloop addTimer:timer forMode:NSRunLoopCommonModes];
    [runloop addTimer:timer forMode:UITrackingRunLoopMode];

}

-(void)tick
{
    timerCount+=0.1f;
    if(timerCount>=5.0f) {
        int offset = [scrollView contentOffset].x;
        offset+=320;
        if(offset>=scrollView.contentSize.width) {
            offset = 0;
        }
        [scrollView setContentOffset:CGPointMake(offset, 0) animated:YES];
        timerCount = 0.0f;
    }
}

-(void)setUpLocationGetting
{
    weatherDataLoaded = NO;
    weatherCell = [[DRWeatherTableViewCell alloc] init];
    // get our physical location
    LocationGetter *locationGetter = [[LocationGetter alloc] init];
    locationGetter.delegate = self;
    [locationGetter startUpdates]; 	

}

-(void)setUpCalendarInformation
{
    store = [[EKEventStore alloc] init];
    // Create the predicate's start and end dates.
    CFGregorianDate gregorianStartDate, gregorianEndDate;
    CFGregorianUnits startUnits = {0, 0, 0, 0, 0, 0};
    CFGregorianUnits endUnits = {0, 0, 1, 0, 0, 0};
    CFTimeZoneRef timeZone = CFTimeZoneCopySystem();
    
    gregorianStartDate = CFAbsoluteTimeGetGregorianDate(
                                                        
                                                        CFAbsoluteTimeAddGregorianUnits(CFAbsoluteTimeGetCurrent(), timeZone, startUnits),
                                                        
                                                        timeZone);
    gregorianStartDate.hour = 0;
    gregorianStartDate.minute = 0;
    gregorianStartDate.second = 0;
    
    gregorianEndDate = CFAbsoluteTimeGetGregorianDate(
                                                      
                                                      CFAbsoluteTimeAddGregorianUnits(CFAbsoluteTimeGetCurrent(), timeZone, endUnits),
                                                      
                                                      timeZone);
    gregorianEndDate.hour = 0;
    gregorianEndDate.minute = 0;
    gregorianEndDate.second = 0;
    
    NSDate* startDate =
    [NSDate dateWithTimeIntervalSinceReferenceDate:CFGregorianDateGetAbsoluteTime(gregorianStartDate, timeZone)];
    
    NSDate* endDate =
    [NSDate dateWithTimeIntervalSinceReferenceDate:CFGregorianDateGetAbsoluteTime(gregorianEndDate, timeZone)];
    
    CFRelease(timeZone);
    
    // Create the predicate.
    
    NSPredicate *predicate = [store predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil]; // eventStore is an instance variable.
    
    // Fetch all events that match the predicate.
    events = [store eventsMatchingPredicate:predicate];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if(section == 0) {
        return 1;
    } else if(section == 1) {
        if(events.count>0) {
            return [events count];
        } else {
            return 1;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
        
    if([indexPath section] == 0) {
        DRWeatherTableViewCell *cell = (DRWeatherTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil) {
            UIViewController *temp = [[UIViewController alloc] initWithNibName:@"DRWeatherTableViewCell" bundle:nil];
            if(!weatherDataLoaded) {
                cell = (DRWeatherTableViewCell *)temp.view;
                [cell.activityIndicator startAnimating];
                [cell.activityIndicator setHidden:NO];
                [temp release];
                [[cell infoLabel] setText:@""];
            } else {
                cell = (DRWeatherTableViewCell *)temp.view;
                [self performSelectorOnMainThread:@selector(updateWeatherInformation:) withObject:nil waitUntilDone:NO];
            }
        }
        return cell;
    } else if([indexPath section]==1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil) {
            if([indexPath row]<[events count]) {
                EKEvent *event = [events objectAtIndex:[indexPath row]];
                NSString *d = event.description;
                if(d) {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"At: %@",event.location];
                } else {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                }
                [[cell textLabel] setText:[event title]];
                cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
                
            } else {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                cell.textLabel.text = @"Nothing is scheduled for today!";
            }
        }
        return cell;
    }
    
    // Configure the cell...
    return [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[NSArray arrayWithObjects:@"Weather", @"Calendar Events", @"u", @"u", nil] objectAtIndex:section];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath section] == 0) {
        return 100.0f;
    }
    return 44.0f;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath section]==2) {
        // Show detail
        /**DetailTableViewController *detail = [[DetailTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        detail.item = (MWFeedItem *)[itemsToDisplay objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:detail animated:YES];
        [detail release];
        
        // Deselect
        [mainDisplayTableView deselectRowAtIndexPath:indexPath animated:YES];**/
    }
}

#pragma mark LocationDelegate methods
- (void)newPhysicalLocation:(CLLocation *)location {
    lastKnownLocation = location;
    // Alert user
    CLLocationCoordinate2D coord;    
    coord.latitude = lastKnownLocation.coordinate.latitude;
    coord.longitude = lastKnownLocation.coordinate.longitude;
    MKReverseGeocoder *geocoder = [[MKReverseGeocoder alloc] initWithCoordinate:coord];
    geocoder.delegate = self;
    [geocoder start];
}

#pragma mark MKReverseGeocoder Delegate Methods
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
    [geocoder release];
    weatherDataLoaded = YES;
    [self performSelectorInBackground:@selector(showWeatherFor:) withObject:[placemark.addressDictionary objectForKey:@"ZIP"]];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{    
    NSLog(@"reverseGeocoder:%@ didFailWithError:%@", geocoder, error);
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
    DRWeatherTableViewCell *cell = (DRWeatherTableViewCell *)[mainDisplayTableView cellForRowAtIndexPath:path];
    [cell.infoLabel setText:@"Sorry, weather data couldn't be loaded"];
    [geocoder release];
}

#pragma mark MWFeedParserDelegate

- (void)feedParserDidStart:(MWFeedParser *)parser {
	NSLog(@"Started Parsing: %@", parser.url);
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedInfo:(MWFeedInfo *)info {
	NSLog(@"Parsed Feed Info: “%@”", info.title);
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item {
	NSLog(@"Parsed Feed Item: “%@”", item.title);
	if (item) [parsedItems addObject:item];	
}

- (void)feedParserDidFinish:(MWFeedParser *)parser {
	NSLog(@"Finished Parsing%@", (parser.stopped ? @" (Stopped)" : @""));
	self.itemsToDisplay = [parsedItems sortedArrayUsingDescriptors:
						   [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO] autorelease]]];
    [newsActivityIndicator stopAnimating];
    for(NSUInteger i = 0; i < itemsToDisplay.count; i++) {
        CGFloat xOrigin = i*320.0f;
        DRNewsView *viewController = [[DRNewsView alloc] initWithNibName:@"DRNewsView" bundle:nil];
        [[viewController view] setFrame:CGRectMake(xOrigin, 0.0f, 320.0f, 40.0f)];
        MWFeedItem *item = [itemsToDisplay objectAtIndex:i];
        if (item) {
            // Process
            NSString *itemTitle = item.title ? [item.title stringByConvertingHTMLToPlainText] : @"[No Title]";
            
            viewController.titleTextLabel.text = itemTitle;
            /**viewController.subtitleTextLabel.text = itemSummary;
            if(!viewController.imageView.image) {
                viewController.imageView.image = [[UIImage imageWithData:[NSData dataWithContentsOfURL:item.image]] retain];
            }**/
        }
        [scrollView addSubview:viewController.view];
        [viewController release];
    }
    scrollView.contentSize = CGSizeMake(320.0f * [itemsToDisplay count], 40.0f);
    [scrollView setNeedsDisplay];
}

- (void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error {
	NSLog(@"Finished Parsing With Error: %@", error);
	self.itemsToDisplay = [NSArray array];
	[parsedItems removeAllObjects];
    DRNewsView *viewController = [[DRNewsView alloc] initWithNibName:@"DRNewsView" bundle:nil];
    [[viewController view] setFrame:CGRectMake(0.0f, 0.0f, 320.0f, 40.0f)];
    viewController.titleTextLabel.text = @"Sorry, couldn't load the news";
    [scrollView addSubview:viewController.view];
    scrollView.contentSize = CGSizeMake(320.0f, 40.0f);
    [scrollView setNeedsDisplay];
}

#pragma mark UIScrollView Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollV
{
    if(scrollV == self.scrollView) {
        timerCount = 0.0f;
    }
}

- (void)showWeatherFor:(NSString *)query
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    ICB_WeatherConditions *weather = [[ICB_WeatherConditions alloc] initWithQuery:query];
    
    //self.conditionsImage = [[UIImage imageWithData:[NSData dataWithContentsOfURL:weather.conditionImageURL]] retain];
    
    [self performSelectorOnMainThread:@selector(updateWeatherInformation:) withObject:weather waitUntilDone:NO];
    
    [pool release];
}

-(void)updateWeatherInformation:(ICB_WeatherConditions *)weather
{
    if(weather) {
        currentTemp = weather.currentTemp;
        highTemp = weather.highTemp;
        lowTemp = weather.lowTemp;
        currentConditions = weather.condition;
        currentCity = weather.location;
        currentWeatherImage = [[UIImage imageWithData:[NSData dataWithContentsOfURL:weather.conditionImageURL]] retain];
    }
    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
    DRWeatherTableViewCell *cell = (DRWeatherTableViewCell *)[mainDisplayTableView cellForRowAtIndexPath:path];
    [cell.activityIndicator stopAnimating];
    [cell.activityIndicator setHidden:YES];
    //[[cell textLabel] setText:[NSString stringWithFormat:@"Current Temp: %d\nHigh Temp: %d\nLow Temp: %d\nCurrent Conditions: %@\nCurrent Location: %@",currentTemp, highTemp, lowTemp, currentConditions, currentCity]];
    [[cell currentTemperatureLabel] setText:[NSString stringWithFormat:@"Current Temperature: %d",currentTemp]];
    [[cell currentConditionsLabel] setText:currentConditions];
    [[cell highTemperatureLabel] setText:[NSString stringWithFormat:@"High: %d",highTemp]];
    [[cell lowTemperatureLabel] setText:[NSString stringWithFormat:@"Low: %d",lowTemp]];
    [[cell currentLocationLabel] setText:currentCity];
    [[cell weatherImage] setImage:currentWeatherImage];
    [[cell infoLabel] setText:@""];
    [cell setNeedsDisplay];
    //[mainDisplayTableView reloadData];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch *touch in touches) {
        CGPoint touchLoc = [touch locationInView:touch.view];
        touchLoc = CGPointMake(touchLoc.x, touchLoc.y+390);
        CGRect rect = scrollView.frame;
        if(CGRectContainsPoint(rect, touchLoc)) {
            DetailTableViewController *detail = [[DetailTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            detail.item = (MWFeedItem *)[itemsToDisplay objectAtIndex:scrollView.contentOffset.x/320.0f];
            //[self presentModalViewController:detail animated:YES];
            [self.navigationController pushViewController:detail animated:YES];
            [detail release];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setTitle:(NSString *)title
{
    [super setTitle:title];
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    if (!titleView) {
        titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.font = [UIFont boldSystemFontOfSize:19.0];
        titleView.shadowColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        titleView.shadowOffset = CGSizeMake(0.5f, 0.5f);
        
        titleView.textColor = [UIColor blackColor]; // Change to desired color
        
        self.navigationItem.titleView = titleView;
        [titleView release];
    }
    titleView.text = title;
    [titleView sizeToFit];
}


-(void)dealloc 
{
    [newsActivityIndicator release];
    [currentWeatherImage release];
    [super dealloc];
}

@end
