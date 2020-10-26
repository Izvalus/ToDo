//
//  ToDOCoreDataViewController.swift
//  ToDo
//
//  Created by Роман Мироненко on 24.10.2020.
//  Copyright © 2020 Роман Мироненко. All rights reserved.
//

import UIKit
import CoreData

class ToDoCoreDataViewController: UIViewController {
    
     var todo = [NSManagedObject]()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    lazy var context = appDelegate.persistentContainer.viewContext
    
    lazy var customView = View()
    
    override func loadView() {
        view = customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customView.tableView.dataSource = self
        customView.tableView.delegate = self
        customView.addButton.addTarget(self, action: #selector(newTask), for: .touchUpInside)
        customView.tableView.reloadData()
        self.todo = fatch()
    }
    
    @objc func newTask() {
        let alert = UIAlertController(title: "Create a task", message: "Enter a new task in the text field", preferredStyle: .alert)
        let action = UIAlertAction(title: "create", style: .default) { (action) in
            
            guard let textField = alert.textFields?.first,
                let text = textField.text,
                text.isEmpty == false else { return }
            
            self.appendText(text: text)
            self.customView.tableView.reloadData()
        }
        
        let actionCancel = UIAlertAction(title: "cancel", style: .cancel) { _ in }
        
        alert.addTextField { _ in }
        alert.addAction(action)
        alert.addAction(actionCancel)
        present(alert, animated: true, completion: nil)
    }
    
    func appendText(text: String) {
        
        let entity = NSEntityDescription.entity(forEntityName: "Todo", in: context)
        let newTitle = NSManagedObject(entity: entity!, insertInto: context)
        newTitle.setValue(text, forKey: "title")
        newTitle.setValue("❎", forKey: "status")
        
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
        todo.append(newTitle)
    }
    
    func fatch() -> [NSManagedObject] {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Todo")
        do {
            return try context.fetch(request).compactMap({ (element) -> NSManagedObject? in
                element as? NSManagedObject
            })
        } catch {
            return []
        }
    }
}


extension ToDoCoreDataViewController {
    class View: UIView {
        
        let addButton = setup(UIButton()) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setTitle("New", for: .normal)
        }
        
        let tableView = setup(UITableView()) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.tableFooterView = UIView()
            $0.register(ToDoCoreDataViewController.Cell.self, forCellReuseIdentifier: "Cell")
        }
        
        init() {
            super.init(frame: .zero)
            addSubview(tableView)
            addSubview(addButton)
            setupConstraints()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setupConstraints() {
            NSLayoutConstraint.activate([
                addButton.leadingAnchor.constraint(equalTo: leadingAnchor),
                addButton.trailingAnchor.constraint(equalTo: trailingAnchor),
                addButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
                
                tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
                tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor)
                ])
        }
    }
}

extension ToDoCoreDataViewController {
    class Cell: UITableViewCell {
        let titleLabel = setup(UILabel()) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.numberOfLines = 0
        }
        
        let statusLabel = setup(UILabel()) {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            contentView.addSubview(titleLabel)
            contentView.addSubview(statusLabel)
            setupConstraints()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setupConstraints() {
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
                titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                titleLabel.trailingAnchor.constraint(equalTo: statusLabel.leadingAnchor),
                
                statusLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
                statusLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                statusLabel.widthAnchor.constraint(equalToConstant: 30)
                ])
        }
    }
}





extension ToDoCoreDataViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ToDoCoreDataViewController.Cell
        let title = todo[indexPath.row]
        cell.titleLabel.text = title.value(forKey: "title") as? String
        cell.statusLabel.text = title.value(forKey: "status") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = todo[indexPath.row]
            todo.remove(at: indexPath.row)
            context.delete(item)
            try? context.save()
        }
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = todo[indexPath.row]
        
        if item.value(forKey: "status") as? String == "❎" {
            item.setValue("✅", forKey: "status")
            
        } else {
            item.setValue("❎", forKey: "status")
        }
        try? context.save()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
