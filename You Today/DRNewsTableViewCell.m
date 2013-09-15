//
//  DRNewsTableViewCell.m
//  You Today
//
//  Created by Patrick Mc Gartoll on 9/5/11.
//  Copyright 2011 Drenguin. All rights reserved.
//

#import "DRNewsTableViewCell.h"
#import "DRNewsView.h"
#import "NSString+HTML.h"

@implementation DRNewsTableViewCell
@synthesize scrollView, itemsToDisplay;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.frame = CGRectMake(0.0f, 0.0f, 320.0f, 100.0f);
        
        
    }
    return self;
}

-(void)setUpParsing
{
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
    
    for(NSUInteger i = 0; i < itemsToDisplay.count; i++) {
        NSUInteger xOrigin = i*self.frame.size.width;
        DRNewsView *viewController = [[DRNewsView alloc] initWithNibName:@"DRNewsView" bundle:nil];
        [[viewController view] setFrame:CGRectMake(xOrigin+15, 15, self.frame.size.width-30, self.frame.size.height-30)];
        MWFeedItem *item = [itemsToDisplay objectAtIndex:i];
        if (item) {
            // Process
            NSString *itemTitle = item.title ? [item.title stringByConvertingHTMLToPlainText] : @"[No Title]";
            NSString *itemSummary = item.summary ? [item.summary stringByConvertingHTMLToPlainText] : @"[No Summary]";
            
            viewController.titleTextLabel.text = itemTitle;
            viewController.subtitleTextLabel.text = itemSummary;
            if(!viewController.imageView.image) {
                viewController.imageView.image = [[UIImage imageWithData:[NSData dataWithContentsOfURL:item.image]] retain];
            }
        }
        [scrollView addSubview:viewController.view];
        [viewController release];
    }
    scrollView.contentSize = CGSizeMake(self.frame.size.width * [itemsToDisplay count]-30, 100.0f);
    [self addSubview:scrollView];
    [self setNeedsDisplay];
}

- (void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error {
	NSLog(@"Finished Parsing With Error: %@", error);
	self.itemsToDisplay = [NSArray array];
	[parsedItems removeAllObjects];
}

-(void)dealloc
{
    [itemsToDisplay release];
    [scrollView release];
    [super dealloc];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
