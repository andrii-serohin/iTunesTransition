//
//  TrackDetailsViewController.swift
//  iTunesTransition
//
//  Created by Andrew Seregin on 21.06.2018.
//  Copyright © 2018 Andrew Seregin. All rights reserved.
//

import UIKit

protocol TrackDetailsViewControllerDelegate: class {
    func trackDetailsViewController(_ viewController: TrackDetailsViewController, whanUpdate progress: CGFloat)
    func dismissThreshold(for: TrackDetailsViewController) -> CGFloat
}

class TrackDetailsViewController: FlexibleViewController {
    
    private let cover: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "cover"))
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var scroll: UIScrollView = {
        let scroll = UIScrollView(frame: view.bounds)
        scroll.contentSize = CGSize(width: view.bounds.width, height: view.bounds.height * 10)
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private var coverTopConstraint: NSLayoutConstraint?
    private var coverLeftConstraint: NSLayoutConstraint?
    private var coverWidthConstraint: NSLayoutConstraint?
    private var coverHeightConstraint: NSLayoutConstraint?
    
    private var headerTopConstraint: NSLayoutConstraint?
    private var headerLeftConstraint: NSLayoutConstraint?
    private var headerWidthConstraint: NSLayoutConstraint?
    private var headerHeightConstraint: NSLayoutConstraint?
    
    private let header: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 2
        button.backgroundColor = UIColor.lightGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(scroll)
        scroll.addSubview(cover)
        scroll.addSubview(header)

        prepareConstreints()
        
        header.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }
    
    func prepareConstreints() {
        
        coverTopConstraint = cover.topAnchor.constraint(equalTo: scroll.topAnchor, constant: 10)
        coverLeftConstraint = cover.leftAnchor.constraint(equalTo: scroll.leftAnchor, constant: 20)
        coverWidthConstraint = cover.widthAnchor.constraint(equalToConstant: 50)
        coverHeightConstraint = cover.heightAnchor.constraint(equalToConstant: 50)
        
        headerTopConstraint = header.topAnchor.constraint(equalTo: scroll.topAnchor, constant: 0)
        headerLeftConstraint = header.leftAnchor.constraint(equalTo: scroll.leftAnchor, constant: 0)
        headerWidthConstraint = header.widthAnchor.constraint(equalToConstant: 0)
        headerHeightConstraint = header.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([coverTopConstraint,
                                     coverLeftConstraint,
                                     coverWidthConstraint,
                                     coverHeightConstraint,
                                     headerTopConstraint,
                                     headerLeftConstraint,
                                     headerHeightConstraint,
                                     headerWidthConstraint,
                                     scroll.topAnchor.constraint(equalTo: view.topAnchor),
                                     scroll.leftAnchor.constraint(equalTo: view.leftAnchor),
                                     scroll.widthAnchor.constraint(equalTo: view.widthAnchor),
                                     scroll.heightAnchor.constraint(equalTo: view.heightAnchor)].compactMap { $0 })
    }
    
    override func onShrink() {
        header.isHidden = true
        cover.layer.cornerRadius = 3
        
        coverTopConstraint?.constant = 10
        coverLeftConstraint?.constant = 20
        coverWidthConstraint?.constant = 50
        coverHeightConstraint?.constant = 50
        
        headerLeftConstraint?.constant = 0
        headerTopConstraint?.constant = 0
        headerHeightConstraint?.constant = 0
        headerWidthConstraint?.constant = 0
    }
    
    
    
    override func onExpand() {
        header.isHidden = false
        headerLeftConstraint?.constant = (view.bounds.width - 100) / 2
        headerTopConstraint?.constant = 10
        headerHeightConstraint?.constant = 5
        headerWidthConstraint?.constant = 100
        
        let coverWidth = view.bounds.width * 0.8
        cover.layer.cornerRadius = 8
        
        coverTopConstraint?.constant = 40
        coverLeftConstraint?.constant = (view.bounds.width - coverWidth) / 2
        coverWidthConstraint?.constant = coverWidth
        coverHeightConstraint?.constant = coverWidth
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

@objc extension TrackDetailsViewController {
    
    private func handleTap() {
        dismiss(animated: true)
    }
    
}

