//
//  AppDelegate.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 4/21/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import UIKit
import CoreData
import iAd

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ADBannerViewDelegate {
    
    var window: UIWindow?
    
    var banner: ADBannerView?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        window?.frame = UIScreen.mainScreen().bounds
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let number:Int = 0
        
        if defaults.objectForKey(symbolSetKey) == nil {
            defaults.setInteger(number, forKey: symbolSetKey)
        }
        if defaults.objectForKey(timedKey) == nil {
            defaults.setBool(false, forKey: timedKey)
        }
        
        // initialize the matrix so it's ready to crank out puzzles
       // SamuraiMatrix.prepareMatrix()
        
        
        return true
        
    }
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        let rootView = window?.rootViewController as? UINavigationController
        
        if let puzzleController = rootView?.topViewController as? PlayPuzzleDelegate {
            saveCurrentPuzzleForController(puzzleController)
            puzzleController.goToBackground()
        } else if let puzzleController = rootView?.topViewController as? SudokuControllerDelegate {
            puzzleController.goToBackground()
        }
        
        
        
        banner = nil
        
        PuzzleStore.sharedInstance.operationQueue.cancelAllOperations()
        
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        let rootView = window?.rootViewController as? UINavigationController
        if let puzzleController = rootView?.topViewController as? PlayPuzzleDelegate {
            saveCurrentPuzzleForController(puzzleController)
        }
        
        
        SamuraiMatrix.tearDown()
        
        
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        let rootView = self.window?.rootViewController as? UINavigationController
        if let puzzleController = rootView?.topViewController as? SudokuController {
            puzzleController.wakeFromBackground()
        }
        
        if !SamuraiMatrix.isReady() {
            SamuraiMatrix.prepareMatrix()
        }
        
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        let rootView = self.window?.rootViewController as? UINavigationController
        if let puzzleController = rootView?.topViewController as? SudokuController {
            puzzleController.wakeFromBackground()
        }
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        
        let rootView = window?.rootViewController as? UINavigationController
        
        if let puzzleController = rootView?.topViewController as? PlayPuzzleDelegate {
            saveCurrentPuzzleForController(puzzleController)
        }
        
        
        
    }
    
    func applicationDidReceiveMemoryWarning(application: UIApplication) {
        
        if UIApplication.sharedApplication().applicationState == UIApplicationState.Background {
            let rootView = window?.rootViewController as? UINavigationController
            
            if let puzzleController = rootView?.topViewController as? PlayPuzzleDelegate {
                
                saveCurrentPuzzleForController(puzzleController)
                rootView?.popViewControllerAnimated(false)
            }
            
        }
        
        dispatch_barrier_sync(concurrentPuzzleQueue){
            SamuraiMatrix.tearDown()
        }
    }
    
    func saveCurrentPuzzleForController(controller: PlayPuzzleDelegate) {
        // save using core data
    }
    
    
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        let rootView = window!.rootViewController as! SudokuController
        
        rootView.bannerViewDidLoadAd(banner)
        
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        let rootView = window!.rootViewController as! SudokuController
        rootView.bannerView(banner, didFailToReceiveAdWithError: error)
        
    }
    
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        
        if let puzzleController = window!.rootViewController  as? PlayPuzzleDelegate {
            return puzzleController.bannerViewActionShouldBegin(banner, willLeaveApplication: willLeave)
        } else {
            if let sudokuContrl = window!.rootViewController  as? SudokuControllerDelegate {
                return sudokuContrl.bannerViewActionShouldBegin(banner, willLeaveApplication: willLeave)
            }
        }
        return false
    }
    
    
    
    func bannerViewActionDidFinish(banner: ADBannerView!) {
        if let puzzleController =  window!.rootViewController as? PlayPuzzleDelegate {
            puzzleController.bannerViewActionDidFinish(banner)
        } else {
            /* if let sudokuContrl = window!.rootViewController  as? SudokuController {
             return sudokuContrl.bannerViewActionDidFinish(banner)
             }*/
        }
        
    }
    
    
}
