//
//  SMARTHealthCardDemoApp.swift
//  SMARTHealthCardDemo
//
//  Created by David Carlson on 11/14/25.
//

import SwiftUI

@main
struct SMARTHealthCardDemoApp: App {
	
	@State var healthCardModel = HealthCardModel()
	
    var body: some Scene {
        WindowGroup {
            ContentView()
				.environment(healthCardModel)
        }
    }
}
