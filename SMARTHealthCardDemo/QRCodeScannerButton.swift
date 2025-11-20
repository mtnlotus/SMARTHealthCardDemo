//
//  QRCodeScannerButton.swift
//  SMARTHealthCardDemo
//
//  Created by David Carlson on 11/19/25.
//

import SwiftUI
import CodeScanner
internal import AVFoundation

struct QRCodeScannerButton: View {
	
	@Environment(HealthCardModel.self) private var healthCardModel
	
    @State private var isPresentingScanner = false

    var body: some View {
		Button(action: {isPresentingScanner = true})
		{
			Text("Scan QR Code")
				.font(.headline)
				.padding()
		}
		.buttonStyle(.borderedProminent)
		.frame(minWidth: 100, maxWidth: .infinity, minHeight: 44)
			
        .sheet(isPresented: $isPresentingScanner) {
			CodeScannerView(codeTypes: [.qr], scanMode: .oncePerCode, scanInterval: 1.0, showViewfinder: true) { response in
                if case let .success(result) = response {
					healthCardModel.numericSerialization = result.string
                    isPresentingScanner = false
                }
            }
        }
    }
}
