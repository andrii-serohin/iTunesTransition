//
//  PlayerView.swift
//  iTunesTransition
//
//  Created by Andrew Seregin on 21.06.2018.
//  Copyright © 2018 Andrew Seregin. All rights reserved.
//

import UIKit

class PlayerView: UIView {
    
    private let imageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "cover"))
        view.layer.shadowOpacity = 0.3
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 3, height: 3)
        view.layer.shadowRadius = 10
        view.layer.cornerRadius = 3
        view.clipsToBounds = true
        return view
    }()
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
        backgroundColor = .white
        addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([imageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
                                     imageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
                                     imageView.heightAnchor.constraint(equalToConstant: 50),
                                     imageView.widthAnchor.constraint(equalToConstant: 50)])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
