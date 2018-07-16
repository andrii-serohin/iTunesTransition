//
//  AdditionalViewTabBarController.swift
//  iTunesTransition
//
//  Created by Andrew Seregin on 13.07.2018.
//  Copyright © 2018 cookie. All rights reserved.
//

import Foundation

import UIKit

class AdditionalViewTabBarController: UITabBarController {
    
    private let _additionalView = UIView()
    
    public var additionalView: UIView {
        return _additionalView
    }
    
    var moveOutAnimator: AppleMusicPresentationController?
    var moveOutInteractiveAnimator: AppleMusicPercentDrivenInteractiveAnimator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.barTintColor = .white
        prepareAdditionalView()
        prepareGestureRecognizer()
        prepareInteractiveAnimator()
    }
    
    func prepareInteractiveAnimator() {
        moveOutInteractiveAnimator = AppleMusicPercentDrivenInteractiveAnimator(source: additionalView)
        moveOutInteractiveAnimator?.delegate = self
    }
    
    var flexibleViewController: FlexibleViewController {
        return FlexibleViewController()
    }
    
    final func presentFlexibleViewController() {
        present(preparedFlexibleViewController, animated: true)
    }
    
}

private extension AdditionalViewTabBarController {
    
    var scaleFactor: CGFloat {
        guard let container = view else { return 0 }
        let persent = UIApplication.shared.statusBarFrame.height * 1.5 / container.bounds.height
        return 1 - persent
    }
    
    func prepareAdditionalView() {
        
        view.insertSubview(additionalView, belowSubview: tabBar)
        additionalView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([additionalView.leftAnchor.constraint(equalTo: view.leftAnchor),
                                     additionalView.rightAnchor.constraint(equalTo: view.rightAnchor),
                                     additionalView.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
                                     //TODO: Change to more clever algorithm
                                     additionalView.heightAnchor.constraint(equalToConstant: Constants.playerHeight - tabBar.bounds.height)])
    }
    
    func prepareGestureRecognizer() {
        additionalView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                   action: #selector(handleTap)))
    }
    
    var preparedFlexibleViewController: FlexibleViewController {
        let controller = flexibleViewController
        controller.transitioningDelegate = self
        controller.modalPresentationStyle = .custom
        controller.modalPresentationCapturesStatusBarAppearance = true
        controller.delegate = self
        return controller
    }
    
}

@objc extension AdditionalViewTabBarController {
    
    private func handleTap() {
        presentFlexibleViewController()
    }
    
}


extension AdditionalViewTabBarController: AppleMusicPercentInteractiveAnimatorDelegate {
    
    func appleMusicPercentAnimatorWillInteract(_ animator: AppleMusicPercentDrivenInteractiveAnimator) {
        presentFlexibleViewController()
    }
    
}

extension AdditionalViewTabBarController: FlexibleViewControllerDelegate {
    
    var dismissThreshold: CGFloat {
        return additionalView.frame.origin.y
    }
    
    func flexibleViewController(_ viewController: FlexibleViewController, updateProgress current: CGFloat) {
        guard let selectedView = selectedViewController?.view else { return }
        let persent = UIApplication.shared.statusBarFrame.height * 1.5 / view.bounds.height
        let scale = scaleFactor + persent * current
        selectedView.transform = CGAffineTransform.identity.scaledBy(x: scale,
                                                                     y: scale)
    }

}

extension AdditionalViewTabBarController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        moveOutAnimator?.isPresenting = true
        return moveOutAnimator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        moveOutAnimator?.isPresenting = false
        return moveOutAnimator
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        moveOutAnimator = AppleMusicPresentationController(presentedViewController: presented,
                                                        presenting: presenting)
        return moveOutAnimator
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return moveOutInteractiveAnimator
    }
    
}

