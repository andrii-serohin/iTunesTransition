//
//  TrackDetailsViewController.swift
//  iTunesTransition
//
//  Created by Andrew Seregin on 21.06.2018.
//  Copyright © 2018 Andrew Seregin. All rights reserved.
//

import UIKit

protocol TrackDetailsViewControllerDelegate: class{
    func trackDetailsViewController(_ viewController: TrackDetailsViewController, whanUpdate progress: CGFloat)
    func dismissThreshold(for: TrackDetailsViewController) -> CGFloat
}

class TrackDetailsViewController: UIViewController {
    
    private var scrollUpdater: ScrollUpdater?
    private var panGesture: UIPanGestureRecognizer?
    weak var delegate: TrackDetailsViewControllerDelegate?
    
    private let cover: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "cover"))
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private var isAllowDismisSwipe: Bool {
        return scrollUpdater?.isDismissEnabled ?? true
    }
    
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
        
        header.addTarget(self, action: #selector(handleTap(_:)), for: .touchUpInside)

        prepareGestureRecognizers()
    }
    
    func prepareGestureRecognizers() {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        view.addGestureRecognizer(gesture)
        panGesture = gesture
        panGesture?.delegate = self
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
    
    func shrinkContent() {
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
    
    func expandContent() {
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
    
    private func updatePresentedView(for translation: CGFloat, onProgress value: CGFloat) {
        
        
        let threshold = delegate?.dismissThreshold(for: self) ?? 350
        
        guard translation >= 0 else { return }
//        delegate?.trackDetailsViewController(self, whanUpdate: value)
        view.transform = CGAffineTransform(translationX: 0,
                                           y: elasticTranslation(for: translation))
        
        if translation >= threshold {
            print("if translation >= threshold")
            dismiss(animated: true)
        }
        
    }
    
    private func elasticTranslation(for translation: CGFloat) -> CGFloat {
        
        let threshold: CGFloat = 120
        let factor: CGFloat = 1/2
        
        guard translation >= threshold else {
            return translation * factor
        }
        
        let length = translation - threshold
        let friction = 30 * atan(length / 120) + length / 3
        return friction + (threshold * factor)
        
        
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

@objc extension TrackDetailsViewController {
    
    private func handleTap(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true)
    }
    

    
    private func handlePan(gesture: UIPanGestureRecognizer) {
        
        guard gesture.isEqual(panGesture), isAllowDismisSwipe else { return }
        
        let transition = gesture.translation(in: view)
        let progress = transition.y / (view.frame.height - Constants.playerHeight)

        switch gesture.state {
        case .began:
            guard let scrollView = detectedScrollView else { return }
            scrollUpdater = ScrollUpdater(rootView: self.view, scrollView: scrollView)
        case .changed:
            
            guard isAllowDismisSwipe else { return }
            updatePresentedView(for: transition.y, onProgress: progress)
            
        case .ended:
            
            guard isAllowDismisSwipe else { return }
            
            guard progress > 0.2 else {
                UIView.animate(withDuration: 0.2 + Double(progress) * 0.2,
                               delay: 0,
                               options: .curveEaseInOut,
                               animations: {
                    self.delegate?.trackDetailsViewController(self, whanUpdate: 0)
                    self.view.transform = .identity
                })
                scrollUpdater = nil
                return
            }
            print("dismiss(animated: true)")
            dismiss(animated: true)
            
        default:
            break
        }
        
    }
    
}

extension TrackDetailsViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer.isEqual(panGesture) else { return false }
        return true
    }
    
}
