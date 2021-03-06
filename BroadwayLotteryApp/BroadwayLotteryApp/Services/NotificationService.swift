//
//  NotificationService.swift
//  BroadwayLotteryApp
//
//  Created by Eleanor Murguia on 7/19/17.
//  Copyright © 2017 Eleanor Murguia. All rights reserved.
//

import Foundation
import UserNotifications

struct NotificationService{
    
    /*
     * ENABLING
     */
    
    static func setNotificationID(identifer: String){
        let shows = ShowService.getShows()
        for show in shows{
            if identifer.contains(show.title){
                if identifer.contains("close"){
                    setCloseShowNotification(currentShow: show)
                }else{
                    setOpenShowNotification(currentShow: show)
                }
            }
        }
    }
    
    //enable open notification for one show
    static func setOpenShowNotification(currentShow: Show){
        //set up content
        let content = UNMutableNotificationContent()
        //content.title = NSString.localizedUserNotificationString(forKey: currentShow.title, arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey:
            "The Lottery for \(currentShow.title) has opened!", arguments: nil)

        content.sound = UNNotificationSound.default()

        //set up trigger time
        var dateComponents = DateComponents()
        dateComponents.hour = Calendar.current.component(.hour, from: currentShow.lotteryOpen)
        dateComponents.minute = Calendar.current.component(.minute, from: currentShow.lotteryOpen)
        dateComponents.second = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
      
        //schedule
        let id = currentShow.title
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: { (error) in
            if let error = error {
                print(error)
            }
        })
        
        //set notification default 
        setNotificationDefault(currentShow: currentShow, notificationsStatus: true)
    }
    
    //enable close notification for one show
    static func setCloseShowNotification(currentShow: Show){
        //set up content
        let content = UNMutableNotificationContent()
        //content.title = NSString.localizedUserNotificationString(forKey: currentShow.title, arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "The lottery for \(currentShow.title) just closed. Check your email for results!", arguments: nil)
        
        content.sound = UNNotificationSound.default()
        
        //set up trigger time
        var dateComponents = DateComponents()
        dateComponents.hour = Calendar.current.component(.hour, from: currentShow.lotteryCloseEve)
        dateComponents.minute = Calendar.current.component(.minute, from: currentShow.lotteryCloseEve)
        dateComponents.second = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        //schedule
        let id = currentShow.title + "close"
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: { (error) in
            if let error = error {
                print(error)
            }
        })
        
    }

    //enable notifications for all shows
    static func setAllNotifications(){
        let shows = ShowService.getShows()
        let center = UNUserNotificationCenter.current()
        //for testing
        center.removeAllPendingNotificationRequests()
        
        for show in shows{
            setOpenShowNotification(currentShow: show)
            if UserDefaults.standard.bool(forKey: Constants.UserDefaults.closeNotificationsOn){
                setCloseShowNotification(currentShow: show)
            }
        }
        UserDefaults.standard.set(true, forKey: Constants.UserDefaults.notificationsOn)
    }
    
    //enable close notifications for shows with notifications currently turned on 
    static func setCloseForActiveNotifications(){
        let shows = ShowService.getShows()
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests(){ requests in
            var ids = [String]()
            for request in requests{
                ids.append(request.identifier)
            }
            
            for id in ids{
                for show in shows{
                    if show.title == id{
                        self.setCloseShowNotification(currentShow: show)
                    }
                }
            }
        }
        UserDefaults.standard.set(true, forKey: Constants.UserDefaults.closeNotificationsOn)
    }
    
    
    /* 
     * DISABLING
     */
    
    //disable close notifications for shows with notifications currently turned on
    static func removeCloseForActiveNotifications(){
        let shows = ShowService.getShows()
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests(){ requests in
            var ids = [String]()
            for request in requests{
                ids.append(request.identifier)
            }
            
            for id in ids{
                for show in shows{
                    if show.title == id{
                        self.removeShowCloseNotification(currentShow: show)
                    }
                }
            }
        }
        UserDefaults.standard.set(false, forKey: Constants.UserDefaults.closeNotificationsOn)
    }
    
    
    //disable close notifications for one show
    static func removeShowCloseNotification(currentShow: Show){
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [currentShow.title + "close"])
    }
    
    //disable notifications for one show
    static func removeShowNotification(currentShow: Show){
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [currentShow.title])
        setNotificationDefault(currentShow: currentShow, notificationsStatus: false)
        
    }
    
    //disable close notifications for all shows
    static func removeCloseNotifications(){
        let shows = ShowService.getShows()
        for show in shows{
            removeShowCloseNotification(currentShow: show)
        }
        UserDefaults.standard.set(false, forKey: Constants.UserDefaults.closeNotificationsOn)
    }
    
    //disable all notifications for all shows
    static func removeAllNotifications(){
        let shows = ShowService.getShows()
        for show in shows{
            removeShowNotification(currentShow: show)
            removeShowCloseNotification(currentShow: show)
        }
        UserDefaults.standard.set(false, forKey: Constants.UserDefaults.notificationsOn)
        UserDefaults.standard.set(false, forKey: Constants.UserDefaults.closeNotificationsOn)
    }
    

    
    /*
     * HELPERS
     */
    
  

    //function to set user defaults for each show
    static func setNotificationDefault(currentShow: Show, notificationsStatus: Bool){
        let defaults = UserDefaults.standard
        
        switch currentShow.title {
        case Constants.ShowTitle.aladdin:
            defaults.set(notificationsStatus, forKey: Constants.UserDefaults.aladdinNotifications)
        case Constants.ShowTitle.anastasia:
            defaults.set(notificationsStatus, forKey: Constants.UserDefaults.anastasiaNotifications)
        case Constants.ShowTitle.bookOfMormon:
            defaults.set(notificationsStatus, forKey: Constants.UserDefaults.bookOfMormonNotifications)
        case Constants.ShowTitle.cats:
            defaults.set(notificationsStatus, forKey: Constants.UserDefaults.catsNotifications)
        case Constants.ShowTitle.dearEvanHansen:
            defaults.set(notificationsStatus, forKey: Constants.UserDefaults.dearEvanHansenNotifications)
        case Constants.ShowTitle.greatComet:
            defaults.set(notificationsStatus, forKey: Constants.UserDefaults.greatCometNotifications)
        case Constants.ShowTitle.groundhogDay:
            defaults.set(notificationsStatus, forKey: Constants.UserDefaults.groundhogDayNotifications)
        case Constants.ShowTitle.hamilton:
            defaults.set(notificationsStatus, forKey: Constants.UserDefaults.hamiltonNotifications)
        case Constants.ShowTitle.kinkyBoots:
            defaults.set(notificationsStatus, forKey: Constants.UserDefaults.kinkyBootsNotifications)
        case Constants.ShowTitle.lionKing:
            defaults.set(notificationsStatus, forKey: Constants.UserDefaults.lionKingNotifications)
        case Constants.ShowTitle.onYourFeet:
            defaults.set(notificationsStatus, forKey: Constants.UserDefaults.onYourFeetNotifications)
        case Constants.ShowTitle.oslo:
            defaults.set(notificationsStatus, forKey: Constants.UserDefaults.osloNotifications)
        case Constants.ShowTitle.phantom:
            defaults.set(notificationsStatus, forKey: Constants.UserDefaults.phantomNotifications)
        case Constants.ShowTitle.schoolOfRock:
            defaults.set(notificationsStatus, forKey: Constants.UserDefaults.schoolOfRockNotifications)
        case Constants.ShowTitle.warPaint:
            defaults.set(notificationsStatus, forKey: Constants.UserDefaults.warPaintNotifications)
        case Constants.ShowTitle.wicked:
            defaults.set(notificationsStatus, forKey: Constants.UserDefaults.wickedNotifications)
        case Constants.ShowTitle.charlie:
            defaults.set(notificationsStatus, forKey: Constants.UserDefaults.charlieNotifications)
        case Constants.ShowTitle.springsteen:
            defaults.set(notificationsStatus, forKey: Constants.UserDefaults.springsteenNotifications)
        case Constants.ShowTitle.spongebob:
            defaults.set(notificationsStatus, forKey: Constants.UserDefaults.springsteenNotifications)
        case Constants.ShowTitle.frozen:
            defaults.set(notificationsStatus, forKey: Constants.UserDefaults.frozenNotifications)
        case Constants.ShowTitle.bronx:
            defaults.set(notificationsStatus, forKey: Constants.UserDefaults.bronxNotifications)
        case Constants.ShowTitle.fairLady:
            defaults.set(notificationsStatus, forKey: Constants.UserDefaults.fairLadyNotifications)
        case Constants.ShowTitle.meanGirls:
            defaults.set(notificationsStatus, forKey: Constants.UserDefaults.meanGirlsNotifcations)
        case Constants.ShowTitle.summer:
            defaults.set(notificationsStatus, forKey: Constants.UserDefaults.summerNotifications)
        case Constants.ShowTitle.bandsVisit:
            defaults.set(notificationsStatus, forKey: Constants.UserDefaults.bandsVisitNotifications)
        case Constants.ShowTitle.beautiful:
            defaults.set(notificationsStatus, forKey: Constants.UserDefaults.beautifulNotifcations)
        case Constants.ShowTitle.cher:
            defaults.set(notificationsStatus, forKey: Constants.UserDefaults.cherNotifications)
        case Constants.ShowTitle.kong:
            defaults.set(notificationsStatus, forKey: Constants.UserDefaults.kongNotifications)
        case Constants.ShowTitle.prettyWoman:
            defaults.set(notificationsStatus, forKey: Constants.UserDefaults.prettyWomanNotifications)
        default:
            print("error - show not found")
        }
    }

}
