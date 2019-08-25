//
//  ViewController.swift
//  HitList
//
//  Created by Vasilii on 25/08/2019.
//  Copyright © 2019 Vasilii Burenkov. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var people:[NSManagedObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Список"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchReguest = NSFetchRequest<NSManagedObject>(entityName: "Person")
        
        do {
            people = try managedContext.fetch(fetchReguest)
        }  catch let error as NSError {
            print("Не могу прочитать. \(error), \(error.userInfo)")
        }
    }
    
    // через кнопку добавлеяем запись в таблицу
    @IBAction func addName(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Новое имя", message: "Добавьте новое имя", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Сохранить", style: .default) {
            //чтообы ссылка не считалась и не захватывалась unowned self
            [unowned self] (action) in
            guard let textField = alert.textFields?.first, let nameToSave = textField.text else { return }
            
            self.save(name: nameToSave)
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    func save(name: String) {
        //получаем ссылку на делегат приложения
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedContext)!
        let person = NSManagedObject(entity: entity, insertInto: managedContext)
        
        person.setValue(name, forKey: "name")
        
        do {
            try managedContext.save()
            people.append(person)
        } catch let error as NSError {
            print("Не могу записать. \(error), \(error.userInfo)")
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       let person = people[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = person.value(forKey: "name") as? String
        return cell
    }
}
