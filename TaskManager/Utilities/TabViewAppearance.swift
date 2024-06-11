//
//  TabViewAppearance.swift
//  TaskManager
//
//  Created by Linus Ilbratt on 2024-06-05.
//

import SwiftUI

struct TabViewAppearance {
    
    static func setupAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black

        let selectedAppearance = UITabBarItemAppearance()
        selectedAppearance.normal.iconColor = UIColor.white
        selectedAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        selectedAppearance.selected.iconColor = UIColor.cyan
        selectedAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.cyan]
        
        appearance.stackedLayoutAppearance = selectedAppearance
        appearance.inlineLayoutAppearance = selectedAppearance
        appearance.compactInlineLayoutAppearance = selectedAppearance

        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

