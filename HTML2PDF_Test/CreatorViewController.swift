//
//  CreatorViewController.swift
//  HTML2PDF_Test
//
//  Created by Дмитрий Ага on 6/7/19.
//  Copyright © 2019 Дмитрий Ага. All rights reserved.
//

import UIKit

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
                _ = createTextField(mark: value, key: key)
             }
        }
        //add scroll view
        myScrollView.contentSize.height = myView.bounds.size.height
        myScrollView.addSubview(myView)
        view.addSubview(myScrollView)
        
        HideKeyboard()
        //MARK: - Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        
    
    }

    //MARK: - Create text fields
    func createTextField(mark: [String: String], key: String!) -> UITextField {
 
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
        var index = 0
        for value in markArray {
            for key in value.keys {
                guard let textReplacing = arrayTextFields[index].text else { return }
                html = html.replacingOccurrences(of: key, with: textReplacing)
                index += 1
            }
        }

        let fml = UIMarkupTextPrintFormatter(markupText: html)
        
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
    
        _ = createFile()

        activityViewController = UIActivityViewController(activityItems: [pdfData], applicationActivities: nil)
        present(activityViewController!, animated: true, completion: nil)
    }
    

    //create file
        fileprivate func createFile() {
            let fileManager = FileManager.default
            let fileName = "Документ - \(formatAndGetCurrentDate())"
    
            do {
                let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let fileName = documentDirectory.appendingPathComponent(fileName)
                let outputURL = fileName.appendingPathExtension("pdf")
                print(outputURL)
            } catch {
                print("Destination URL not created")
            }
        }

    //create Current Date
    fileprivate func formatAndGetCurrentDate() -> String {
        let timestamp = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: .medium, timeStyle: .short)
        return timestamp
    }
    
    //create string
    fileprivate func renderString(path: String) -> String! {
        do {
            let HTMLContent = try String(contentsOfFile: path)
            return HTMLContent
        } catch {
            print("Unable to open and use HTML template files.")
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
    @objc func keyboardWillBeHidden(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        myScrollView.contentInset = contentInsets
        myScrollView.scrollIndicatorInsets = contentInsets
    }
    
}

// MARK: UITextField Delegate Methods
extension CreatorViewController: UITextFieldDelegate {
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
