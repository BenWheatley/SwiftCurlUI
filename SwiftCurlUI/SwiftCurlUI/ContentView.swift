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
	@State private var tokenFieldUrls: [String] = []  // A separate state property for TokenField
	
	var body: some View {
		VStack {
			HStack {
				Text("URLs:")
				
				TokenField($tokenFieldUrls)
					.frame(maxHeight: 45)
				
				// Example content for token field: https://www.kitsunesoftware.com/images/KitsuneSoftwareLogo2022.png,https://www.kitsunesoftware.com/images/KitsuneSoftwareLogo[1999-2023].png
				Button {
					curl.urls = tokenFieldUrls
					Task.detached {
						await curl.invoke()
					}
					print(curl.stderr)
					print()
				} label: {
					Text("Invoke")
				}
			}
			
			Text("stdin")
			TextEditor(text: $curl.stdin)
			
			Text("stdout")
			TextEditor(text: $curl.stdout)
			
			Text("stderr")
			TextEditor(text: $curl.stderr) // Weird bug: the contents only updates when app loses focus
		}
		.padding()
	}
}

#Preview {
	CurlView()
		.previewDevice(PreviewDevice(rawValue: "Mac"))
}
