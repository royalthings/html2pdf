//
//  CreatorViewController.swift
//  HTML2PDF_Test
//
//  Created by Дмитрий Ага on 6/7/19.
//  Copyright © 2019 Дмитрий Ага. All rights reserved.
//

import UIKit

class CreatorViewController: UIViewController {

    //MARK: - add Outlet
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var myView: UIView!
    
    
    //MARK: - add variables and constants
    //docs
    let pathToDocHTMLTemplate = Bundle.main.path(forResource: "Template", ofType: "htm")
    let pathToDocHTMLTemplate2 = Bundle.main.path(forResource: "Template2", ofType: "html")
    
    var docInfo: [String: AnyObject]!
    
    var activityViewController: UIActivityViewController? = nil
    
    let A4PageWidth: CGFloat = 595.2
    let A4PageHeight: CGFloat = 841.8
    
    
    var arrayTextFields: [UITextField] = []
    var firstIdentTextField: CGFloat = 15.0
    
    //Mark
    let markArray = [["#TO#": "Назва установи"], ["#TO_INDEX#": "Індекс"], ["#TO_CITY#": "Місто"], ["#TO_STREET#": "Вулиця"], ["#TO_BUILDING#": "Будинок"], ["#PERSON#": "Від кого"], ["#PERSON_INDEX#": "Індекс заявника"], ["#PERSON_REGION#": "Область заявника"], ["#PERSON_CITY#": "Місто заявника"], ["#PERSON_STREET#": "Вулиця заявника"], ["#PERSON_BUILDING#": "Будинок заявника"], ["#PERSON_APARTMENT#": "Квартира заявника"], ["#PERSON_ID#": "Ідентифікаційний номер заявника"], ["#NAME#": "ПІБ"]]

    var html: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //add save button - rightBarButtonItem
        let rightButtonItem = UIBarButtonItem.init(title: "SAVE", style: .done, target: self, action: #selector(rightButtonAction))
        self.navigationItem.rightBarButtonItem = rightButtonItem

        for value in docInfo.values {
            html = renderString(path: value as! String)
        }
 
        for value in markArray {
            for key in value.keys {
                createTextField(mark: value, key: key, constant: firstIdentTextField)
             }
        }
        //add scroll view
        myScrollView.contentSize.height = myView.bounds.size.height
        myScrollView.addSubview(myView)
        view.addSubview(myScrollView)
    }

    //Create text fields
    func createTextField(mark: [String: String], key: String!, constant: CGFloat) {
 
        let textField = UITextField()
        
        if html.contains(key) {
            textField.borderStyle = .roundedRect
            guard let phString = mark[key] else { return }
            textField.placeholder = "\(String(describing: phString))"
            myView.addSubview(textField)

            textField.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                textField.leftAnchor.constraint(equalTo: myView.leftAnchor, constant: 16),
                textField.rightAnchor.constraint(equalTo: myView.rightAnchor, constant: -16),
                textField.heightAnchor.constraint(equalToConstant: 30),
                textField.centerXAnchor.constraint(equalTo: myView.centerXAnchor),
                textField.topAnchor.constraint(equalTo: myView.topAnchor, constant: constant)
                ])
            
             firstIdentTextField += 38
        }
        arrayTextFields.append(textField)
    }

    // Action
    @objc func rightButtonAction(sender: UIBarButtonItem) {
        var index = 0
        for value in markArray {
            for key in value.keys {
                html = html.replacingOccurrences(of: key, with: arrayTextFields[index].text!)
                index += 1
            }
        }
        
        
        let fml = UIMarkupTextPrintFormatter(markupText: html)
        
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(fml, startingAtPageAt: 0)
        let page = CGRect(x: 0, y: 0, width: A4PageWidth, height: A4PageHeight)
        render.setValue(page, forKey: "paperRect")
        render.setValue(page, forKey: "printableRect")
        
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)
        for i in 0..<render.numberOfPages {
            UIGraphicsBeginPDFPage()
            render.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }
        UIGraphicsEndPDFContext()
        
        guard let outputURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Документ - \(formatAndGetCurrentDate())").appendingPathExtension("pdf") else {fatalError("Destination URL not created")}
        pdfData.write(to: outputURL, atomically: true)

        
        activityViewController = UIActivityViewController(activityItems: [pdfData], applicationActivities: nil)
        present(activityViewController!, animated: true, completion: nil)
    }
    
    
    
    func formatAndGetCurrentDate() -> String {
        let timestamp = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: .medium, timeStyle: .short)
        return timestamp
    }
    
    func renderString(path: String) -> String! {
        do {
            let HTMLContent = try String(contentsOfFile: path)
            return HTMLContent
        } catch {
            print("Unable to open and use HTML template files.")
        }
        return nil
    }
    
}
