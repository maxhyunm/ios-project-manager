//
//  ProjectManager - ToDoListViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
//  Last modified by Max.

import UIKit
import RxSwift

final class BaseListViewController: UIViewController {
    private let viewModel: BaseViewModelType
    private let disposeBag = DisposeBag()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .top
        stackView.spacing = 10
        return stackView
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    init(_ viewModel: BaseViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addChildren()
        setupUI()
        bindConnection()
        setupNavigationBar()
    }
    
    private func bindConnection() {
        NetworkMonitor.shared.isConnected
            .observe(on: MainScheduler.instance)
            .bind { [weak self] isNetworkAvailable in
                if isNetworkAvailable {
                    let connectionIcon = UIAction(title: "ONLINE", image: UIImage(systemName: "powerplug.fill")) { _ in }
                    connectionIcon.image?.withTintColor(.systemGreen)
                    self?.navigationItem.leftBarButtonItem = UIBarButtonItem(primaryAction: connectionIcon)
                } else {
                    let connectionIcon = UIAction(title: "OFFLINE", image: UIImage(systemName: "powerplug")) { _ in }
                    connectionIcon.image?.withTintColor(.systemRed)
                    self?.navigationItem.leftBarButtonItem = UIBarButtonItem(primaryAction: connectionIcon)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func addChildren() {
        ToDoStatus.allCases.forEach { status in
            let childViewModel = viewModel.inputs.addChild(status)
            let childViewController = ChildListViewController(status,
                                                              viewModel: childViewModel,
                                                              dateFormatter: dateFormatter)
            self.addChild(childViewController)
            stackView.addArrangedSubview(childViewController.view)
            
            NSLayoutConstraint.activate([
                childViewController.view.heightAnchor.constraint(equalTo: stackView.heightAnchor),
                childViewController.view.centerYAnchor.constraint(equalTo: stackView.centerYAnchor)
            ])
        }
    }
    
    private func setupUI() {
        let safeArea = view.safeAreaLayoutGuide
        view.backgroundColor = .systemBackground
        stackView.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1)
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.widthAnchor.constraint(equalTo: safeArea.widthAnchor),
            stackView.heightAnchor.constraint(equalTo: safeArea.heightAnchor),
            stackView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        self.title = "Project Manager"
        let addToDo = UIAction(image: UIImage(systemName: "plus")) { [weak self] _ in
            guard let viewModelDelegate = self?.viewModel as? BaseViewModelDelegate else { return }
            let detailViewController = DetailViewController()
            let detailViewModel = DetailViewModel()
            detailViewModel.delegate = viewModelDelegate
            detailViewController.viewModel = detailViewModel
            let detailNavigation = UINavigationController(rootViewController: detailViewController)
            self?.present(detailNavigation, animated: true)
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(primaryAction: addToDo)
    }
}

