//
//  ToDoViewController.swift
//  ProjectManager
//
//  Created by Max on 2023/09/26.
//

import UIKit
import RxSwift

final class ChildListViewController: UIViewController {
    private let status: ToDoStatus
    private let headerView: ListHeaderView
    private let viewModel: ChildViewModelType
    private let disposeBag = DisposeBag()
    
    let today = Date().timeIntervalSinceReferenceDate
    private let dateFormatter: DateFormatter
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tag = 0
        tableView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.98, alpha: 1)
        return tableView
    }()
    
    init(_ status: ToDoStatus, viewModel: ChildViewModelType, dateFormatter: DateFormatter) {
        self.status = status
        self.headerView = ListHeaderView(status)
        self.dateFormatter = dateFormatter
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.inputs.viewWillAppear()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupBinding()
    }

    private func setupUI() {
        let safeArea = view.safeAreaLayoutGuide
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        
        tableView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressEvent)))
        
        NSLayoutConstraint.activate([
            tableView.widthAnchor.constraint(equalTo: safeArea.widthAnchor),
            tableView.heightAnchor.constraint(equalTo: safeArea.heightAnchor),
            tableView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            tableView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ListTableViewCell.self, forCellReuseIdentifier: status.rawValue)
    }
}

extension ChildListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.outputs.entityList.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: status.rawValue,
                                                       for: indexPath) as?
                ListTableViewCell else { return UITableViewCell() }
        
        let toDoEntity = viewModel.outputs.entityList[indexPath.row]
        let isDone = toDoEntity.status == ToDoStatus.done.rawValue
        let isPast = floor(today/86400) > floor(toDoEntity.dueDate.timeIntervalSinceReferenceDate/86400) && !isDone
        let date = dateFormatter.string(from: toDoEntity.dueDate)
        
        cell.setupUI()
        cell.setModel(title: toDoEntity.title, date: date, body: toDoEntity.body, isPast: isPast)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailViewController = DetailViewController(viewModel.outputs.entityList[indexPath.row])
        let detailViewModel = DetailViewModel()
        detailViewModel.delegate = self.viewModel.delegate
        detailViewController.viewModel = detailViewModel
        let detailNavigation = UINavigationController(rootViewController: detailViewController)
        self.present(detailNavigation, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) ->
    UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: "") { (_, _, success: @escaping (Bool) -> Void) in
            let selectedEntity = self.viewModel.outputs.entityList[indexPath.row]
            self.viewModel.inputs.swipeToDelete(selectedEntity)
        }
        
        delete.backgroundColor = .systemRed
        delete.title = "Delete"
        
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

extension ChildListViewController {
    private func setupBinding() {
        viewModel.outputs.action.subscribe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] action in
                guard let self else { return }
                switch action.type {
                case .create:
                    let index = self.viewModel.outputs.entityList.count - 1
                    self.tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                case .read, .update:
                    self.tableView.reloadData()
                case .delete:
                    guard let indexInformation = action.extraInformation.filter({ $0.key == "index" }).first,
                          let index = indexInformation.value as? Int else { return }
                    self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                }
                
                self.headerView.setupTotalCount(viewModel.outputs.entityList.count)
            }, onError: { [weak self] error in
                let errorType = ProjectManagerError.downcastError(error)
                
                let alertBuilder = AlertBuilder(prefferedStyle: .alert)
                    .setTitle(errorType.alertTitle)
                    .setMessage(errorType.alertMessage)
                    .addAction(.confirm)
                    .build()
                self?.present(alertBuilder, animated: true)
            }).disposed(by: disposeBag)
    }
}

extension ChildListViewController {
    @objc private func longPressEvent(sender: UILongPressGestureRecognizer) {
        let point = sender.location(in: tableView)
        
        guard let indexPath = self.tableView.indexPathForRow(at: point),
              let viewModelDelegate = viewModel as? ChildViewModelDelegate else { return }
        let entity = viewModel.outputs.entityList[indexPath.row]
        let changeStatusViewModel = ChangeStatusViewModel()
        changeStatusViewModel.delegate = viewModelDelegate
        let changeStatusViewController = ChangeStatusViewController(entity, status: status, viewModel: changeStatusViewModel)
        changeStatusViewController.modalPresentationStyle = .popover
        changeStatusViewController.preferredContentSize = CGSize(width: 300, height: 150)
        
        let popOverController = changeStatusViewController.popoverPresentationController
        popOverController?.sourceView = tableView
        popOverController?.sourceRect = CGRect(x: point.x, y: point.y, width: 0, height: 0)
        popOverController?.permittedArrowDirections = .up
        present(changeStatusViewController, animated: true)
        
    }
}

