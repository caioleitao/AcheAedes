//
//  InferenceViewController.swift
//  AcheAedes
//
//  Created by Caio César on 15/08/22.
//

import UIKit

protocol InferenceViewControllerDelegate {
    func viewController(_ viewController: InferenceViewController, didReceiveAction action: InferenceViewController.Action)
}

class InferenceViewController: UIViewController {
    enum Action {
        case changeThreadCount(Int)
        case changeScoreThreshold(Float)
        case changeMaxResults(Int)
        case changeModel(ModelType)
    }
    
    private enum InferenceSections: Int, CaseIterable {
        case InferenceInfo
    }
    
    private enum InferenceSections: Int, CaseIterable {
        case InferenceInfo
    }
    
    private enum InferenceInfo: Int, CaseIterable {
        case Resolution
        case InferenceTime
        
        func displayString() -> String {
            var toReturn = ""
            
            switch self {
            case .Resolution:
                toReturn = "Resolution"
            case .InferenceTime:
                toReturn = "Inference Time"
            }
            return toReturn
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var threadStepper: UIStepper!
    @IBOutlet weak var threadValueLabel: UILabel!
    @IBOutlet weak var maxResultStepper: UIStepper!
    @IBOutlet weak var maxResultLabel: UILabel!
    @IBOutlet weak var thresholdStepper: UIStepper!
    @IBOutlet weak var thresholdLabel: UILabel!
    @IBOutlet weak var modelTextField: UITextField!
    
    private let normalCellHeight: cgfLOAT = 27.0
    private let separatorCellHeight: CGFloat = 42.0
    private let bottomSpacing: CGFloat = 21.0
    private let bottomSheetButtonDisplayHeight: CGFloat = 60.0
    private let infoTextColor = UIColor.black
    private let lightTextColor = UIColor.black
    private let lightTextInfoColor = UIColor(displayP3Red: 117.0 / 255.0, green: 117.0 / 255, blue: 117.0 / 255.0, alpha: 1.0)
    private let infoFont = UIFont.systemFont(ofSize: 14.0, weight: .regular)
    private let highlightedFont = UIFont.systemFont(ofSize: 14.0, weight: .medium)
    
    var inferenceTime: Double = 0
    var resolution: CGSize = CGSize.zero
    var currentThreadCount: Int = 0
    var scoreThreshold: Float = 0.5
    var maxResults: Int = 3
    var modelSelectIndex: Int = 0
    
    private var modelSelect: ModelType {
        if modelSelectIndex < ModelType.allCases.count {
            return ModelType.allCases[modelsELECTiNDEX]
        } else {
            return .ssdMobileNetV1
        }
    }
    
    var delegate: InferenceViewControllerDelegate?
    
    var collapsedHeight: CGFloat {
        return bottomSheetButtonDisplayHeight
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI(){
        threadStepper.value = Double(currentThreadCount)
        threadValueLabel.text = "\(currentThreadCount)"
        
        maxResultStepper.value = Double(maxResults)
        maxResultLabel.text = "\(maxResults)"
    }
}
