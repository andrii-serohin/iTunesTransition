//
//  AppleMusicPresentationController.swift
//  iTunesTransition
//
//  Created by Andrew Seregin on 21.06.2018.
//  Copyright © 2018 Andrew Seregin. All rights reserved.
//

import UIKit

class AppleMusicPresentationController: UIPresentationController {
    
    var isPresenting = false
    
    var tabBarSnapshot: UIView?
    private var snapshotConstraint: NSLayoutConstraint?
    
    private var presentedControllerHeightConstraint: NSLayoutConstraint?
    private var presentedControllerTopConstraint: NSLayoutConstraint?

    private var scaleFactor: CGFloat {
        guard let container = containerView else { return 0 }
        let persent = UIApplication.shared.statusBarFrame.height * 1.5 / container.bounds.height
        return 1 - persent
    }
    
    private var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.0
        return view
    }()
    
    override func presentationTransitionWillBegin() {
        
        guard let containerView = containerView, let window = containerView.window else { return }
        
        guard let coordinator = presentedViewController.transitionCoordinator else { return }
        
        containerView.addSubview(dimmingView)
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([dimmingView.leftAnchor.constraint(equalTo: window.leftAnchor),
                                     dimmingView.topAnchor.constraint(equalTo: window.topAnchor),
                                     dimmingView.rightAnchor.constraint(equalTo: window.rightAnchor),
                                     dimmingView.bottomAnchor.constraint(equalTo: window.bottomAnchor)])
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.5
        })
        
    }
    
    override func dismissalTransitionWillBegin() {
        
        guard let coordinator = presentedViewController.transitionCoordinator else { return }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.0
        }, completion: { context in
            guard context.isCancelled else {
                self.dimmingView.removeFromSuperview()
                return
            }
        })
    }
    
}

extension AppleMusicPresentationController: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Constants.Animation.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        guard let flexibleViewController = presentedViewController as? FlexibleViewController else { return }
        guard let additionalViewTabBarController = presentingViewController as? AdditionalViewTabBarController else { return }
        
        guard isPresenting else {
            return animateShrinkTransition(using: transitionContext,
                                           for: flexibleViewController,
                                           on: additionalViewTabBarController)
        }
        
        animateExpandTransition(using: transitionContext,
                                for: flexibleViewController,
                                on: additionalViewTabBarController)
        

        
    }
}

private extension AppleMusicPresentationController {
    
    func animateShrinkTransition(using transitionContext: UIViewControllerContextTransitioning,
                                         for flexibleViewController: FlexibleViewController,
                                         on additionalViewTabBarController: AdditionalViewTabBarController) {
        
        UIView.animate(withDuration: Constants.Animation.duration,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut,
                       animations: {
                        
                        additionalViewTabBarController.view.layer.cornerRadius = 0
                        additionalViewTabBarController.view.transform = .identity
                        additionalViewTabBarController.selectedViewController?.view.frame = self.frameOfPresentedViewInContainerView
                        
                        flexibleViewController.onShrink()
                        self.presentedView?.layer.cornerRadius = 0
                        self.snapshotConstraint?.constant = 0
                        self.presentedControllerHeightConstraint?.constant = Constants.playerHeight
                        self.presentedControllerTopConstraint?.constant = additionalViewTabBarController.additionalView.frame.origin.y - flexibleViewController.view.transform.ty
                        additionalViewTabBarController.additionalView.isHidden = true
                        self.containerView?.layoutIfNeeded()
                        
        }, completion: { isCompleted in
            if !transitionContext.transitionWasCancelled {
                self.tabBarSnapshot?.removeFromSuperview()
                self.tabBarSnapshot = nil
                additionalViewTabBarController.additionalView.isHidden = false
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
        
    }
    
    func animateExpandTransition(using transitionContext: UIViewControllerContextTransitioning,
                                         for flexibleViewController: FlexibleViewController,
                                         on additionalViewTabBarController: AdditionalViewTabBarController) {
        
        guard let presentedView = presentedView else { return }
        guard let containerView = containerView else { return }
        
        containerView.addSubview(presentedView)
        presentedView.translatesAutoresizingMaskIntoConstraints = false
        
        let deltaY = containerView.bounds.height - additionalViewTabBarController.tabBar.bounds.height - additionalViewTabBarController.additionalView.bounds.height
        presentedControllerTopConstraint = presentedView.topAnchor.constraint(equalTo: containerView.topAnchor,
                                                                              constant: deltaY)
        presentedControllerHeightConstraint = presentedView.heightAnchor.constraint(equalToConstant: Constants.playerHeight)
        
        NSLayoutConstraint.activate([presentedView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
                                     presentedView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
                                     presentedControllerTopConstraint,
                                     presentedControllerHeightConstraint].compactMap{ $0 })
        
        
        tabBarSnapshot = additionalViewTabBarController.tabBar.snapshot
        tabBarSnapshot.flatMap {
            containerView.addSubview($0)
        }
        
        tabBarSnapshot?.translatesAutoresizingMaskIntoConstraints = false
        
        snapshotConstraint = tabBarSnapshot?.bottomAnchor.constraint(equalTo: additionalViewTabBarController.tabBar.bottomAnchor)
        NSLayoutConstraint.activate([tabBarSnapshot?.leftAnchor.constraint(equalTo: containerView.leftAnchor),
                                     tabBarSnapshot?.rightAnchor.constraint(equalTo: containerView.rightAnchor),
                                     tabBarSnapshot?.heightAnchor.constraint(equalTo: additionalViewTabBarController.tabBar.heightAnchor),
                                     snapshotConstraint].compactMap{ $0 })
        
        containerView.layoutIfNeeded()
        
        UIView.animate(withDuration: Constants.Animation.duration,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut,
                       animations: {
                        
                        additionalViewTabBarController.selectedViewController?.view.layer.cornerRadius = 10
                        additionalViewTabBarController.selectedViewController?.view.clipsToBounds = true
                        
                        let translatY = 20 - containerView.bounds.height * 0.05 / 2
                        let transform = additionalViewTabBarController.selectedViewController?.view.transform ?? .identity
                        additionalViewTabBarController.selectedViewController?.view.transform = transform.scaledBy(x: self.scaleFactor,
                                                                                                                   y: self.scaleFactor).translatedBy(x: 0,
                                                                                                                                                     y: translatY)
                        
                        self.snapshotConstraint?.constant = self.tabBarSnapshot!.bounds.height
                        
                        flexibleViewController.onExpand()
                        self.presentedControllerHeightConstraint?.constant = containerView.bounds.height - Constants.musicDetailsTopPadding
                        self.presentedControllerTopConstraint?.constant = Constants.musicDetailsTopPadding
                        containerView.layoutIfNeeded()
                        presentedView.layer.cornerRadius = 10
                        presentedView.clipsToBounds = true
                        
        }, completion: { isCompleted in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
        
    }
    
}
