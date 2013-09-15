//
//  DRWeatherTableViewCell.h
//  You Today
//
//  Created by Patrick Mc Gartoll on 9/4/11.
//  Copyright 2011 Drenguin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DRWeatherTableViewCell : UITableViewCell {
    
}
@property (nonatomic, retain) IBOutlet UILabel *currentTemperatureLabel;
@property (nonatomic, retain) IBOutlet UILabel *highTemperatureLabel;
@property (nonatomic, retain) IBOutlet UILabel *lowTemperatureLabel;
@property (nonatomic, retain) IBOutlet UILabel *currentConditionsLabel;
@property (nonatomic, retain) IBOutlet UILabel *currentLocationLabel;
@property (nonatomic, retain) IBOutlet UILabel *infoLabel;
@property (nonatomic, retain) IBOutlet UIImageView *weatherImage;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
