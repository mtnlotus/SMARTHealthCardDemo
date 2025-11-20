//
//  Resource+Display.swift
//  SMARTHealthCardDemo
//
//  Created by David Carlson on 11/19/25.
//

import Foundation
import SwiftUI
import ModelsR4

extension Resource {
	var icon: Image? {
		switch type(of: self).resourceType {
		case .condition:
			return Image(systemName: "stethoscope")
		case .goal:
			return Image(systemName: "flag")
		case .immunization:
			return Image(systemName: "cross.vial")
		case .medicationRequest:
			return Image(systemName: "pills.fill")
		case .observation:
			return Image(systemName: "checkmark.rectangle")
		case .patient:
			return Image(systemName: "person")
		default:
			return nil
		}
	}
	
	@objc public var title: String {
		type(of: self).resourceType.rawValue
	}
	
	@objc public var subtitle: String? {
		nil
	}
	
	@objc public var detail: String? {
		nil
	}
	
}

extension Patient {
	
	public override var title: String {
		name?.first?.fullName ?? super.title
	}
	
	public override var subtitle: String? {
		guard let fhirDate = birthDate?.value, let nsDate = try? fhirDate.asNSDate()
		else { return nil }
		
		// Displays date correctly in user's timezone. FHIRDate does not include time components.
		let displayDate = Calendar.current.date(from: .init(timeZone: .current, year: fhirDate.year,
										  month: fhirDate.month != nil ? Int(fhirDate.month!) : nil,
										  day: fhirDate.day != nil ? Int(fhirDate.day!) : nil)) ?? nsDate
		
		let formatter = DateFormatter()
		formatter.dateStyle = .long
		formatter.timeStyle = .none
		return "\(formatter.string(from: displayDate))"
	}
	
}

extension Goal {
	
	public override var title: String {
		super.title
	}
	
	public override var subtitle: String? {
		guard case .date(let fhirDate) = self.start, let nsDate = try? fhirDate.value?.asNSDate()
		else { return nil }
		
		// Displays date correctly in user's timezone. FHIRDate does not include time components.
		let displayDate = Calendar.current.date(from: .init(timeZone: .current, year: fhirDate.value?.year,
										  month: fhirDate.value?.month != nil ? Int(fhirDate.value!.month!) : nil,
										  day: fhirDate.value?.day != nil ? Int(fhirDate.value!.day!) : nil)) ?? nsDate
		
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .none
		return "Starting \(formatter.string(from: displayDate))"
	}
	
	public override var detail: String? {
		description_fhir.displayString ?? super.title
	}
	
}

extension Immunization {
	
	public override var title: String {
		self.vaccineCode.displayString ?? super.title
	}
	
	public override var subtitle: String? {
		guard case .dateTime(let dateTime) = self.occurrence, let nsDate = try? dateTime.value?.asNSDate()
		else { return nil }
		
		let formatter = DateFormatter()
		formatter.dateStyle = .long
		formatter.timeStyle = .none
		formatter.timeZone = Calendar.current.timeZone
		return "\(formatter.string(from: nsDate))"
	}
	
	public override var detail: String? {
		performer?.first?.actor.display?.value?.string
	}
	
}

extension Observation {
	
	public override var title: String {
		self.code.displayString ?? super.title
	}
	
	public override var subtitle: String? {
		guard case .dateTime(let dateTime) = self.effective, let nsDate = try? dateTime.value?.asNSDate()
		else { return nil }
		
		let formatter = DateFormatter()
		formatter.dateStyle = .long
		formatter.timeStyle = .none
		formatter.timeZone = Calendar.current.timeZone
		return "\(formatter.string(from: nsDate))"
	}
	
	public override var detail: String? {
		if let value = value {
			return value.displayString
		}
		else if let obsComponents = component, !obsComponents.isEmpty {
			var componentDisplay = ""
			for component in obsComponents {
				if let codeString = component.code.coding?.first?.code?.value?.string, let valueString = component.value?.displayString {
					componentDisplay += "\(codeString) = \(valueString), "
				}
			}
			return componentDisplay
		}
		else {
			return nil
		}
	}
}

extension Observation.ValueX {
	public var displayString: String? {
		switch self {
		case .quantity(let value):
			return value.displayString
		case .codeableConcept(let value):
			return value.displayString
		case .string(let value):
			return value.value?.string
		case .integer(let value):
			return value.value?.integer.description
		case .boolean(let value):
			return value.value?.bool.description
		default:
			return nil
		}
	}
}

extension ObservationComponent.ValueX {
	public var displayString: String? {
		switch self {
		case .quantity(let value):
			return value.displayString
		case .codeableConcept(let value):
			return value.displayString
		case .string(let value):
			return value.value?.string
		case .integer(let value):
			return value.value?.integer.description
		case .boolean(let value):
			return value.value?.bool.description
		default:
			return nil
		}
	}
}

extension Quantity {
	
	public var displayString: String? {
		guard let displayValue = self.displayValue else { return nil }
		
		return "\(self.comparator?.value?.rawValue ?? "") \(displayValue) \(self.unit?.value?.string ?? "")"
	}
	
	public var displayValue: String? {
		if let value = self.value?.value?.decimal {
			let d = Double(truncating:value as NSNumber)
			let formatter = NumberFormatter()
			formatter.numberStyle = .decimal
			formatter.maximumFractionDigits = d.isLess(than: 1) ? 2 : 1
			return formatter.string(from: NSNumber(value: d))
		}
		return nil
	}
	
}

extension CodeableConcept {
	
	public var displayString: String? {
		if let text = ValueSetUtil.shared.displayString(for: self) {
			return text
		}
		else if let coding = coding?.first {
			return "\(systemDisplay(coding.system) ?? "") \(coding.code?.value?.string ?? "")"
		}
		else {
			return nil
		}
	}
	
	private func systemDisplay(_ system: FHIRPrimitive<FHIRURI>?) -> String? {
		guard let systemURI = system?.value?.url.absoluteString
		else { return nil }
		
		switch systemURI {
		case "http://hl7.org/fhir/sid/cvx":
			return "CVX"
		case "http://loinc.org":
			return "LOINC"
		case "http://snomed.info/sct":
			return "SNOMED"
			
		case "http://hl7.org/fhir/us/pco/CodeSystem/pco-concepts-temporary":
			return "PCO"
		case "http://va.gov/fhir/vco/CodeSystem/well-being":
			return "VCO"
		case "http://va.gov/fhir/us/vco/CodeSystem/well-being-signs":
			return "Well-Being Signs (WBS)"
		default :
			return systemURI
		}
	}
}

extension HumanName {
	
	/// Join the non-empty name parts into a "human-normal" string in the order prefix > given > family > suffix, joined by a space,
	/// **unless** the receiver's `text` is set, in which case the text is returned.
	public var fullName: String? {
		if let text = text?.value?.string {
			return text
		}
		
		var parts = [String]()
		if let prefix = prefix {
			parts.append(contentsOf: prefix.filter { $0.value?.string.count ?? -1 > 0 }.map { $0.value?.string ?? "" })
		}
		if let given = given {
			parts.append(contentsOf: given.filter { $0.value?.string.count ?? -1 > 0 }.map {$0.value?.string ?? "" })
		}
		if let family = family?.value?.string, family.count > 0 {
			parts.append(family)
		}
		if let suffix = suffix {
			parts.append(contentsOf: suffix.filter { $0.value?.string.count ?? -1 > 0 }.map { $0.value?.string ?? "" })
		}
		guard parts.count > 0 else {
			return nil
		}
		return parts.joined(separator: " ")
	}
}
