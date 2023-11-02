//
//  FileMode.swift
//  SwiftCurlUI
//
//  Created by Ben Wheatley on 02/11/2023.
//

import Foundation

struct FileMode { // This probably already exists somehwere (it certainly ought to in macOS!) but google didn't find it
	let owner: Permission
	let group: Permission
	let other: Permission
	
	struct Permission {
		let read: Bool
		let write: Bool
		let execute: Bool
		
		var toOctal: UInt8 {
			(read ? 4 : 0) +
			(write ? 2 : 0) +
			(execute ? 1: 0)
		}
	}
	
	var toString: String {
		"0\(owner.toOctal)\(group.toOctal)\(other.toOctal)"
	}
}
