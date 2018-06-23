//
//  PlayerTabBarController.swift
//  iTunesTransition
//
//  Created by Andrew Seregin on 21.06.2018.
//  Copyright © 2018 Andrew Seregin. All rights reserved.
//

import UIKit

class PlayerTabBarViewController: UITabBarController {
    
    var player: PlayerView!
    
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
        
        player  = PlayerView()
        player.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(player, belowSubview: tabBar)
        NSLayoutConstraint.activate([player.leftAnchor.constraint(equalTo: view.leftAnchor),
                                     player.rightAnchor.constraint(equalTo: view.rightAnchor),
                                     player.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
                                     player.heightAnchor.constraint(equalToConstant: Constants.playerHeight - tabBar.bounds.height)])
        
        prepareGestureRecognizer()
        interactiveAnimator = PercentInteractiveAnimator(source: player)
        interactiveAnimator?.delegate = self
    }
    
    private func prepareGestureRecognizer() {
        let recognizer = UITapGestureRecognizer(target: self,
                                                action: #selector(handleTap(_:)))
        player.addGestureRecognizer(recognizer)
    }
    
    private func presentTrackDetails() {
        let controller = TrackDetailsViewController()
        controller.transitioningDelegate = self
        controller.modalPresentationStyle = .custom
        controller.modalPresentationCapturesStatusBarAppearance = true
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
}

@objc extension PlayerTabBarViewController {
    
    func handleTap(_ sender: UITapGestureRecognizer) {
        presentTrackDetails()
    }
    
}

extension PlayerTabBarViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator?.isPresenting = true
        return animator
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator?.isPresenting = false
        return animator
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        self.animator = PresentationController(presentedViewController: presented, presenting: presenting)
        return animator
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveAnimator
    }
    
}

extension PlayerTabBarViewController: TrackDetailsViewControllerDelegate {
    
    func trackDetailsViewController(_ viewController: TrackDetailsViewController, whanUpdate progress: CGFloat) {
        
        guard let selectedView = selectedViewController?.view else { return }
        let persent = Constants.statusBarHeight * 1.5 / view.bounds.height
        selectedView.transform = CGAffineTransform.identity.scaledBy(x: scaleFactor + persent * progress,
                                                                     y: scaleFactor + persent * progress)
    }
    
    func dismissThreshold(for: TrackDetailsViewController) -> CGFloat {
        return player.frame.origin.y
    }
    
}

extension PlayerTabBarViewController: PresentInteractiveDelegate {
    
    func percentAnimatorWantInteract(_ animator: PercentInteractiveAnimator) {
        presentTrackDetails()
    }
    
}


