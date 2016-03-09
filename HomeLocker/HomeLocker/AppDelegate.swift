//
//  AppDelegate.swift
//  HomeLocker
//
//  Created by 施安宏 on 2016/1/30.
//  Copyright © 2016年 shih. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    var locationManager: CLLocationManager!
    var beaconRegion: CLBeaconRegion?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Override point for customization after application launch.
        Fabric.with([Crashlytics.self])

        //let categories = Set<UIUserNotificationCategory>(arrayLiteral: restartGameCategory)
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        self.locationManager.requestAlwaysAuthorization()
        
        self.locationManager.allowsBackgroundLocationUpdates = true
        
        return true
    }

    func startScanning() {
        
        //let uuid = (UUIDString: "90C9B34F-52FE-00F4-EF58-14BFB68AF033")
        //beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "FDA50693-A4E2-4FB1-AFCF-C6EB07647825")!, major: 6, minor: 6, identifier:"Door" )
        beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "f7826da6-4fa2-4e98-8024-bc5b71e0893e")!, major: 20541, minor: 10392, identifier:"Door" )
        beaconRegion!.notifyEntryStateOnDisplay = true
        
        locationManager!.startMonitoringForRegion(beaconRegion!)
        //locationManager.startRangingBeaconsInRegion(beaconRegion)
        
        print("startScanning")
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("applicationDidEnterBackground")
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        print("applicationWillEnterForeground")
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways {
            if CLLocationManager.isMonitoringAvailableForClass(CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        
        let notification: UILocalNotification = UILocalNotification()
        //notification.alertBody = "開始判斷強弱..."
        //UIApplication .sharedApplication().presentLocalNotificationNow(notification);
        
        if beacons.count > 0 {
            //
            
            let now = NSDate().timeIntervalSince1970
            
            var userDefault = NSUserDefaults.standardUserDefaults()
            var lastDate:Double = userDefault.doubleForKey("lastUnlock")
            
            var adjust:Double = lastDate+180.0
            
            if lastDate == 0 {
                userDefault.setDouble(now, forKey: "lastUnlock")
            }else if adjust > now {
                var nextSec = adjust - now;
                if nextSec < 30 {
                    var str = NSString(format: "%.0f", nextSec)
                    notification.alertBody = "進入感應區：\(str)秒後開鎖"
                    //UIApplication .sharedApplication().presentLocalNotificationNow(notification);
                }else {
                    //notification.alertBody = "不開鎖 間隔過短"
                    //UIApplication .sharedApplication().presentLocalNotificationNow(notification);
                }
            }else if adjust <= now {
                let test:CLBeacon = beacons[0]
                if(test.rssi > -70 && test.rssi != 0){
                    //self.openRequest()
                    userDefault.setDouble(now, forKey: "lastUnlock")
                    notification.alertBody = "開鎖～距離近  didRangeBeacons\(test.rssi)"
                    UIApplication .sharedApplication().presentLocalNotificationNow(notification);
                }else if(test.rssi <= -70){
                    notification.alertBody = "不開鎖～距離遠  didRangeBeacons\(test.rssi)"
                    UIApplication .sharedApplication().presentLocalNotificationNow(notification);
                }
            }
        }
    }
    
    func locationManager(manager: CLLocationManager,
        rangingBeaconsDidFailForRegion region: CLBeaconRegion,
        withError error: NSError) {
            print("rangingBeaconsDidFailForRegion")
    }
    
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        /*
        A user can transition in or out of a region while the application is not running. When this happens CoreLocation will launch the application momentarily, call this delegate method and we will let the user know via a local notification.
        */
        
        let notification: UILocalNotification = UILocalNotification()
        
        if region.identifier == "Door" {
            if state == CLRegionState.Inside {
                print("You're inside the region")
                notification.alertBody = "You're inside the region"
                UIApplication .sharedApplication().presentLocalNotificationNow(notification);
                //
                locationManager.startRangingBeaconsInRegion(beaconRegion!)
                //
            }
            else if state == CLRegionState.Outside {
                print("You're outside the region")
                notification.alertBody = "You're outside the region"
                UIApplication .sharedApplication().presentLocalNotificationNow(notification);
                locationManager.stopRangingBeaconsInRegion(beaconRegion!)
            }
            else {
                return
            }
            
            /*
            If the application is in the foreground, it will get a callback to application:didReceiveLocalNotification:.
            If it's not, iOS will display the notification to the user.
            */
        }
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        print("didReceiveLocalNotification")
    }
    
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        print("didStartMonitoringForRegion")
    }
    
    func openRequest() {
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        Alamofire.request(.POST, "http://114.34.167.81/doorHistory.php", parameters: ["code" : "1234"], encoding: .URL, headers: headers).response {request, response, data, error in
            print(request)
            print(response)
            print(data)
            print(error)
        }
    }
}

