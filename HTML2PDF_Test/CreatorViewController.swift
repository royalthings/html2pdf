//
//  CreatorViewController.swift
//  HTML2PDF_Test
//
//  Created by Дмитрий Ага on 6/7/19.
//  Copyright © 2019 Дмитрий Ага. All rights reserved.
//

import UIKit

class CreatorViewController: UIViewController {

    let pathToDocHTMLTemplate = Bundle.main.path(forResource: "Template", ofType: "htm")
    let pathToDocHTMLTemplate2 = Bundle.main.path(forResource: "Template2", ofType: "html")
    
    var docInfo: [String: AnyObject]!
    
    var activityViewController: UIActivityViewController? = nil
    
    let A4PageWidth: CGFloat = 595.2
    let A4PageHeight: CGFloat = 841.8
    
    let textField = UITextField()
    
    var html: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let rightButtonItem = UIBarButtonItem.init(title: "SAVE", style: .done, target: self, action: #selector(rightButtonAction))
        self.navigationItem.rightBarButtonItem = rightButtonItem
        
        let mark = ["#TO#": "Назва установи", "#TO_INDEX#": "Індекс", "#TO_CITY#": "Місто", "#TO_STREET#": "Вулиця", "#TO_BUILDING#": "Будинок"]

        for value in docInfo.values {
            html = renderString(path: value as! String)
        }
        
        
        //        textField.frame = CGRect(x: 16, y: 150, width: 250, height: 32)
        //        textField.borderStyle = .roundedRect
        //        textField.placeholder = "Назва установи"
        //        view.addSubview(textField)
        

//            if html.contains("#TO#") {
//                toTextField.isHidden = false
//                toTextField.frame = CGRect(x: 16, y: 100, width: view.bounds.size.width - 32, height: 32)
//                toTextField.borderStyle = .roundedRect
//                toTextField.placeholder = "Назва установи"
//                view.addSubview(toTextField)
//            }
        
            

        createTextField(mark: mark, key: "#TO#")
        //createTextField(html: html, mark: mark, key: "#TO_INDEX#")
    
    }

    //Create text fields
    func createTextField(mark: [String: String], key: String!) {
        if html.contains(key) {
            textField.borderStyle = .roundedRect
            textField.placeholder = "\(String(describing: mark[key]))"
            view.addSubview(textField)

            textField.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                textField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
                textField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
                textField.heightAnchor.constraint(equalToConstant: 30),
                textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                textField.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 15)
                ])
        }
    }
    
    
    @objc func rightButtonAction(sender: UIBarButtonItem) {
        
        html = html.replacingOccurrences(of: "#TO#", with: textField.text!)
        //html = html.replacingOccurrences(of: "#TO_INDEX#", with: textField.text!)
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
        
        print("open \(outputURL.path)")
        
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
