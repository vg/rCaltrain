//
//  AppDelegate.swift
//  rCaltrain
//
//  Created by Ranmocy on 9/30/14.
//  Copyright (c) 2014 Ranmocy. All rights reserved.
//

import UIKit

extension NSDate {
    convenience init(timeString: String) {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        if let time = formatter.dateFromString(timeString) {
            self.init(timeInterval: 0, sinceDate: time)
        } else {
            // a special case that HH is greater than 23
            var hour = timeString[0...1].toInt()!
            if hour > 23 {
                var newString = String("00" + timeString[1...timeString.length-1])
                if let time = formatter.dateFromString(newString) {
                    self.init(timeInterval: NSTimeInterval(hour*60*60), sinceDate: time)
                } else {
                    fatalError("Invalid timeString: \(timeString)")
                }
            } else {
                fatalError("Invalid timeString: \(timeString)")
            }
        }
    }
}

extension String {
    subscript (i: Int) -> String {
        return String(Array(self)[i])
    }

    subscript (r: Range<Int>) -> String {
        var start = advance(startIndex, r.startIndex)
        var end = advance(startIndex, r.endIndex)
        return substringWithRange(Range(start: start, end: end))
    }

    var length: Int {
        get {
            return countElements(self)
        }
    }
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // Trip data
    var stationNameToStation: [String: [Station]]!
    var stationIdToStation: [Int: Station]!
    var services: [Service]!

    func readJSON(fileName: String) -> NSDictionary {
        var error: NSError?

        // get filePath
        if let filePath = NSBundle.mainBundle().pathForResource(fileName, ofType: "json") {
            // read file
            if let jsonData = NSData(contentsOfFile: filePath) {
                // parse JSON
                if let json = NSJSONSerialization.JSONObjectWithData(jsonData, options: .MutableContainers, error: &error) as? NSDictionary {
                    return json
                } else {
                    fatalError("Can't parse file: \(fileName).json")
                }
            } else {
                fatalError("Can't read file: \(fileName).json")
            }
        } else {
            fatalError("Can't find file: \(fileName).json")
        }
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.

        // load stops data
        // {stationName: [stationId1, stationId2]}
        stationNameToStation = [:]
        stationIdToStation = [:]
        for (name, idsArray) in readJSON("stops") as [String: NSArray] {
            var stations = [Station]()
            for idObj in idsArray {
                if let id = (idObj as String).toInt() {
                    var station = Station(name: name, id: id)
                    stationIdToStation[id] = station
                    stations.append(station)
                } else {
                    fatalError("invalid id in stops: \(idObj)")
                }
            }
            stationNameToStation[name] = stations
        }

        // load trips data
        // {serviceId: [[stationId, departTime, arrivalTime],...]}
        services = []
        for (serviceId, stopsArray) in readJSON("times") as [String: NSArray] {
            var stops = [Stop]()
            for data in stopsArray as [NSArray] {
                assert(data.count == 3, "data length is \(data.count), expected 3!")

                var id = (data[0] as String).toInt()!
                var dTime = NSDate(timeString: data[1] as String)
                var aTime = NSDate(timeString: data[2] as String)

                stops.append(Stop(station: stationIdToStation[id]!, departureTime: dTime, arrivalTime: aTime))
            }
            services.append(Service(id: serviceId, stops: stops))
        }

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

