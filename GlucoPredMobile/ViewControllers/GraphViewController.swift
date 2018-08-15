//
//  ViewController.swift
//  GlucoPredMobile
//
//  Created by Peter Stige on 05/07/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import UIKit
import Charts
import RealmSwift
import GameplayKit
/// Class to handle what happens in simulation view
class GraphViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    /// View controller to choose meals to add to experiment
    var chooseMeal: ChooseMealViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chooseMealViewController") as! ChooseMealViewController
    /// View controller to choose insulin doses to add to experiment
    var chooseInsulin: ChooseInsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "choosInsViewController") as! ChooseInsViewController
    /// View controller to choose exercise to add to experiment
    var chooseExercise: ChooseExerciseViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chooseExerciseViewController") as! ChooseExerciseViewController
    /// Line chart view showing plot of simulation of experiment
    @IBOutlet var lineChartView: LineChartView!
    
    @IBOutlet var statesPlottedLabel: UILabel!
    @IBOutlet var statesPlottedField: UITextField!
    
    @IBOutlet var addActivityLabel: UILabel!
    @IBOutlet var addActivityButton: UIButton!
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var dateField: UITextField!
    
    @IBOutlet weak var estimateButton: UIButton!
    
    @IBOutlet var saveProfileButton: UIButton!

    @IBOutlet var tableView: UITableView!
    
    var person: Person!
    var mmParameterSet: MMParameterSet!
    
    var viewConstraints = [NSLayoutConstraint]()
    var chartPortraitConstraints = [NSLayoutConstraint]()
    var chartPortraitHeightConstraint: NSLayoutConstraint!
    var simDisplayed = false
    
    var diabetesType, sex: String?
    var height, weight: Double?
    var age, hrMax: Int?
    
    var currentExperiment = MMExperiment()
    var simulation: MMSimulator!
    var startDate = Date()
    var simLength: Double = 0 // Simulation length in minutes
    var time: [Date] = []
    var simResult: Matrix!
    var estSimResult: Matrix?
    var paramsToEstimate = [String]()
    
    var datePickerView: UIDatePicker!
    var statesPlottedPicker: UIPickerView!
    
    var tableViewData: [TimeVar] = []
    
    var currentSim: SimulationResult!
    var timeMealVar: TimeMealVar!
    var timeInsVar: TimeVar!
    var timeExVar: TimeExVar!
    var exSessionLength: Double!
    
    var safeAreaSet = false
    var currentOrientation: UIInterfaceOrientation!
    
    var currentControl: UITextField!
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        diabetesType = userDefaultStringForKeyIfExists(key: "diabetesType")
        if let ageStr = userDefaultStringForKeyIfExists(key: "age") {
            age = Int(ageStr)
        }
        sex = userDefaultStringForKeyIfExists(key: "sex")
        if let heightStr = userDefaultStringForKeyIfExists(key: "height") {
            height = Double(heightStr)
        }
        if let weightStr = userDefaultStringForKeyIfExists(key: "weight") {
            weight = Double(weightStr)
        }
        if let hrMaxStr = userDefaultStringForKeyIfExists(key: "HRMax") {
            hrMax = Int(hrMaxStr)
        }
        
        paramsToEstimate = ["mealtime", "carbs", "Si"]
        //paramsToEstimate += ParamInit.pStrList.dropLast(2)
        //paramsToEstimate = ["Si", "kabs", "kgb", "kHL", "Eneo", "kgm", "p2", "f", "kglg"]
        
        time = currentSim.dates
        simResult = currentSim.simResult
        statesPlottedPicker = UIPickerView()
        statesPlottedPicker.delegate = self
        statesPlottedPicker.dataSource = self
        statesPlottedField.text = Constants.plottingChoices[0]
        statesPlottedPicker.selectRow(0, inComponent: 0, animated: false)
        statesPlottedField.delegate = self
        statesPlottedField.inputView = statesPlottedPicker
        addToolbarToTextfieldInput(inputField: statesPlottedField)
        
        datePickerView = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.time
        datePickerView.locale = Locale(identifier: "nb")
        dateField.inputView = datePickerView
        dateField.delegate = self
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        if let start = currentSim.dates.first {
            startDate = start
        }
        dateField.text = dateFormatter.string(from: startDate)
        addToolbarToTextfieldInput(inputField: dateField)
        
        enableSaveButton(enable: false)
        
        tableViewData = currentSim.timeVars
        setSimLength()
        makeExperiment()
        
        let nib = UINib.init(nibName: "TimeVarTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "timeVarCell")
        let nibEx = UINib.init(nibName: "TimeExVarTableViewCell", bundle: nil)
        tableView.register(nibEx, forCellReuseIdentifier: "timeExVarCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        viewConstraints = view.constraints
        chartPortraitHeightConstraint = lineChartView.constraints.first
        currentOrientation = UIApplication.shared.statusBarOrientation
        showCorrectView(fromInterfaceOrientation: .portrait)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var actAdded = false
        
        var mode: Person.Mode?
        if diabetesType == "DM1" {
            mode = Person.Mode.DM1
        } else if diabetesType == "DM2" {
            mode = Person.Mode.DM2
        } else if diabetesType == "Healthy" {
            mode = Person.Mode.HEALTHY
        }
        mmParameterSet = makeParameterSetFromSettings()
        person = Person(ptype: mode, age: age, sex: sex, weight: weight, height: height, hrMax: hrMax, mmParams: mmParameterSet)
        
        if timeMealVar.carb > 0 {
            addActivityToTable(timeVar: timeMealVar)
            actAdded = true
        }
        if timeInsVar.value > 0 {
            addActivityToTable(timeVar: timeInsVar)
            actAdded = true
        }
        if timeExVar.value > 0 {
            addActivityToTable(timeVar: timeExVar)
            actAdded = true
        }
        if actAdded {
            setSimLength()
            startSimulation()
        }
        
        timeMealVar = TimeMealVar()
        chooseMeal = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chooseMealViewController") as! ChooseMealViewController
        timeInsVar = TimeVar()
        chooseInsulin = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "choosInsViewController") as! ChooseInsViewController
        timeExVar = TimeExVar()
        chooseExercise = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chooseExerciseViewController") as! ChooseExerciseViewController
        exSessionLength = 0.0
        
        if !time.isEmpty {
            setChart()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        currentSim.dates = self.time
        currentSim.simResult = self.simResult
        currentSim.timeVars = tableViewData
        
        setEnableLandscapeInGraph(to: false)
        
        if (self.isMovingFromParentViewController) {
            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
        
    }
    /// Needed to allow this view to rotate to landscape orientation
    @objc func canRotate() { }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        currentOrientation = toInterfaceOrientation
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        showCorrectView(fromInterfaceOrientation: fromInterfaceOrientation)
    }
    /// Sets plot from simulation result to lineChartView.
    private func setChart() {
        enableSaveButton(enable: true)
        let rowInPicker = statesPlottedPicker.selectedRow(inComponent: 0)
        var toPlot: [String] = Constants.plotStatesByRow[rowInPicker]
        if let _ = estSimResult {
            if toPlot.count == 1 && toPlot[0] == "Gp" {
                toPlot.append("estGp")
            }
        }
        var values = [[Double]](repeating: [Double](repeating: Double(), count: simResult.getRow(j: 0).count), count: toPlot.count)
        
        for j in 0..<toPlot.count {
            if let stateEnum = Constants.stateEnumFromName[toPlot[j]] {
                for i in 0..<simResult.getColumnDimension() {
                    values[j][i] = simResult.getRow(j: stateEnum + 1)[i]
                    if toPlot[j] == "Gp" || toPlot[j] == "Gt" {
                        values[j][i] = values[j][i] / Constants.GLUCOSEUNITCONVFACTOR
                    }
                }
                toPlot[j] = Constants.stateLongName[stateEnum]
            } else if let res = estSimResult {
                for i in 0..<res.getColumnDimension() {
                    values[j][i] = res.getRow(j: 1)[i] / Constants.GLUCOSEUNITCONVFACTOR
                }
                toPlot[j] = "Estimated plasma glucose"
            }
        }
        
        var referenceTimeInterval: TimeInterval = 0
        if let minTimeInterval = (time.map { $0.timeIntervalSince1970 }).min() {
            referenceTimeInterval = minTimeInterval
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let xValuesNumberFormatter = ChartXAxisFormatter(referenceTimeInterval: referenceTimeInterval, dateFormatter: formatter)
        
        var dataEntries = [[ChartDataEntry]](repeating: [ChartDataEntry](repeating: ChartDataEntry(), count: simResult.getRow(j: 0).count), count: toPlot.count)
        
        for i in 0..<time.count {
            let xValue = (time[i].timeIntervalSince1970 - referenceTimeInterval) / (3600*24)
            for j in 0..<toPlot.count {
                let dataEntry = ChartDataEntry(x: xValue, y: values[j][i])
                dataEntries[j][i] = dataEntry
            }
        }
        
        var lineChartDataSets = [LineChartDataSet]()
        for j in 0..<toPlot.count {
            lineChartDataSets.append(LineChartDataSet(values: dataEntries[j], label: toPlot[j]))
        }
        let lineChartData = LineChartData()
        for lineChartDataSet in lineChartDataSets {
            lineChartDataSet.axisDependency = YAxis.AxisDependency.left
            lineChartDataSet.circleRadius = 1
            lineChartData.dataSets.append(lineChartDataSet)
        }
        lineChartData.giveLinesDifferentColors()
        let leftYAx = lineChartView.leftAxis
        let rightYAx = lineChartView.rightAxis
        leftYAx.axisMinimum = Double(min(Constants.defPlotLimits[rowInPicker][0], Int(lineChartData.getYMin())))
        leftYAx.axisMaximum = Double(max(Constants.defPlotLimits[rowInPicker][1], Int(lineChartData.getYMax())))
        leftYAx.axisMaxLabels = 10
        rightYAx.drawGridLinesEnabled = false
        rightYAx.drawLabelsEnabled = false
        
        let xAx = lineChartView.xAxis
        xAx.drawLabelsEnabled = true
        xAx.labelPosition = .bottom
        xAx.valueFormatter = xValuesNumberFormatter
        lineChartView.chartDescription?.text = Constants.stateUnits[rowInPicker]
        lineChartView.chartDescription?.position = CGPoint(x: 35, y: 0)
        
        lineChartView.data = lineChartData
        lineChartView.backgroundColor = UIColor.lightGray
        
        setEnableLandscapeInGraph(to: true)
    }
    /// Starts simulation with activities from tableViewData
    private func startSimulation() {
        time = []
        
        if diabetesType == nil {
            print("You must choose diabetes type in profile settings to start simulation")
        } else if diabetesType != nil {
            
            let initState = InitialState()
            simulation = MMSimulator(pers: person, initState: initState)
            makeExperiment()
            simResult = simulation.getSimStates(mmexperiment: currentExperiment, params: mmParameterSet)
            time = []
            for i in 0..<simResult.getColumnDimension() {
                time.append(startDate.addingTimeInterval(60*simResult.getRow(j: 0)[i]))
            }
            
            setChart()
        }
    }
    /// Called when estimateButton is clicked.
    /// Starting estimation of parameters to fit already simulated scenario.
    @IBAction func estimateButtonClicked(_ sender: Any) {
        simulation = MMSimulator(pers: person, initState: InitialState())
        let paramEstimator = ParameterEstimator(params: paramsToEstimate, model: self.simulation.model as! GlucoseModel)
        let bestParams = paramEstimator.estimateParameters(refVec: simResult.getRow(j: Constants.XGP+1), exp: currentExperiment)
        
        let sim = MMSimulator(pers: self.person, initState: InitialState())
        for i in 0..<paramsToEstimate.count {
            if let paramVal = ParamInit.healthy[paramsToEstimate[i]] {
                sim.model.updateParamValue(param: MMParameter(name: paramsToEstimate[i], value: paramVal))
            } else if paramsToEstimate[i] == "mealtime" {
                currentExperiment.meals[0].date = startDate.addingTimeInterval(bestParams[i]*60)
            } else if paramsToEstimate[i] == "carbs" {
                currentExperiment.meals[0].carb = bestParams[i]
            }
        }
        
        estSimResult = sim.getSimStates(mmexperiment: currentExperiment, params: sim.model.getParams())
        
        setChart()
        
        print(bestParams)
    }
    
    
    /**
     Adds the toolbar with a done button at the top of the UIPickerViews and keyboards.
     - parameters:
        - inputField: A done button is added to inputField's keyboard
    */
    private func addToolbarToTextfieldInput(inputField: UITextField) {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
        toolbar.barStyle = .default
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(GraphViewController.doneClicked))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [flexSpace, button]
        inputField.inputAccessoryView = toolbar
    }
    /// Called when done button at the top of UIPickerview or keyboard is clicked.
    /// Sets text from UIPickerView or keyboard to corresponding UITextField
    @objc func doneClicked() {
        if currentControl.inputView is UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            dateField.text = dateFormatter.string(from: datePickerView.date)
            dateField.resignFirstResponder()
        }
        
        if currentControl.inputView is UIPickerView {
            let pickerView = currentControl.inputView as! UIPickerView
            let row = pickerView.selectedRow(inComponent: 0)
            pickerView.selectRow(row, inComponent: 0, animated: true)
            pickerView.delegate?.pickerView!(pickerView, didSelectRow: row, inComponent: 0)
            view.endEditing(true)
        }
        
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        currentControl = textField
        if textField == dateField {
            if tableViewData.count <= 0 {
                return true
            } else {
                self.displayDefaultAlert(title: "Stop", message: "You can't change start time while there are activities in the table")
                return false
            }
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if (!(textField.text?.isEmpty)!) {
            if textField == statesPlottedField {
                if Constants.plottingChoices.contains(textField.text!) {
                    return true
                } else {
                    return false
                }
            }
            return true
        }
        else {
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == statesPlottedField {
            startSimulation()
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Constants.plottingChoices.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Constants.plottingChoices[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        statesPlottedField.text = Constants.plottingChoices[row]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let timeVar = tableViewData[indexPath.row]
        
        if timeVar.getType().caseInsensitiveCompare("meal") == ComparisonResult.orderedSame {
            let cell = tableView.dequeueReusableCell(withIdentifier: "timeVarCell", for: indexPath) as! TimeVarTableViewCell
            cell.nameLabel.text = "Meal: \(timeVar.name)"
            cell.secondLabel.text = "Carbs: \(String(format: timeVar.value == floor(timeVar.value) ? "%.0f" : "%.1f", timeVar.value))"
            cell.thirdLabel.text = timeVar.date.getTimeIn24HourFormat()
            return cell
        } else if timeVar.getType().caseInsensitiveCompare("rapid") == ComparisonResult.orderedSame ||
            timeVar.getType().caseInsensitiveCompare("slow") == ComparisonResult.orderedSame {
            let cell = tableView.dequeueReusableCell(withIdentifier: "timeVarCell", for: indexPath) as! TimeVarTableViewCell
            cell.nameLabel.text = "Insulin: \(timeVar.name)"
            cell.secondLabel.text = "Units: \(String(format: timeVar.value == floor(timeVar.value) ? "%.0f" : "%.1f", timeVar.value))"
            cell.thirdLabel.text = timeVar.date.getTimeIn24HourFormat()
            return cell
        } else if timeVar.getType().caseInsensitiveCompare("exercise") == ComparisonResult.orderedSame  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "timeExVarCell", for: indexPath) as! TimeExVarTableViewCell
            let timeExVar = timeVar as! TimeExVar
            cell.nameLabel.text = timeExVar.name
            cell.secondLowerLabel.text = "HR: \(String(format: timeExVar.value == floor(timeExVar.value) ? "%.0f" : "%.1f", timeVar.value))"
            cell.secondUpperLabel.text = "\(timeExVar.exSessionLength) min"
            cell.thirdLabel.text = timeExVar.date.getTimeIn24HourFormat()
            return cell
        }
        return UITableViewCell()
    }
    
    internal func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Activity"
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            setSimLength()
            tableViewData.remove(at: indexPath.row)
            tableView.reloadData()
            startSimulation()
        }
    }
    /// Called when addActivityButton is clicked
    /// Presents an UIAlertView with choices for what to add to experiment. When one is selected the corresponding ViewController 
    @IBAction func addActivityButtonClicked(_ sender: Any) {
        if startDateSelected() {
            let alertController = UIAlertController(title: "Choose type", message: "", preferredStyle: .alert)
            let mealAction = UIAlertAction(title: "Meal", style: .default) { (action:UIAlertAction) in
                self.chooseMeal.timeMealVar = self.timeMealVar
                self.chooseMeal.startDate = self.startDate
                self.present(self.chooseMeal, animated: true, completion: nil)
            }
            let insAction = UIAlertAction(title: "Insulin dose", style: .default) { (action:UIAlertAction) in
                self.chooseInsulin.timeVar = self.timeInsVar
                self.chooseInsulin.startDate = self.startDate
                self.present(self.chooseInsulin, animated: true, completion: nil)
            }
            let exerciseAction = UIAlertAction(title: "Exercise", style: .default) { (action:UIAlertAction) in
                self.chooseExercise.timeExVar = self.timeExVar
                self.chooseExercise.startDate = self.startDate
                self.present(self.chooseExercise, animated: true, completion: nil)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            alertController.addAction(mealAction)
            if diabetesType?.caseInsensitiveCompare("healthy") != ComparisonResult.orderedSame {
                alertController.addAction(insAction)
            }
            alertController.addAction(exerciseAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func saveProfileButtonClicked(_ sender: Any) {
        let alertController = UIAlertController(title: "Save profile", message: nil, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action:UIAlertAction) in
            let newRes = self.makePersSimResult()
            if let n = alertController.textFields![0].text {
                newRes.name = n
                try! self.realm.write {
                    self.realm.add(newRes)
                }
            }
            self.enableSaveButton(enable: false)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addTextField(configurationHandler: { (textField: UITextField!) -> Void in
            textField.placeholder = "Name" })
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func userDefaultStringForKeyIfExists(key: String) -> String? {
        var ret: String?
        if let retStr = UserDefaults.standard.string(forKey: key) {
            ret = retStr
        }
        return ret
    }
    
    func makeParameterSetFromSettings() -> MMParameterSet {
        let mmParameterSet = MMParameterSet()
        if diabetesType == "DM1" {
            for pName in ParamInit.pStrList {
                if let parInRealm = realm.object(ofType: PersistentParameter.self, forPrimaryKey: pName) {
                    mmParameterSet.addParameter(name: parInRealm.name, val: parInRealm.value)
                }
                else if let value = ParamInit.dm1[pName] {
                    mmParameterSet.addParameter(name: pName, val: value)
                } else {
                    print("Parameter not found")
                }
            }
        }
        if diabetesType == "DM2" {
            for pName in ParamInit.pStrList {
                if let parInRealm = realm.object(ofType: PersistentParameter.self, forPrimaryKey: pName) {
                    mmParameterSet.addParameter(name: parInRealm.name, val: parInRealm.value)
                }
                else if let value = ParamInit.dm2[pName] {
                    mmParameterSet.addParameter(name: pName, val: value)
                } else {
                    print("Parameter not found")
                }
            }
        }
        if diabetesType == "Healthy" {
            for pName in ParamInit.pStrList {
                if let parInRealm = realm.object(ofType: PersistentParameter.self, forPrimaryKey: pName) {
                    mmParameterSet.addParameter(name: parInRealm.name, val: parInRealm.value)
                }
                else if let value = ParamInit.healthy[pName] {
                    mmParameterSet.addParameter(name: pName, val: value)
                } else {
                    print("Parameter \(pName) not found")
                }
            }
        }
        return mmParameterSet
    }
    
    func addActivityToTable(timeVar: TimeVar) {
        tableViewData.append(timeVar)
        tableViewData.sort(by: {$0.date < $1.date})
        tableView.reloadData()
    }
    
    func enableSaveButton(enable: Bool) {
        saveProfileButton.isEnabled = enable
        if enable {
            saveProfileButton.backgroundColor = UIColor.darkGray
        } else {
            saveProfileButton.backgroundColor = UIColor.lightGray
        }
    }
    
    func setSimLength() {
        var lastActTime = 0.0
        for act in tableViewData {
            if act.getMinutesSince(otherDate: startDate) > lastActTime {
                lastActTime = act.getMinutesSince(otherDate: startDate)
            }
        }
        simLength = lastActTime + 2*60
    }
    
    func makePersSimResult() -> PersistentSimResult {
        
        let newRes = PersistentSimResult()
        for date in self.time {
            newRes.dates.append(date)
        }
        
        for row in self.simResult.getArray() {
            for value in row {
                newRes.values.append(value)
            }
        }

        for item in self.tableViewData {
            if type(of: item) == TimeVar.self {
                let persItem = PersistentTimeVar()
                persItem.copyFrom(nV: item)
                newRes.timeVars.append(persItem)
            } else if type(of: item) == TimeMealVar.self {
                let persItem = PersistentTimeMealVar()
                if let item = item as? TimeMealVar {
                    persItem.copyFrom(nMV: item)
                }
                newRes.timeMealVars.append(persItem)
            } else if type(of: item) == TimeExVar.self {
                let persItem = PersistentTimeExVar()
                if let item = item as? TimeExVar {
                    persItem.copyFrom(nEV: item)
                }
                newRes.timeExVars.append(persItem)
            }
        }
        if let simAge = self.age {
            newRes.age = simAge
        }
        if let simSex = self.sex {
            newRes.sex = simSex
        }
        if let simDiaType = self.diabetesType {
            newRes.diaType = simDiaType
        }
        
        return newRes
    }
    
    func showCorrectView(fromInterfaceOrientation: UIInterfaceOrientation) {
        if simDisplayed {
            if currentOrientation.isLandscape && fromInterfaceOrientation.isPortrait {
                removeAllButChart()
            } else if currentOrientation.isPortrait {
                displayAll()
                if fromInterfaceOrientation.isPortrait && safeAreaSet {
                    self.additionalSafeAreaInsets.top = -(self.navigationController?.navigationBar.bounds.maxY)!// Bugfix when rotating back to portrait, so that top of graph isn't hidden behind navigation bar
                    safeAreaSet = false
                } else if fromInterfaceOrientation.isLandscape && !safeAreaSet {
                    self.additionalSafeAreaInsets.top = (self.navigationController?.navigationBar.bounds.maxY)! // Bugfix when rotating back to portrait, so that top of graph isn't hidden behind navigation bar
                    safeAreaSet = true
                }
            }
        }
    }
    
    func removeAllButChart() {
        statesPlottedLabel.removeFromSuperview()
        statesPlottedField.removeFromSuperview()
        addActivityLabel.removeFromSuperview()
        addActivityButton.removeFromSuperview()
        dateLabel.removeFromSuperview()
        dateField.removeFromSuperview()
        //estimateButton.removeFromSuperview()
        saveProfileButton.removeFromSuperview()
        tableView.removeFromSuperview()
        chartPortraitConstraints = view.constraints
        view.removeConstraints(view.constraints)
        lineChartView.removeConstraints(lineChartView.constraints)
        lineChartView.pinEdges(to: self.view)
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func displayAll() {
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
        view.removeConstraints(view.constraints)
        view.addSubview(statesPlottedLabel)
        view.addSubview(statesPlottedField)
        view.addSubview(addActivityLabel)
        view.addSubview(addActivityButton)
        view.addSubview(dateLabel)
        view.addSubview(dateField)
        //view.addSubview(estimateButton)
        view.addSubview(saveProfileButton)
        view.addSubview(tableView)
        view.addConstraints(viewConstraints)
        view.addConstraints(chartPortraitConstraints)
        lineChartView.addConstraint(chartPortraitHeightConstraint)
    }
    
    func setEnableLandscapeInGraph(to: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.enableLandscapeInGraph = to
        if simDisplayed != to {
            simDisplayed = to
        }
    }
    
    func startDateSelected() -> Bool {
        if self.tableViewData.count == 0 {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            let calendar = Calendar.current
            let midnightDate = calendar.startOfDay(for: startDate)
            print(midnightDate.getTimeIn24HourFormat())
            let dateString = dateField.text
            if let date = dateFormatter.date(from: dateString!) {
                print(date.getTimeIn24HourFormat())
                let timeOfDay = date.timeIntervalSince(calendar.startOfDay(for: date))
                startDate = midnightDate.addingTimeInterval(timeOfDay)
                print(startDate.getTimeIn24HourFormat())
                return true
            } else {
                self.displayDefaultAlert(title: "Wait", message: "You must select start time to add activity")
                return false
            }
        }
        return true
    }
    
    private func makeExperiment() {
        var meals: [TimeMealVar] = []
        var insulinDoses: [TimeVar] = []
        var exercises: [TimeVar] = []
        for act in tableViewData {
            if act.getType().caseInsensitiveCompare("meal") == ComparisonResult.orderedSame {
                meals.append(act as! TimeMealVar)
            } else if act.getType().caseInsensitiveCompare("rapid") == ComparisonResult.orderedSame ||
                act.getType().caseInsensitiveCompare("slow") == ComparisonResult.orderedSame {
                insulinDoses.append(act)
            } else if act.getType().caseInsensitiveCompare("exercise") == ComparisonResult.orderedSame {
                let ex = act as! TimeExVar
                for t in 0..<(2*ex.exSessionLength) { // times 2 because simulation timestep is 0.5, but should get this from simulation.
                    let newEx = TimeExVar()
                    newEx.copy(nEV: ex)
                    newEx.date.addTimeInterval(Double(t)/2.0*60.0)
                    exercises.append(newEx)
                }
            }
        }
        currentExperiment = MMExperiment(meals: meals, exercise: exercises, insulin: insulinDoses, start: startDate, tmax: simLength)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return startDateSelected()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMeals" {
            if let addMealView = segue.destination as? ChooseMealViewController {
                addMealView.timeMealVar = timeMealVar
                addMealView.startDate = startDate
            }
        } else if segue.identifier == "showInsulinDoses"  {
            if let addInsView = segue.destination as? ChooseInsViewController {
                addInsView.timeVar = timeInsVar
                addInsView.startDate = startDate
            }
        } else if segue.identifier == "showExerciseChooser" {
            if let addExView = segue.destination as? ChooseExerciseViewController {
                addExView.timeExVar = timeExVar
                addExView.exLength = exSessionLength
                addExView.startDate = startDate
            }
        }
    }
}
