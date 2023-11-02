//
//  Curl.swift
//  SwiftCurlUI
//
//  Created by Ben Wheatley on 02/11/2023.
//

import Foundation

enum Curl { // namespace
	static let curlPath = "/usr/bin/curl" // I could make this a URL, but then the names get all confusion — curlURL etc. don't imply the path of the executable
	
	static func invoke(arguments: [Curl.Argument]) -> String {
		let task = Process()
		task.executableURL = URL(fileURLWithPath: curlPath)
		
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

extension Curl {
	enum Argument {
		case abstractUnixSocket(path: String)
		case altSvc(fileName: String)
		case anyAuth
		case append
		case awsSigV4(provider: String, region: String? = nil, service: String? = nil)
		case basic
		case caNative
		case caCert(file: String)
		case caPath(directory: String)
		case certStatus
		case certType(type: String)
		case cert(certificate: String, password: String? = nil)
		case ciphers(cipherList: String)
		case compressedSsh
		case compressed
		case config(file: String)
		case connectTimeout(seconds: Double)
		case connectTo(host1: String, port1: String, host2: String, port2: String)
		case continueAt(offset: String)
		case cookieJar(filename: String)
		case cookie(dataOrFilename: String)
		case createDirs
		case createFileMode(mode: String)
		case crlf
		case crlFile(file: String)
		case curves(algorithmList: String)
		// Add more cases as needed
	}
}
