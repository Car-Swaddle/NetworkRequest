//
//  PocketViewController.swift
//  PocketViewController
//
//  Created by Kyle Kendall on 3/10/19.
//  Copyright © 2019 Kyle. All rights reserved.
//

import UIKit

let effectStyle: UIBlurEffect.Style = .light

final class PocketViewController: UINavigationController {
    
    public var bottomViewControllerHeight: CGFloat = 100 {
        didSet {
            heightConstraint?.constant = bottomViewControllerHeight
            updateAdditionalSafeAreaInsets()
        }
    }
    
    init(rootViewController: UIViewController, bottomViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        self.bottomViewController = bottomViewController
        self.addBottomViewControllerIfNeeded()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public var bottomViewController: UIViewController? {
        didSet {
            if let oldValue = oldValue {
                oldValue.willMove(toParent: nil)
                oldValue.view.removeFromSuperview()
                oldValue.removeFromParent()
            }
            addBottomViewControllerIfNeeded()
            bottomViewController?.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBottomContainerViewControllerIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        bottomContainerViewController.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        bottomViewController?.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        
        print("insets: \(bottomViewController!.view.safeAreaInsets), \(bottomViewController!.additionalSafeAreaInsets)")
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        if view.safeAreaInsets.bottom != suggestedSafeAreaInsetBottom {
            updateAdditionalSafeAreaInsets()
        }
        bottomViewController?.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
//        viewControllers.first?.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)op;//?
        bottomContainerViewController.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        print("insets: \(bottomViewController!.view.safeAreaInsets), \(bottomViewController!.additionalSafeAreaInsets)")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        bottomContainerViewController.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        print("insets: \(bottomViewController!.view.safeAreaInsets), \(bottomViewController!.additionalSafeAreaInsets)")
    }
    
    private func updateAdditionalSafeAreaInsets() {
        additionalSafeAreaInsets = suggestedAdditionalSafeAreaInsets
    }
    
    private var suggestedAdditionalSafeAreaInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: suggestedSafeAreaInsetBottom, right: 0)
    }
    
    private var suggestedSafeAreaInsetBottom: CGFloat {
        return max(bottomViewControllerHeight - safeAreaInsetsMinusAdditional.bottom, view.safeAreaInsets.bottom)
    }
    
    private var heightConstraint: NSLayoutConstraint?
    
    private lazy var bottomContainerViewController: UIViewController = {
        let bottomContainerViewController = UIViewController()
        bottomContainerViewController.view.backgroundColor = .white
        return bottomContainerViewController
    }()
    
    private func addBottomContainerViewControllerIfNeeded() {
        guard bottomContainerViewController.parent == nil else { return }
        addChild(bottomContainerViewController)
        
        bottomContainerViewController.view.layer.shadowOpacity = 0.2
        
        view.addSubview(bottomContainerViewController.view)
        
        bottomContainerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        let c = bottomContainerViewController.view.heightAnchor.constraint(equalToConstant: bottomViewControllerHeight)
        c.isActive = true
        heightConstraint = c
        
        bottomContainerViewController.view.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        bottomContainerViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        bottomContainerViewController.didMove(toParent: self)
        bottomContainerViewController.view.backgroundColor = .clear
        
        let blurEffect = UIBlurEffect(style: effectStyle)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        bottomContainerViewController.view.addSubview(blurEffectView)
        
        blurEffectView.pinFrameToSuperViewBounds()
    }
    
    func addBottomViewControllerIfNeeded() {
        guard let bottomViewController = bottomViewController else { return }
        bottomContainerViewController.addChild(bottomViewController)
        
        bottomContainerViewController.view.addSubview(bottomViewController.view)
        
        bottomViewController.view.translatesAutoresizingMaskIntoConstraints = false
        bottomViewController.view.pinFrameToSuperViewBounds()
        bottomViewController.didMove(toParent: self)
    }
    
}


extension UIViewController {
    
    public var safeAreaInsetsMinusAdditional: UIEdgeInsets {
        return UIEdgeInsets(top: view.safeAreaInsets.top - additionalSafeAreaInsets.top,
                            left: view.safeAreaInsets.left - additionalSafeAreaInsets.left,
                            bottom: view.safeAreaInsets.bottom - additionalSafeAreaInsets.bottom,
                            right: view.safeAreaInsets.right - additionalSafeAreaInsets.right)
    }
    
}

class PushVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton()
        button.addTarget(self, action: #selector(tap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .green
        button.backgroundColor = .blue
        
        view.addSubview(button)
        
        button.setTitle("Button next", for: .normal)
        
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        view.addSubview(tableView)
        
        tableView.pinFrameToSuperViewBounds()
        tableView.backgroundColor = .blue
        
    }
    
    @objc func tap() {
        let vc = UIViewController()
        vc.view.backgroundColor = .red
        
        navigationController?.show(vc, sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! UITableViewCell
        cell.textLabel?.text = "Dude"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor(red: rando(), green: rando(), blue: rando(), alpha: 1.0)
        
        let f = UIView()
        f.translatesAutoresizingMaskIntoConstraints = false
        f.backgroundColor = .green
        
        vc.view.addSubview(f)
        
        f.bottomAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        f.widthAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.widthAnchor).isActive = true
        f.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        navigationController?.show(vc, sender: self)
    }
    
    func rando() -> CGFloat {
        return CGFloat.random(in: 0...1.0)
    }
    
}





extension UIView {
    
    @discardableResult public func pinFrameToSuperViewBounds(insets: UIEdgeInsets = UIEdgeInsets.zero, useSafeArea: Bool = false) -> (top:NSLayoutConstraint, bottom:NSLayoutConstraint, left:NSLayoutConstraint, right:NSLayoutConstraint)? {
        assert(self.superview != nil, "Invalid superview!!!")
        guard let superview = superview else { return nil }
        translatesAutoresizingMaskIntoConstraints = false // TODO: Look into taking this out. But Don't know what it would effect.
        
        let top: NSLayoutConstraint
        let bottom: NSLayoutConstraint
        let left: NSLayoutConstraint
        let right: NSLayoutConstraint
        
        if useSafeArea {
            top = topAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor, constant: insets.top)
            bottom = bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: -insets.bottom)
            left = leadingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leadingAnchor, constant: insets.left)
            right = trailingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.trailingAnchor, constant: -insets.right)
            
            NSLayoutConstraint.activate([top, bottom, left, right])
        } else {
            top = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: superview, attribute: .top, multiplier: 1.0, constant: insets.top)
            bottom = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: superview, attribute: .bottom, multiplier: 1.0, constant: -insets.bottom)
            left = NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: superview, attribute: .left, multiplier: 1.0, constant: insets.left)
            right = NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: superview, attribute: .right, multiplier: 1.0, constant: -insets.right)
            
            
            superview.addConstraint(top)
            superview.addConstraint(bottom)
            superview.addConstraint(left)
            superview.addConstraint(right)
        }
        
        return (top, bottom, left, right)
    }
    
}
