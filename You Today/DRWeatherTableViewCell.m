//
//  DRWeatherTableViewCell.m
//  You Today
//
//  Created by Patrick Mc Gartoll on 9/4/11.
//  Copyright 2011 Drenguin. All rights reserved.
//

#import "DRWeatherTableViewCell.h"

@implementation DRWeatherTableViewCell
@synthesize currentTemperatureLabel, currentConditionsLabel, weatherImage, highTemperatureLabel, lowTemperatureLabel, currentLocationLabel, activityIndicator, infoLabel;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
