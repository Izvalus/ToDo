//
//  ToDoRealmViewController.swift
//  ToDo
//
//  Created by Роман Мироненко on 23.10.2020.
//  Copyright © 2020 Роман Мироненко. All rights reserved.
//

import UIKit
import RealmSwift

class TodoItems: Object {
    
    @objc dynamic var detail = ""
    @objc dynamic var status = "❎"
}

class ToDoRealmViewController: UIViewController {
    
    
    let realm = try! Realm()
    var todoList: Results<TodoItems> {
        get {
            return realm.objects(TodoItems.self)
        }
    }
    
    lazy var customView = View()
    
    var add = UIBarButtonItem()
    
    override func loadView() {
        view = customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "ToDo with Realm"
        customView.tableView.dataSource = self
        customView.tableView.delegate = self
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(action))
        navigationItem.rightBarButtonItem = addButton
    }
    
    @objc func action() {
        let alert = UIAlertController(title: "Add task", message: "Enter a new task", preferredStyle: .alert)
        
        let actionAdd = UIAlertAction(title: "Create", style: .default) { (action) in
            let todoAdd = (alert.textFields?.first)! as UITextField
            let todoItem = TodoItems()
            todoItem.detail = todoAdd.text ?? ""
            todoItem.status = "❎"
            
            try! self.realm.write {
                self.realm.add(todoItem)
                self.customView.tableView.insertRows(at: [IndexPath.init(row: self.todoList.count - 1, section: 0)], with: .automatic)
            }
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        
        alert.addAction(actionCancel)
        alert.addAction(actionAdd)
        alert.addTextField { (textField) in
            
        }
        present(alert, animated: true, completion: nil)
    }
    
    
}

extension ToDoRealmViewController {
    class View: UIView {
        let tableView = setup(UITableView()) {
            $0.tableFooterView = UIView()
            $0.register(ToDoRealmViewController.Cell.self, forCellReuseIdentifier: "Cell")
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        init() {
            super.init(frame: .zero)
            addSubview(tableView)
            setupConstraints()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setupConstraints() {
            NSLayoutConstraint.activate([
                tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
                tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
                tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
                ])
        }
    }
}

extension ToDoRealmViewController {
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

extension ToDoRealmViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ToDoRealmViewController.Cell
        let item = todoList[indexPath.row]
        cell.titleLabel.text = item.detail
        cell.statusLabel.text = "\(item.status)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = todoList[indexPath.row]
        
        try! self.realm.write {
            if item.status == "❎" {
                item.status = "✅"
            } else {
                item.status = "❎"
            }
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = todoList[indexPath.row]
            try! realm.write {
                realm.delete(item)
            }
        }
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}
