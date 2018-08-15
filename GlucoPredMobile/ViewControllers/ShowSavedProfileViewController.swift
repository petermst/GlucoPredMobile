//
//  ShowSavedProfileViewController.swift
//  GlucoPredMobile
//
//  Created by Peter Stige on 23/07/2018.
//  Copyright © 2018 Prediktor Medical. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Charts

class ShowSavedProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var lineChartView: LineChartView!
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var infoText: UITextView!
    
    @IBOutlet weak var statesPlottedLabel: UILabel!
    @IBOutlet weak var statesPlottedField: UITextField!
    
    var viewConstraints = [NSLayoutConstraint]()
    var chartPortraitConstraints = [NSLayoutConstraint]()
    var chartPortraitHeightConstraint: NSLayoutConstraint!
    
    var name = ""
    
    var time:[Date] = []
    var simResult:Matrix!
    var timeVars:[TimeVar] = []
    
    var statesPlottedPicker: UIPickerView!
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        time = []
        timeVars = []
        var age: Int = 0
        var sex = ""
        var diaType = ""
        if let persSimResult = realm.object(ofType: PersistentSimResult.self, forPrimaryKey: name) {
            self.simResult = Matrix(m: Constants.nStates, n: persSimResult.dates.count, s: Double())
            for t in 0..<persSimResult.dates.count {
                time.append(persSimResult.dates[t])
                for i in 0..<Constants.nStates {
                    self.simResult.set(i: i, j: t, s: persSimResult.values[t + (i+1)*persSimResult.dates.count])
                }
            }
            for item in persSimResult.timeVars {
                let timeVar = item.getTimeVar()
                timeVars.append(timeVar)
            }
            for item in persSimResult.timeMealVars {
                let timeVar = item.getTimeMealVar()
                timeVars.append(timeVar)
            }
            for item in persSimResult.timeExVars {
                let timeVar = item.getTimeExVar()
                timeVars.append(timeVar)
            }
            age = persSimResult.age
            sex = persSimResult.sex
            diaType = persSimResult.diaType
            
        }
        timeVars.sort(by: {$0.date < $1.date})
        
        infoText.text = "Simulated for \(Int(age)) year old \(sex.lowercased()), with diabetes type \(diaType.lowercased())"
        
        statesPlottedPicker = UIPickerView()
        statesPlottedPicker.delegate = self
        statesPlottedPicker.dataSource = self
        statesPlottedField.text = Constants.plottingChoices[0]
        statesPlottedPicker.selectRow(0, inComponent: 0, animated: false)
        statesPlottedField.delegate = self
        statesPlottedField.inputView = statesPlottedPicker
        addToolbarToTextfieldInput(inputField: statesPlottedField)
        
        let nib = UINib.init(nibName: "TimeVarTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "timeVarCell")
        let nibEx = UINib.init(nibName: "TimeExVarTableViewCell", bundle: nil)
        tableView.register(nibEx, forCellReuseIdentifier: "timeExVarCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.borderWidth = 2.0
        tableView.reloadData()
        
        viewConstraints = view.constraints
        chartPortraitHeightConstraint = lineChartView.constraints.first
        showCorrectView(fromInterfaceOrientation: .portrait)
        
        setChart()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        setEnableLandscapeInGraph(to: false)
        
        if (self.isMovingFromParentViewController) {
            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
    }
    
    // Needed to allow this view to rotate to landscape
    @objc func canRotate() { }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        showCorrectView(fromInterfaceOrientation: fromInterfaceOrientation)
    }
    
    func setChart() {
        let rowInPicker = statesPlottedPicker.selectedRow(inComponent: 0)
        let toPlot: [String] = Constants.plotStatesByRow[rowInPicker]
        var values = [[Double]](repeating: [Double](repeating: Double(), count: simResult.getRow(j: 0).count), count: toPlot.count)
        
        for i in 0..<simResult.getColumnDimension() {
            for j in 0..<toPlot.count {
                values[j][i] = simResult.getRow(j: Constants.stateEnumFromName[toPlot[j]]!)[i]
            }
        }
        
        var referenceTimeInterval: TimeInterval = 0
        if let minTimeInterval = (time.map { $0.timeIntervalSince1970 }).min() {
            referenceTimeInterval = minTimeInterval
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let xValuesNumberFormatter = ChartXAxisFormatter(referenceTimeInterval: referenceTimeInterval, dateFormatter: formatter)
        
        var dataEntries = [[ChartDataEntry]](repeating: [ChartDataEntry](repeating: ChartDataEntry(), count: time.count), count: toPlot.count)
        
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
        
        lineChartView.noDataText = ""
        lineChartView.data = lineChartData
        lineChartView.backgroundColor = UIColor.lightGray
        
        setEnableLandscapeInGraph(to: true)
    }
    
    // Adds the toolbar with a done button at the top of the UIPickerViews for the textfields that use them
    func addToolbarToTextfieldInput(inputField: UITextField) {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
        toolbar.barStyle = .default
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(GraphViewController.doneClicked))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [flexSpace, button]
        inputField.inputAccessoryView = toolbar
    }
    
    @objc func doneClicked() {
        let row = statesPlottedPicker.selectedRow(inComponent: 0)
        statesPlottedPicker.selectRow(row, inComponent: 0, animated: true)
        statesPlottedPicker.delegate?.pickerView!(statesPlottedPicker, didSelectRow: row, inComponent: 0)
        view.endEditing(true)
        
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
        setChart()
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
        return timeVars.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let i = indexPath.row
        if timeVars[i].type.caseInsensitiveCompare("meal") == ComparisonResult.orderedSame {
            let cell = tableView.dequeueReusableCell(withIdentifier: "timeVarCell") as! TimeVarTableViewCell
            cell.nameLabel.text = "Meal: \(timeVars[i].name)"
            cell.secondLabel.text = "Carbs: \(String(format: timeVars[i].value == floor(timeVars[i].value) ? "%.0f" : "%.1f", timeVars[i].value))"
            cell.thirdLabel.text = timeVars[i].date.getTimeIn24HourFormat()
            return cell
        } else if timeVars[i].type.caseInsensitiveCompare("rapid") == ComparisonResult.orderedSame ||
            timeVars[i].type.caseInsensitiveCompare("slow") == ComparisonResult.orderedSame {
            let cell = tableView.dequeueReusableCell(withIdentifier: "timeVarCell") as! TimeVarTableViewCell
            cell.nameLabel.text = "Insulin: \(timeVars[i].name)"
            cell.secondLabel.text = "Units: \(String(format: timeVars[i].value == floor(timeVars[i].value) ? "%.0f" : "%.1f", timeVars[i].value))"
            cell.thirdLabel.text = timeVars[i].date.getTimeIn24HourFormat()
            return cell
        } else if timeVars[i].type.caseInsensitiveCompare("exercise") == ComparisonResult.orderedSame  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "timeExVarCell", for: indexPath) as! TimeExVarTableViewCell
            cell.nameLabel.text = timeVars[i].name
            cell.secondLowerLabel.text = "HR: \(String(format: timeVars[i].value == floor(timeVars[i].value) ? "%.0f" : "%.1f", timeVars[i].value))"
            cell.secondUpperLabel.text = "\((timeVars[i] as! TimeExVar).exSessionLength) min"
            cell.thirdLabel.text = timeVars[i].date.getTimeIn24HourFormat()
            return cell
        }
        
        return UITableViewCell()
    }
    
    func showCorrectView(fromInterfaceOrientation: UIInterfaceOrientation) {
        let currentOrientation = UIDevice.current.orientation
        if (currentOrientation == .landscapeLeft || currentOrientation == .landscapeRight) && fromInterfaceOrientation == .portrait {
            removeAllButChart()
        } else if currentOrientation == .portrait {
            displayAll()
        }
    }
    
    func removeAllButChart() {
        infoText.removeFromSuperview()
        tableView.removeFromSuperview()
        chartPortraitConstraints = view.constraints
        lineChartView.removeConstraints(lineChartView.constraints)
        lineChartView.pinEdges(to: self.view)
        lineChartView.chartDescription?.position = CGPoint(x: 94, y: self.view.bounds.maxY - 27)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func displayAll() {
        self.navigationController?.navigationBar.isHidden = false
        view.removeConstraints(view.constraints)
        view.addSubview(infoText)
        view.addSubview(tableView)
        view.addConstraints(viewConstraints)
        view.addConstraints(chartPortraitConstraints)
        lineChartView.addConstraint(chartPortraitHeightConstraint)
        lineChartView.chartDescription?.position = CGPoint(x: 94, y: lineChartView.bounds.maxY - 27)
    }
    
    func setEnableLandscapeInGraph(to: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.enableLandscapeInGraph = to
    }
    
}
