//
//  ViewController.swift
//  ToDo
//
//  Created by Роман Мироненко on 23.10.2020.
//  Copyright © 2020 Роман Мироненко. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    let titleArray = ["ToDo with Realm", "ToDo with CoreData"]
    
    lazy var customView = View()
    
    override func loadView() {
        view = customView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        customView.tableView.dataSource = self
        customView.tableView.delegate = self
        navigationItem.title = "ToDo"
    }

    

}

extension MainViewController {
    class View: UIView {
        let tableView = setup(UITableView()) {
            $0.tableFooterView = UIView()
            $0.register(MainViewController.Cell.self, forCellReuseIdentifier: "Cell")
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        init() {
            super.init(frame: .zero)
            backgroundColor = .black
            tableView.backgroundColor = .black
            
            addSubview(tableView)
            setupConstaints()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setupConstaints() {
            NSLayoutConstraint.activate([
                tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
                tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
                ])
        }
    }
}

extension MainViewController {
    final class Cell: UITableViewCell {
        let titleLabel = setup(UILabel()) {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            backgroundColor = .lightGray
            accessoryType = .disclosureIndicator
            contentView.addSubview(titleLabel)
            setupConstrain()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setupConstrain() {
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
                titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
                ])
        }
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            navigationController?.pushViewController(ToDoRealmViewController(), animated: true)
        } else {
            navigationController?.pushViewController(ToDoCoreDataViewController(), animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MainViewController.Cell
        cell.titleLabel.text = titleArray[indexPath.row]
        
        
        return cell
    }
    
    
}
