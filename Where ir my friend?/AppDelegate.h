//
//  AppDelegate.h
//  Where ir my friend?
//
//  Created by MacDev on 9/28/13.
//  Copyright (c) 2013 MacDev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UAirship.h"
#import "UAConfig.h"
#import "UAPush.h"
#import "BackendProxy.h"
#import <MapKit/MapKit.h>
#import "UAInboxPushHandler.h"
#import "UAInboxUI.h"
#import "RequestsViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate>{
    BOOL habiaConexion;
    NSString *badgeAccept;
    NSString *badgeRequest;
    CLLocationManager *locationManager;
}

@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) BOOL habiaConexion;
@property (strong, nonatomic) NSString * badgeAccept;

@property (strong, nonatomic) NSString * badgeRequest;

@property(nonatomic,retain) CLLocationManager *locationManager;

@end
