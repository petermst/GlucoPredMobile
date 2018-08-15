//
//  MainMenuViewController.swift
//  GlucoPredMobile
//
//  Created by Peter Stige on 06/07/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import UIKit

/// Class to handle what happens in Main Menu
class MainMenuViewController: UIViewController {
    /// Button to segue to simulation view
    @IBOutlet weak var simulateButton: UIButton!
    /// Button to go to profile settings view
    @IBOutlet weak var profileSettingsButton: UIButton!
    /// Button to go to stored meals and insulin doses
    @IBOutlet weak var mealsButton: UIButton!
    /// Variable to store current simulation
    var currentSim: SimulationResult!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddActivities" {
            if let tabBarController = segue.destination as? UITabBarController {
                let savedMealsViewController = tabBarController.viewControllers![0] as! SavedMealsViewController
                savedMealsViewController.timeMealVar = TimeMealVar()
                let savedInsDosesViewController = tabBarController.viewControllers![1] as! SavedInsDosesViewController
                savedInsDosesViewController.timeVar = TimeVar()
            }
        } else if segue.identifier == "showSimulate" {
            if let tabBarController = segue.destination as? UITabBarController {
                let graphViewController = tabBarController.viewControllers![0] as! GraphViewController
                graphViewController.timeMealVar = TimeMealVar()
                graphViewController.timeInsVar = TimeVar()
                graphViewController.timeExVar = TimeExVar()
                graphViewController.currentSim = self.currentSim
            }
        }
    }
}
