//
//  NavigationTitleView.swift
//  ProjectManager
//
//  Created by Max on 2023/11/02.
//

import UIKit

class NavigationTitleView: UIView {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Project Manager"
        label.textColor = .black
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()
    
    let wifiIcon: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(systemName: "wifi")
        image.tintColor = .systemBlue
        return image
    }()
    
    init() {
        super.init(frame: .init())
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        self.addSubview(titleLabel)
        self.addSubview(wifiIcon)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            titleLabel.rightAnchor.constraint(equalTo: wifiIcon.leftAnchor, constant: -10),
            wifiIcon.heightAnchor.constraint(equalTo: titleLabel.heightAnchor, constant: -10),
            wifiIcon.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            wifiIcon.rightAnchor.constraint(equalTo: self.rightAnchor)
        ])
    }
    
    func toggleIcon(isOnline: Bool) {
        if isOnline {
            wifiIcon.image = UIImage(systemName: "wifi")
            wifiIcon.tintColor = .systemBlue
        } else {
            wifiIcon.image = UIImage(systemName: "wifi.slash")
            wifiIcon.tintColor = .systemRed
        }
    }
}
