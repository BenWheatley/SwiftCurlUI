//
//  Curl.swift
//  SwiftCurlUI
//
//  Created by Ben Wheatley on 02/11/2023.
//

import Foundation

enum Curl { // namespace
	static func invoke() -> String {
		let task = Process()
		task.executableURL = URL(fileURLWithPath: "/usr/bin/curl")
		
		// Specify the command-line arguments
		task.arguments = ["-o", "output.txt", "https://example.com"] // Replace "https://example.com" with your desired URL
		
		// Optionally, you can set the working directory if needed
		task.currentDirectoryPath = "/path/to/your/working/directory"
		
		let pipe = Pipe()
		task.standardOutput = pipe
		
		do {
			try task.run()
			task.waitUntilExit()
			
			let data = pipe.fileHandleForReading.readDataToEndOfFile()
			if let output = String(data: data, encoding: .utf8) {
				print("Output: \(output)")
			}
		} catch {
			print("Error: \(error.localizedDescription)")
		}
		
		return ""
	}
}
