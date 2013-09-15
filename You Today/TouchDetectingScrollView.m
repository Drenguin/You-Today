//
//  TouchDetectingScrollView.m
//  You Today
//
//  Created by Patrick Mc Gartoll on 9/5/11.
//  Copyright 2011 Drenguin. All rights reserved.
//

#import "TouchDetectingScrollView.h"

@implementation TouchDetectingScrollView

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
    }
    
    return self;
}

- (void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event {
	if (!self.dragging) {
		[self.nextResponder touchesEnded: touches withEvent:event]; 
	}		
	[super touchesEnded: touches withEvent: event];
}

-(void)dealloc
{
    [super dealloc];
}

@end
