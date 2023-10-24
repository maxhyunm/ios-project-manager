//
//  DetailViewController.swift
//  ProjectManager
//
//  Created by Min Hyun on 2023/10/24.
//

import UIKit

class DetailViewController: UIViewController {
    var viewModel: ToDoListBaseViewModelDelegate?
        var editable: Bool = true {
            didSet {
                toggleEditable()
            }
        }
        var data: ToDo?
        
        private let titleField: UITextField = {
            let textField = UITextField()
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.placeholder = "Title"
            textField.font = .preferredFont(forTextStyle: .title3)
            textField.borderStyle = .none
            textField.layer.shadowColor = UIColor.black.cgColor
            textField.layer.shadowOffset = CGSize(width: 0, height: 5)
            textField.layer.shadowOpacity = 0.3
            textField.layer.shadowRadius = 5.0
            textField.backgroundColor = .white
            
            return textField
        }()
        
        private let datePicker: UIDatePicker = {
            let datePicker = UIDatePicker()
            datePicker.translatesAutoresizingMaskIntoConstraints = false
            datePicker.datePickerMode = .date
            datePicker.locale = .current
            datePicker.preferredDatePickerStyle = .wheels
            
            return datePicker
        }()
        
        private let bodyField: UITextView = {
            let textView = UITextView()
            textView.translatesAutoresizingMaskIntoConstraints = false
            textView.layer.masksToBounds = false
            textView.layer.shadowColor = UIColor.black.cgColor
            textView.layer.shadowOffset = CGSize(width: 0, height: 5)
            textView.layer.shadowOpacity = 0.3
            textView.layer.shadowRadius = 5.0
            textView.backgroundColor = .white
            
            return textView
        }()
        
        init(_ data: ToDo? = nil) {
            self.data = data
            super.init(nibName: nil, bundle: nil)
            
            if let data {
                self.editable = false
                setupData(data)
            }
            toggleEditable()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            setupNavigationBar()
            setupDelegate()
        }
        
        func setupUI() {
            let safeArea = view.safeAreaLayoutGuide
            view.backgroundColor = .systemBackground
            
            view.addSubview(titleField)
            view.addSubview(datePicker)
            view.addSubview(bodyField)
            
            NSLayoutConstraint.activate([
                titleField.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 10),
                titleField.widthAnchor.constraint(equalTo: safeArea.widthAnchor, constant: -20),
                titleField.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
                datePicker.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 10),
                datePicker.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
                bodyField.topAnchor.constraint(equalTo: datePicker.bottomAnchor, constant: 10),
                bodyField.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
                bodyField.widthAnchor.constraint(equalTo: safeArea.widthAnchor, constant: -20),
                bodyField.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -10)
            ])
        }
        
        func setupNavigationBar() {
            self.navigationItem.title = "TODO"
            self.navigationController?.navigationBar.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.98, alpha: 1)
            
            let doneAction = UIAction(title: "Done") { [weak self] _ in
                guard let self else { return }
                self.viewModel?.touchUpDoneButton(data, values: [KeywordArgument(key: "title", value: titleField.text),
                                                            KeywordArgument(key: "body", value: bodyField.text),
                                                            KeywordArgument(key: "dueDate", value: datePicker.date)])
                
                self.dismiss(animated: true)
            }
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(primaryAction: doneAction)
        }
        
        
        
        func setupData(_ data: ToDo) {
            self.titleField.text = data.title
            self.datePicker.date = data.dueDate
            self.bodyField.text = data.body
        }
        
        func toggleEditable() {
            if editable {
                let cancelAction = UIAction(title: "Cancel") { [weak self] _ in
                    guard let self else { return }
                    self.dismiss(animated: true)
                }
                navigationItem.leftBarButtonItem = UIBarButtonItem(primaryAction: cancelAction)
                datePicker.isUserInteractionEnabled = true
            } else {
                let editAction = UIAction(title: "Edit") { [weak self] _ in
                    guard let self else { return }
                    self.editable = true
                }
                navigationItem.leftBarButtonItem = UIBarButtonItem(primaryAction: editAction)
                datePicker.isUserInteractionEnabled = false
            }
        }
    }

    extension DetailViewController: UITextFieldDelegate, UITextViewDelegate {
        func setupDelegate() {
            titleField.delegate = self
            bodyField.delegate = self
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            return editable
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            return editable
        }
}
