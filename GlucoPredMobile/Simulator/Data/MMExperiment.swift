//
//  MMExperiment.swift
//  GlucoPredTest
//
//  Created by Peter Stige on 28/06/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import Foundation

class MMExperiment {
    var meals: [TimeMealVar]
    var exercise: [TimeVar]
    var insulin: [TimeVar]
    
    var startDate: Date
    var tmax: Double
    
    init() {
        self.meals = []
        self.exercise = []
        self.insulin = []
        self.startDate = Date()
        self.tmax = 0.0
    }
    
    init(e: MMExperiment) {
        self.meals = e.meals
        self.exercise = e.exercise
        self.insulin = e.insulin
        self.startDate = e.startDate
        self.tmax = e.tmax
    }
    
    init(meals: [TimeMealVar], exercise: [TimeVar], insulin: [TimeVar], start: Date, tmax: Double) {
        self.meals = meals
        self.exercise = exercise
        self.insulin = insulin
        self.startDate = start
        self.tmax = tmax
    }
    
    func addMeal(meal: TimeMealVar) {
        meals.append(meal)
    }
    
    func getMeals() -> [TimeMealVar] {
        return meals
    }
    
    func addExercise(ex: TimeVar) {
        exercise.append(ex)
    }
    
    func getExercise() -> [TimeVar] {
        return exercise
    }
    
    func addInsulin(ins: TimeVar) {
        insulin.append(ins)
    }
    
    func getInsulin() -> [TimeVar] {
        return insulin
    }
    
    func getStartDate() -> Date {
        return startDate
    }
    
    func getMaxTime() -> Double {
        return tmax
    }
}
