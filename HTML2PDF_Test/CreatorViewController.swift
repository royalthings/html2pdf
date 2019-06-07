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
    let pathToDocHTMLTemplate2 = Bundle.main.path(forResource: "Template2", ofType: "htm")
    
    var docInfo: [String: AnyObject]!
    
    
    
    let A4PageWidth: CGFloat = 595.2
    let A4PageHeight: CGFloat = 841.8
    let toTextField = UITextField()
    var html: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toTextField.isHidden = true
        
        let rightButtonItem = UIBarButtonItem.init(title: "SAVE", style: .done, target: self, action: #selector(rightButtonAction))
        self.navigationItem.rightBarButtonItem = rightButtonItem
        
        let mark = "#TO#"
        
        html = renderString(path: pathToDocHTMLTemplate!)
        
        if html.contains(mark) {
            toTextField.isHidden = false
            toTextField.frame = CGRect(x: 20, y: 100, width: 250, height: 32)
            toTextField.borderStyle = .roundedRect
            toTextField.placeholder = "Назва"
            view.addSubview(toTextField)
            
            
        }
    }

    @objc func rightButtonAction(sender: UIBarButtonItem) {
        
        html = html.replacingOccurrences(of: "#TO#", with: toTextField.text!)
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
