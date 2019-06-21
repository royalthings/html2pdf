//
//  CreatorViewController.swift
//  HTML2PDF_Test
//
//  Created by Дмитрий Ага on 6/7/19.
//  Copyright © 2019 Дмитрий Ага. All rights reserved.
//

import UIKit
import MBProgressHUD

class CreatorViewController: UIViewController {
    
    var activityViewController: UIActivityViewController? = nil
    
    //MARK: - add Outlet
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var myView: UIView!
    
    //MARK: - add variables and constants
    //docs
    fileprivate let pathToDocHTMLTemplate = Bundle.main.path(forResource: "Template", ofType: "htm")
    fileprivate let pathToDocHTMLTemplate2 = Bundle.main.path(forResource: "Template2", ofType: "html")
    
    var docInfo: [String: AnyObject]!
    var html: String = ""
    
    //format A4
    let A4PageWidth: CGFloat = 595.2
    let A4PageHeight: CGFloat = 841.8
    
    var arrayTextFields: [UITextField] = []
    var firstIdentTextField: CGFloat = 15.0
    
    //MARK: - mark array
    let markArray = [["#TO#": "Назва установи"], ["#TO_INDEX#": "Індекс"], ["#TO_CITY#": "Місто"], ["#TO_STREET#": "Вулиця"], ["#TO_BUILDING#": "Будинок"], ["#PERSON#": "Від кого"], ["#PERSON_INDEX#": "Індекс заявника"], ["#PERSON_REGION#": "Область заявника"], ["#PERSON_CITY#": "Місто заявника"], ["#PERSON_STREET#": "Вулиця заявника"], ["#PERSON_BUILDING#": "Будинок заявника"], ["#PERSON_APARTMENT#": "Квартира заявника"], ["#PERSON_ID#": "Ідентифікаційний номер заявника"], ["#NAME#": "ПІБ"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: - add save button - rightBarButtonItem
        let rightButtonItem = UIBarButtonItem.init(title: "SAVE", style: .done, target: self, action: #selector(rightButtonAction))
        self.navigationItem.rightBarButtonItem = rightButtonItem
        
        for value in docInfo.values {
            html = renderString(path: value as! String)
        }
        
        for value in markArray {
            for key in value.keys {
                createTextField(mark: value, key: key)
            }
        }
        
        HideKeyboard()
        
        //MARK: - Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    //MARK: - Create text fields
    @discardableResult func createTextField(mark: [String: String], key: String!) -> UITextField {
        
        let textField = UITextField()
        
        if html.contains(key) {
            textField.borderStyle = .roundedRect
            guard let phString = mark[key] else { return UITextField() }
            textField.placeholder = "\(String(describing: phString))"
            myView.addSubview(textField)
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.delegate = self
            let margins = myView.layoutMarginsGuide
            
            NSLayoutConstraint.activate([
                textField.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
                textField.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
                textField.topAnchor.constraint(equalTo: myView.topAnchor, constant: firstIdentTextField)
                ])
            firstIdentTextField += 38
        }
        arrayTextFields.append(textField)
        return UITextField()
    }
    
    //MARK: - Action
    @objc func rightButtonAction(sender: UIBarButtonItem) {
        
        let fml = UIMarkupTextPrintFormatter(markupText: replacingHtml())
        
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(fml, startingAtPageAt: 0)
        let page = CGRect(x: 0, y: 20, width: A4PageWidth, height: A4PageHeight)
        render.setValue(page, forKey: "paperRect")
        render.setValue(page, forKey: "printableRect")
        
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)
        for i in 0..<render.numberOfPages {
            UIGraphicsBeginPDFPage()
            render.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }
        UIGraphicsEndPDFContext()

        pdfData.write(to: createFile(), atomically: true)
        
        activityViewController = UIActivityViewController(activityItems: [pdfData], applicationActivities: nil)
        present(activityViewController!, animated: true, completion: nil)
    }
    
    //MARK: - replacing mark in string
    fileprivate func replacingHtml() -> String {
        var index = 0
        if index <= markArray.count {
            for value in markArray {
                for key in value.keys {
                    if let textReplacing = arrayTextFields[index].text {
                        let hud = MBProgressHUD.showAdded(to: view, animated: true)
                        hud.label.text = "Загрузка..."
                        DispatchQueue.global(qos: .userInitiated).async {
                            self.html = self.html.replacingOccurrences(of: key, with: textReplacing)
                            index += 1
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(5), execute: {
                                hud.hide(animated: true)
                            })
                        }
                        
                    } else {
                        alertMassage(message: "Нет полей для ввода значений.")
                    }
                }
            }
        }
        return html
    }

    //create file
    fileprivate func createFile() -> URL! {
        let fileManager = FileManager.default
        let fileName = "Документ - \(formatAndGetCurrentDate())"
        
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileName = documentDirectory.appendingPathComponent(fileName)
            let outputURL = fileName.appendingPathExtension("pdf")
            print(outputURL)
            return outputURL
        } catch {
            alertMassage(message: "URL не создан.")
        }
        return nil
    }
    
    //create Current Date
    fileprivate func formatAndGetCurrentDate() -> String {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)
        return timestamp
    }
    
    //create string
    fileprivate func renderString(path: String) -> String! {
        do {
            let HTMLContent = try String(contentsOfFile: path)
            return HTMLContent
        } catch {
            alertMassage(message: "Ошибка открытия HTML файла.")
        }
        return nil
    }
    
    //MARK: - Keyboard
    fileprivate func HideKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func DismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardDidShow(notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)
            myScrollView.contentInset = contentInsets
            myScrollView.scrollIndicatorInsets = contentInsets
        }
    }
    @objc func keyboardWillBeHidden(notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        myScrollView.contentInset = contentInsets
        myScrollView.scrollIndicatorInsets = contentInsets
    }
    
    //MARK: - Alert massage
    fileprivate func alertMassage(message: String) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default) { [weak self] (action) in
            self?.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: UITextField Delegate Methods
extension CreatorViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
