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
	
	var body: some View {
		VStack {
			HStack {
				Text("URLs:")
				TokenField()
				
				/*TextField("Enter URL", text: $curl.url)
					.keyboardType(.URL)
					.textContentType(.URL)
					.disableAutocorrection(true)
					.autocapitalization(.none)*/
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
	public func makeNSView(context: Context) -> some NSTokenField {
		let tokenField = NSTokenField()
		return tokenField
	}
	
	func updateNSView(_ nsView: NSViewType, context: Context) {
		// Nothing yet
	}
}
