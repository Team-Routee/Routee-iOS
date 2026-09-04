//
//  TabBarAppearance.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 9/4/26.
//

enum TabBarVisibility {
    case automatic
    case visible
    case hidden
}

protocol TabBarAppearanceProviding: AnyObject {
    var preferredTabBarVisibility: TabBarVisibility { get }
}

protocol TabBarAppearanceUpdating: AnyObject {
    func updateTabBarAppearance(animated: Bool)
}
