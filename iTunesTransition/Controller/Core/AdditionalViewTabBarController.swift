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
    
    var animator: PresentationController?
    var interactiveAnimator: PercentInteractiveAnimator?
    
    private var scaleFactor: CGFloat {
        guard let container = view else { return 0 }
        let persent = Constants.statusBarHeight * 1.5 / container.bounds.height
        return 1 - persent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.barTintColor = .white
        prepareAdditionalView()
        prepareGestureRecognizer()
        prepareInteractiveAnimator()
    }

    private func prepareAdditionalView() {
        
        view.insertSubview(additionalView, belowSubview: tabBar)
        additionalView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([additionalView.leftAnchor.constraint(equalTo: view.leftAnchor),
                                     additionalView.rightAnchor.constraint(equalTo: view.rightAnchor),
                                     additionalView.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
                                     //TODO: Change to more clever algorithm
            additionalView.heightAnchor.constraint(equalToConstant: Constants.playerHeight - tabBar.bounds.height)])
    }
    
    private func prepareGestureRecognizer() {
        additionalView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                   action: #selector(handleTap)))
    }
    
    func prepareInteractiveAnimator() {
        interactiveAnimator = PercentInteractiveAnimator(source: additionalView)
        interactiveAnimator?.delegate = self
    }
    
    var flexibleViewController: FlexibleViewController {
        return FlexibleViewController()
    }
    
    private var preparedFlexibleViewController: FlexibleViewController {
        let controller = flexibleViewController
        controller.transitioningDelegate = self
        controller.modalPresentationStyle = .custom
        controller.modalPresentationCapturesStatusBarAppearance = true
        controller.delegate = self
        return controller
    }
    
    final func presentFlexibleViewController() {
        present(preparedFlexibleViewController, animated: true)
    }
    
}

@objc extension AdditionalViewTabBarController {
    
    private func handleTap() {
        presentFlexibleViewController()
    }
    
}

extension AdditionalViewTabBarController: PercentInteractiveDelegate {
    
    func percentAnimatorWantInteract(_ animator: PercentInteractiveAnimator) {
        presentFlexibleViewController()
    }
    
}

extension AdditionalViewTabBarController: FlexibleViewControllerDelegate {
    
    var dismissThreshold: CGFloat {
        return additionalView.frame.origin.y
    }
    
    func flexibleViewController(_ viewController: FlexibleViewController, updateProgress current: CGFloat) {
        guard let selectedView = selectedViewController?.view else { return }
        let persent = Constants.statusBarHeight * 1.5 / view.bounds.height
        let scale = scaleFactor + persent * current
        selectedView.transform = CGAffineTransform.identity.scaledBy(x: scale,
                                                                     y: scale)
    }

}

extension AdditionalViewTabBarController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator?.isPresenting = true
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator?.isPresenting = false
        return animator
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        animator = PresentationController(presentedViewController: presented,
                                          presenting: presenting)
        return animator
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveAnimator
    }
    
}

