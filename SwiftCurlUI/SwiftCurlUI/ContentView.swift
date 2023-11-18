//
//  ContentView.swift
//  SwiftCurlUI
//
//  Created by Ben Wheatley on 02/11/2023.
//

import SwiftUI
import TokenField

struct CurlView: View {
	@ObservedObject var curl: Curl = Curl()
	@State private var selectedOutput = 0
	@State private var tokenFieldUrls: [String] = []  // A separate state property for TokenField
	
	var body: some View {
		VStack {
			HStack {
				Text("URLs:")
				
				TokenField($tokenFieldUrls)
				
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
