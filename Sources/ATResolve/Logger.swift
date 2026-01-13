//
//  Logger.swift
//  ATResolve
//
//  Created by Mark @ Germ on 1/13/26.
//

import os

enum ATResolveLogger {
	static func log(_ message: String, component: String) {
		if #available(iOS 14, macOS 11, watchOS 7, tvOS 14, *) {
			Logger(subsystem: "ATResolver", category: component)
				.notice("\(message)")
		}
	}
}
