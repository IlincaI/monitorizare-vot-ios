//  Created by Code4Romania

import Foundation
import UIKit

class SectionInformationsViewController: RootViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    // MARK: - iVars
    var presidingOfficer: MVPresidingOfficer?
    var topLabelText: String?
    private var pickerViewSelection: PickerViewSelection?
    @IBOutlet private var formsButtons: [UIButton]!
    @IBOutlet private weak var topLabel: UILabel!
    @IBOutlet private weak var topButton: UIButton!
    @IBOutlet private weak var firstButton: UIButton!
    @IBOutlet private weak var secondButton: UIButton!
    @IBOutlet private weak var thirdButton: UIButton!
    @IBOutlet private weak var fourthButton: UIButton!
    @IBOutlet private weak var fifthButton: UIButton!
    @IBOutlet private weak var sixthButton: UIButton!
    @IBOutlet private weak var pickerContainer: UIView!
    @IBOutlet private weak var pickerView: UIPickerView!

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        setupOutlets()
        presidingOfficer?.resetSectionInformations()
        pickerContainer.isHidden = true
        fifthButton.setTitle("Alege...", with: MVColors.lightGray.color, for: .normal)
        sixthButton.setTitle("Alege...", with: MVColors.lightGray.color, for: .normal)
        
        if let topLabelText = self.topLabelText {
            self.navigationItem.set(title: topLabelText, subtitle: "Informații despre secție")
        }
    }
    
    // MARK: - IBActions
    @IBAction func topRightButtonPressed(_ sender: UIButton) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func firstButtonTapped(_ sender: UIButton) {
        adjustButton(button: sender, selected: true)
        adjustButton(button: secondButton, selected: false)
        presidingOfficer?.medium = "urban"
    }

    @IBAction func secondButtonTapped(_ sender: UIButton) {
        adjustButton(button: sender, selected: true)
        adjustButton(button: firstButton, selected: false)
        presidingOfficer?.medium = "rural"
    }
    
    @IBAction func thirdButtonTapped(_ sender: UIButton) {
        adjustButton(button: sender, selected: true)
        adjustButton(button: fourthButton, selected: false)
        presidingOfficer?.genre = "masculin"
    }
    
    @IBAction func fourthButtonTapped(_ sender: UIButton) {
        adjustButton(button: sender, selected: true)
        adjustButton(button: thirdButton, selected: false)
        presidingOfficer?.genre = "feminin"
    }
    
    @IBAction func fifthButtonTapped(_ sender: UIButton) {
        pickerViewSelection = .sosire
        pickerContainer.isHidden = false
    }
    
    @IBAction func sixthButtonTapped(_ sender: UIButton) {
        pickerViewSelection = .plecare
        pickerContainer.isHidden = false
    }
    
    @IBAction func bottomButtonTapped(_ sender: UIButton) {
        if let pickFormViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PickFormViewController") as? PickFormViewController, let presidingOfficer = self.presidingOfficer {
            pickFormViewController.presidingOfficer = presidingOfficer
            pickFormViewController.topLabelText = presidingOfficer.judet! + " " + String(presidingOfficer.sectie!)
            self.navigationController?.pushViewController(pickFormViewController, animated: true)
        }
    }
    
    @IBAction func pickerButton(_ sender: UIButton) {
        pickerContainer.isHidden = true
        pickerView.selectRow(0, inComponent: 0, animated: false)
        pickerView.selectRow(0, inComponent: 1, animated: false)
    }
    
    // MARK: - Utils
    private func adjustButton(button: UIButton, selected: Bool) {
        if selected {
            button.backgroundColor = MVColors.yellow.color
        } else {
            button.backgroundColor = MVColors.white.color
        }
    }
    
    private func layout() {
        for aButton in formsButtons {
            aButton.layer.defaultCornerRadius(borderColor: MVColors.lightGray.cgColor)
        }
        topButton.layer.defaultCornerRadius(borderColor: MVColors.gray.cgColor)
    }
    
    private func setupOutlets() {
        if let topLabelText = self.topLabelText {
            topLabel.text = topLabelText
        }
    }
    
    private func setupButtonsWithPickerValues() {
        if let presidingOfficer = self.presidingOfficer {
            let arriveHour = presidingOfficer.arriveHour
            let arriveMinute =  presidingOfficer.arriveMinute
            fifthButton.setTitle(arriveHour + ":" + arriveMinute, with: MVColors.black.color, for: .normal)
            
            let leftHour = presidingOfficer.leftHour
            let leftMinute = presidingOfficer.leftMinute
            sixthButton.setTitle(leftHour + ":" + leftMinute, with: MVColors.black.color, for: .normal)
        }
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 24
        }
        return 60
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row < 10 {
            return "0" + String(row)
        }
        return String(row)
    }
    
    // MARK: - UIPickerviewDelegate
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let pickerViewSelection = self.pickerViewSelection {
            switch pickerViewSelection {
            case .sosire:
                if component == 0 {
                    row < 10 ? (presidingOfficer?.arriveHour = "0" + String(row)) : (presidingOfficer?.arriveHour = String(row))
                } else if component == 1 {
                    row < 10 ? (presidingOfficer?.arriveMinute = "0" + String(row)) : (presidingOfficer?.arriveMinute = String(row))
                }
            case .plecare:
                if component == 0 {
                    row < 10 ? (presidingOfficer?.leftHour = "0" + String(row)) : (presidingOfficer?.leftHour = String(row))
                } else if component == 1 {
                    row < 10 ? (presidingOfficer?.leftMinute = "0" + String(row)) : (presidingOfficer?.leftMinute = String(row))
                }
            default:
                break
            }
            setupButtonsWithPickerValues()
        }
    }
    
    
}
