//
//  HistoryTableViewCell.swift
//  ProjectManager
//
//  Created by Min Hyun on 2023/11/03.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    static let identifier = "History"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .gray
        label.numberOfLines = 3
        return label
    }()

    func setupUI() {
        self.backgroundColor = .white
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9),
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10),
            dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            dateLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func setModel(title: String, date: String) {
        titleLabel.text = title
        dateLabel.text = date
    }
    
    override func prepareForReuse() {
        titleLabel.textColor = .black
        dateLabel.textColor = .gray
        titleLabel.text = ""
        dateLabel.text = ""
    }
}
