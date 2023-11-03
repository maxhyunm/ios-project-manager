//
//  HistoryViewController.swift
//  ProjectManager
//
//  Created by Min Hyun on 2023/11/03.
//

import UIKit

class HistoryViewController: UIViewController {
    let viewModel: HistoryViewModel
    private let dateFormatter: DateFormatter
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tag = 0
        tableView.backgroundColor = .white
        return tableView
    }()
    
    init(_ viewModel: HistoryViewModel, dateFormatter: DateFormatter) {
        self.viewModel = viewModel
        self.dateFormatter = dateFormatter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    func setupUI() {
        let safeArea = view.safeAreaLayoutGuide
        view.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.98, alpha: 0.5)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.widthAnchor.constraint(equalTo: safeArea.widthAnchor, constant: -20),
            tableView.heightAnchor.constraint(equalTo: safeArea.heightAnchor, constant: -20),
            tableView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            tableView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(HistoryTableViewCell.self, forCellReuseIdentifier: HistoryTableViewCell.identifier)
    }
}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.entityList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HistoryTableViewCell.identifier, for: indexPath) as?
                HistoryTableViewCell else { return UITableViewCell() }
        
        let entity = viewModel.entityList[indexPath.row]
        let date = dateFormatter.string(from: entity.createdAt)
        
        cell.setupUI()
        cell.setModel(title: entity.title, date: date)
        
        return cell
    }
    
    
}
