//
//  You_TodayAppDelegate.h
//  You Today
//
//  Created by Patrick Mc Gartoll on 8/22/11.
//  Copyright 2011 Drenguin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface You_TodayAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
