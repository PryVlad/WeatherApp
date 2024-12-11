//
//  WeatherAppApp.swift
//  WeatherApp
//
//  Created by Vladyslav Pryl on 10.12.2024.
//

import SwiftUI

@main
struct WeatherAppApp: App {
    @StateObject var source = WeatherWM()
    var body: some Scene {
        WindowGroup {
            ContentView(weather: source)
        }
    }
}
