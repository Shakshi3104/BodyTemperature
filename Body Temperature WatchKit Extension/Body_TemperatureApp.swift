//
//  Body_TempertureApp.swift
//  Body Temperture WatchKit Extension
//
//  Created by Satoshi on 2021/01/23.
//

import SwiftUI

@main
struct Body_TemperatureApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
