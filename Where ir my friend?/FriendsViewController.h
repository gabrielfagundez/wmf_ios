//
//  SecondViewController.h
//  Where ir my friend?
//
//  Created by MacDev on 9/28/13.
//  Copyright (c) 2013 MacDev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface FriendsViewController : UITableViewController <UIAlertViewDelegate>
{
    UIActivityIndicatorView *spinner;
     NSString * name;
}


@property(nonatomic,retain) UIActivityIndicatorView *spinner;

@end
