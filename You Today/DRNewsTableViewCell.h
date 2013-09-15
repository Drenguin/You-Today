//
//  DRNewsTableViewCell.h
//  You Today
//
//  Created by Patrick Mc Gartoll on 9/5/11.
//  Copyright 2011 Drenguin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWFeedParser.h"

@interface DRNewsTableViewCell : UITableViewCell <UIScrollViewDelegate, MWFeedParserDelegate> {
    // Parsing
	MWFeedParser *feedParser;
	NSMutableArray *parsedItems;
	
	// Displaying
	NSArray *itemsToDisplay;
	NSDateFormatter *formatter;
}
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) NSArray *itemsToDisplay;

-(void)setUpParsing;

@end
