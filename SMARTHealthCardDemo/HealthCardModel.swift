//
//  HealthCardModel.swift
//  SMARTHealthCardDemo
//
//  Created by David Carlson on 11/19/25.
//

import SwiftUI
import SMARTHealthCard
import class ModelsR4.Resource

@Observable class HealthCardModel {
	
	public init(numericSerialization: String? = nil) {
		self.numericSerialization = numericSerialization
	}
	
	public var numericSerialization: String? {
		didSet {
			if let data = numericSerialization, let jws = try? JWS(fromNumeric: data) {
				self.jws = jws
				self.smartHealthCard = try? JSONDecoder().decode(SMARTHealthCardPayload.self, from: jws.payload)
			}
			else {
				jws = nil
				smartHealthCard = nil
			}
		}
	}
	
	public var jws: JWS?
	
	public var smartHealthCard: SMARTHealthCardPayload?
	
	public var fhirResources: [Resource] {
		smartHealthCard?.vc.credentialSubject.fhirBundle?.entry?.compactMap { $0.resource?.get() } ?? []
	}
	
}
