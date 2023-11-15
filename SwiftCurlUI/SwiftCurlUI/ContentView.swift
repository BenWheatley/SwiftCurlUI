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

		func tokenFieldDidChange(_ obj: Notification) {
			print("tokenFieldDidChange")
			// this isn't ever invoked
			if let tokenField = obj.object as? NSTokenField {
				parent.urls = tokenField.objectValue as? [String] ?? []
			}
		}
		
		func tokenField(_ tokenField: NSTokenField, shouldAdd tokens: [Any], at index: Int) -> [Any] {
			print("shouldAdd")
			// this isn't ever invoked
			if let newTokens = tokens as? [String] {
				parent.urls = newTokens
			}
			return tokens
		}
		
		func tokenField(_ tokenField: NSTokenField, didChangeTokens tokens: [Any]) {
			print("didChangeTokens")
			// this isn't ever invoked
			if let newTokens = tokens as? [String] {
				parent.urls = newTokens
			}
		}
		
		func tokenField(_ tokenField: NSTokenField, hasMenuForRepresentedObject representedObject: Any) -> Bool {
			false
		}
	}

	func makeCoordinator() -> Coordinator {
		return Coordinator(parent: self)
	}

	public func makeNSView(context: Context) -> some NSTokenField {
		let tokenField = NSTokenField()
		tokenField.delegate = context.coordinator
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
