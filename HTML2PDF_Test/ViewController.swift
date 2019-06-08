//
//  ViewController.swift
//  HTML2PDF_Test
//
//  Created by Дмитрий Ага on 6/7/19.
//  Copyright © 2019 Дмитрий Ага. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let pathToDocHTMLTemplate = Bundle.main.path(forResource: "Template", ofType: "htm")
    let pathToDocHTMLTemplate2 = Bundle.main.path(forResource: "Template2", ofType: "html")
    
    var docs: [[String: String]] = []
    
    @IBOutlet weak var tableList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let pathToHTML = pathToDocHTMLTemplate, let pathToHTML2 = pathToDocHTMLTemplate2 else { return }
        
        docs = [["ЗАЯВА про встановлення факту смерті": pathToHTML], ["Доверенность": pathToHTML2]]
        
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "idSeguePresentCreator" {
            if let indexPath = tableList.indexPathForSelectedRow {
                let destanationViewController = segue.destination as? CreatorViewController
                destanationViewController?.docInfo = docs[indexPath.row] as [String : AnyObject]
            }
        }
    }
    
    // MARK: UITableView Delegate and Datasource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return docs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "idSegue", for: indexPath)
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "idSegue")
        }
        
        let docKey = docs[indexPath.row].keys
        for value in docKey {
            cell.textLabel?.text = "\(value)"
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "idSeguePresentCreator", sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            docs.remove(at: indexPath.row)
            tableList.reloadData()
            UserDefaults.standard.set(self.docs, forKey: "docs")
        }
    }


}

