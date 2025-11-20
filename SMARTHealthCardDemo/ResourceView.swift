//
//  ResourceView.swift
//  SMARTHealthCardDemo
//
//  Created by David Carlson on 11/19/25.
//

import SwiftUI
import ModelsR4

struct ResourceView: View {
	var resource: Resource
	
    var body: some View {
		VStack(alignment: .leading, spacing: 5) {
			HStack(spacing: 10) {
				if let icon = resource.icon {
					icon
				}
				VStack(alignment: .leading, spacing: 5) {
					Text(resource.title)
						.font(.headline)
					if let subtitle = resource.subtitle {
						Text(subtitle)
							.font(.footnote)
							.foregroundStyle(.secondary)
					}
				}
				Spacer()
			}
			if let value = resource.detail {
				Text(value)
					.multilineTextAlignment(.leading)
			}
			
		}
    }
}

#Preview {
	let condition = Condition(subject: Reference(reference: "resource:0"))
	ResourceView(resource: condition)
}
