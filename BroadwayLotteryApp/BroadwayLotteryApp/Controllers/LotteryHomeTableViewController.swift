//
//  LotteryHomeTableViewController.swift
//  BroadwayLotteryApp
//
//  Created by Eleanor Murguia on 7/11/17.
//  Copyright © 2017 Eleanor Murguia. All rights reserved.
//

import UIKit

class LotteryHomeTableViewController: UITableViewController {

    @IBOutlet weak var backgroundView: UIView!
    //MARK -- Properties 
    let shows = ShowService.getShows()
    let cacheIdentifier = "LotteryHomeViewController"

    @IBAction func settingsBarButtonPressed(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "showSettings", sender: self)
    }
    @IBOutlet weak var settingsBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        let height: CGFloat = 25 //whatever height you want
//        let bounds = self.navigationController!.navigationBar.bounds
//        self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height + height)
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shows.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "showTestCell", for: indexPath) as! ShowTestCell
       // let cell: ShowCell = tableView.dequeueReusableCell(withIdentifier: "showCell", for: indexPath) as! ShowCell
        let index = indexPath.row
        let currentShow = shows[index]
        //print(currentShow.title)
        cell.showTitleLabel.text = currentShow.title
        cell.delegate = self
        cell.index = index
        if let lotteryIsOpen = currentShow.lotteryIsOpen(){
            if currentShow.canEnterWeekly == false{
                if lotteryIsOpen == false {
                    //print("setting label to lottery closed")
                    cell.enterNowButton.setTitle("Lottery Closed", for: .normal)
                    cell.enterNowButton.layer.backgroundColor = UIColor.lightGray.cgColor
                }else if lotteryIsOpen == true{
                    cell.enterNowButton.setTitle("Enter Now", for: .normal)
                    cell.enterNowButton.layer.backgroundColor = UIColor(red:0.26, green:0.57, blue:0.80, alpha:1.0).cgColor
                        //UIColor(red:0.18, green:0.58, blue:0.23, alpha:1.0).cgColor
                }
            }else{
                cell.enterNowButton.setTitle("Enter Now", for: .normal)
                cell.enterNowButton.layer.backgroundColor = UIColor(red:0.26, green:0.57, blue:0.80, alpha:1.0).cgColor
                    //UIColor(red:0.18, green:0.58, blue:0.23, alpha:1.0).cgColor
            }
            
        }
        if currentShow.canEnterWeekly{
            cell.entryPeriodLabel.text = "Weekly"
        }else{
            cell.entryPeriodLabel.text = "Daily"
        }
        
        
        cell.backgroundColor = getAltColor(index: index)
        //test cell
        cell.enterNowButton.layer.cornerRadius = 2
//        cell.enterNowButton.layer.borderWidth = 2.0
//        cell.enterNowButton.layer.borderColor = UIColor.lightGray.cgColor
        //cell.showImage.image = UIImage(contentsOfFile: "Aladdin_digitallottery_980x1502")
        
        //set lottery time labels
        configureLotteryLabels(openLabel: cell.lotteryOpenLabel, closeLabel: cell.lotteryCloseLabel, with: currentShow)
        
        return cell
    }
    
    func getColor(index: Int)-> UIColor{
        if index == 0{
            return UIColor(red:0.55, green:0.06, blue:0.79, alpha:1.0)
        }else if index == 1{
            return UIColor(red:0.92, green:0.53, blue:0.85, alpha:1.0)
        }else if index == 2{
            return UIColor(red:0.83, green:0.72, blue:0.31, alpha:1.0)
        }else if index == 3{
            return UIColor(red:0.00, green:0.00, blue:0.00, alpha:1.0)
        }else{
            return UIColor(red:0.71, green:0.23, blue:0.23, alpha:1.0)
        }
    }
    
    func getAltColor(index: Int) -> UIColor{
        if index == 0{
            return UIColor(red:0.71, green:0.23, blue:0.23, alpha:1.0)
        }else{
            let even = index%2
            if even == 0{
                return UIColor(red:0.71, green:0.23, blue:0.23, alpha:1.0)
            }else{
                return UIColor(red:0.62, green:0.04, blue:0.04, alpha:1.0)
            }
        }
    }
    
    func configureLotteryLabels(openLabel: UILabel, closeLabel: UILabel, with show: Show){

        var openDateComponents = DateComponents()
        openDateComponents.hour = Calendar.current.component(.hour, from: show.lotteryOpen)
        openDateComponents.minute = Calendar.current.component(.minute, from: show.lotteryOpen)
        
        var closeDateComponents = DateComponents()
        closeDateComponents.hour = Calendar.current.component(.hour, from: show.lotteryCloseEve)
        closeDateComponents.minute = Calendar.current.component(.minute, from: show.lotteryCloseEve)
        
        //check if need to convert local time
        let easternTimeZone = TimeZone(identifier: "America/New_York")
        if TimeZone.autoupdatingCurrent != easternTimeZone{
           //lottery open
            let conversionResultOpen = NotificationService.convertToLocalTime(dateComponents: openDateComponents, timeZone: TimeZone.autoupdatingCurrent)
            if let dateComponents = conversionResultOpen {
                configureTime(dateComponents: dateComponents, label: openLabel)
            }
            
            //loterry close
            let conversionResultClose = NotificationService.convertToLocalTime(dateComponents: closeDateComponents, timeZone: TimeZone.autoupdatingCurrent)
            if let dateComponents = conversionResultClose {
                configureTime(dateComponents: dateComponents, label: closeLabel)
            }
        }else{
            configureTime(dateComponents: openDateComponents, label: openLabel)
            configureTime(dateComponents: closeDateComponents, label: closeLabel)
        }
    }
    
    func configureTime(dateComponents: DateComponents, label: UILabel){
        var timeModifier: String = "a.m"
        var printMinutes: String = "0"
        var hour = dateComponents.hour
        var printHour: String = "0"
        
        if hour != nil{
            if hour! >= 12{
                timeModifier = " p.m."
                //convert from 24 hr
                if hour! >= 13{
                    hour = hour! - 12
                }
            }else{
                timeModifier = " a.m."
                if hour! == 0{
                    hour = 12
                }
            }
            printHour = String(hour!)
        }
        
       if let minutes = dateComponents.minute{
            if minutes == 0{
                printMinutes = "00"
            }else if minutes < 10{
                printMinutes = "0" + String(minutes)
            }
            else{
                printMinutes = String(minutes)
            }
        }
        
        let time = printHour + ":" + printMinutes + timeModifier
        label.text = time
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //print("performing segue")
        if segue.identifier == "showSettings" {
            let destVC = segue.destination as! SettingsTableViewController
            destVC.navigationItem.title = "Settings"
        }
    }
 

}

extension LotteryHomeTableViewController: ShowCellDelegate{
    
    func didTapEnterButton(_ likeButton: UIButton, on cell: ShowCell){
        let currentShow = shows[cell.index]
        let webVC = SwiftWebVC(urlString: currentShow.lotteryURL)
        self.navigationController?.pushViewController(webVC, animated: true)
    }
   
}

extension LotteryHomeTableViewController: ShowCellTestDelegate{
    func didPressEnterButton(_ likeButton: UIButton, on cell: ShowTestCell){
        let currentShow = shows[cell.index]
        let webVC = SwiftWebVC(urlString: currentShow.lotteryURL)
        self.navigationController?.pushViewController(webVC, animated: true)
    }

}


