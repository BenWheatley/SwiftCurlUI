//
//  ContentView.swift
//  SwiftCurlUI
//
//  Created by Ben Wheatley on 02/11/2023.
//

import SwiftUI

struct CurlView: View {
	@ObservedObject var curl: Curl = Curl()
	@State private var selectedOutput = 0
	@State private var tokenFieldUrls: [String] = []  // A separate state property for TokenField
	
	var body: some View {
		VStack {
			HStack {
				Text("URLs:")
				
				TokenField(urls: $tokenFieldUrls)
					.onChange { newUrls in
		 // Handle changes to the urls property
		 print(newUrls)
	 }
				
				Button {
					curl.urls = tokenFieldUrls
					tokenFieldUrls = ["1"]
					curl.invoke()
				} label: {
					Text("Invoke")
				}
			}
			
			Picker("Console:", selection: $selectedOutput) {
				Text("stdin").tag(0)
				Text("stdout").tag(1)
				Text("stderr").tag(2)
			}
			.pickerStyle(SegmentedPickerStyle())
			
			TextEditor(text: selectedOutput == 0 ? $curl.stdin : selectedOutput == 1 ? $curl.stdout : $curl.stderr)

		}
		.padding()
	}
}

#Preview {
	CurlView()
		.previewDevice(PreviewDevice(rawValue: "Mac"))
}

// MARK: -

struct TokenField: NSViewRepresentable {
	@Binding var urls: [String] {
		didSet {
			print(urls) // this isn't ever invoked
		}
	}

	class Coordinator: NSObject, NSTokenFieldDelegate {
		var parent: TokenField

		init(parent: TokenField) {
			self.parent = parent
		}
		
		@objc func tokenFieldDidEndEditing(sender: NSTokenField) {
			if let tokens = sender.objectValue as? [String] {
				parent.urls = tokens
			}
		}
		
		func tokenField(_ tokenField: NSTokenField, hasMenuForRepresentedObject representedObject: Any) -> Bool {
			false
		}
	}

	func makeCoordinator() -> Coordinator {
		return Coordinator(parent: self)
	}

	public func makeNSView(context: Context) -> NSTokenField {
		let tokenField = NSTokenField()
		tokenField.delegate = context.coordinator
		tokenField.target = context.coordinator
		tokenField.action = #selector(Coordinator.tokenFieldDidEndEditing(sender:))
		return tokenField
	}

	// Update inner NSTokenField's value when the SwiftUI binding changes
	func updateNSView(_ nsView: NSViewType, context: Context) {
		nsView.objectValue = urls
	}
	
	func onChange(_ action: @escaping ([String]) -> Void) -> Self {
		var view = self
		view.onChangeAction = action
		return view
	}
	
	private var onChangeAction: (([String]) -> Void)? {
		get { nil }
		set {
			if let newValue = newValue {
				newValue(urls)
			}
		}
	}
}
