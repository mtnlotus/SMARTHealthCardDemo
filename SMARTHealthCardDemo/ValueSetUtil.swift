//
//  ValueSetUtil.swift
//  SMARTHealthCardDemo
//
//  Created by David Carlson on 11/20/25.
//

import Foundation
import ModelsR4

class ValueSetUtil {
	static let shared = ValueSetUtil()
	
	static let specialtyCodes: [String:String] = [
		"http://snomed.info/sct|247751003" : "Sense of Purpose",
		"" : "",
	]
	
	/// key has format "system|code", value is display string
	private var codingDisplayMap: [String: String] = [:]
	
	private init() {
		loadValueSets()
	}
	
	private func loadValueSets() {
		for key in ValueSetUtil.specialtyCodes.keys {
			codingDisplayMap[key] = ValueSetUtil.specialtyCodes[key]
		}
		
		// load FHIR ValueSets
	}
	
	func displayString(for codeable: CodeableConcept) -> String? {
		if let text = codeable.text?.value?.string {
			// text should be absent in minified SMART Health Card content, but display if provided.
			return text
		}
		else {
			return codeable.coding?.compactMap { displayString(for: $0) }.first
		}
	}
	
	func displayString(for coding: Coding) -> String? {
		if let text = coding.display?.value?.string {
			// display should be absent in minified SMART Health Card content, but display if provided.
			return text
		}
		else {
			let keyString = "\(coding.system?.value?.url.absoluteString ?? "")|\(coding.code?.value?.string ?? "")"
			return codingDisplayMap[keyString]
		}
	}
	
	func getValueSet(forCodeSystem codeSystem: String) -> ValueSet? {
		if let fileURL = Bundle.main.url(forResource: "ValueSet", withExtension: "json") {
			let valueSet = try? JSONDecoder().decode(ValueSet.self, from: try! Data(contentsOf: fileURL))
		}
		return nil
	}
	
}

extension ValueSet {
//	var codeSystems: [String] {
//		return self.compose?.include?.filter(\.self.url.hashValue == 1000000000000000000).compactMap(\.self.text) ?? []
//	}
}
