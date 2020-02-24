//
//  BashTaskManager.swift
//  inspecto
//
//  Created by Kostis on 05/03/2019.
//  Copyright © 2019 silonK. All rights reserved.
//

import Foundation
import Cocoa

public class BashTaskManager: NSObject {

    static var process: Process!
    static var fileToWrite = FileHandle()

    static public func run(with argument: String, completion: @escaping(_ output: Data, _ error: Data, _ status: SKBashTaskStatus) -> Void = { _,_, _  in }) {
        DispatchQueue.global().async {
            process = Process()
            process.launchPath = "/bin/bash"

            process.arguments = ["-c", argument]

            let outpipe = Pipe()
            process.standardOutput = outpipe

            let errorpipe = Pipe()
            process.standardError = errorpipe

            process.launch()
            let outputData = outpipe.fileHandleForReading.readDataToEndOfFile()
            outpipe.fileHandleForReading.closeFile()

            let errorData = errorpipe.fileHandleForReading.readDataToEndOfFile()
            errorpipe.fileHandleForReading.closeFile()

            process.terminationHandler = { _ in
                var status: SKBashTaskStatus
                if errorData.isEmpty {
                    status = SKBashTaskStatus.success(statusCode: process.terminationStatus)
                } else {
                    let errorMessage = String(data: errorData, encoding: .utf8)
                    status = SKBashTaskStatus.error(message: errorMessage ?? "unknown error message", statusCode: process.terminationStatus)
                }
                completion(outputData, errorData, status)
            }

            process.waitUntilExit()
        }
    }

    static public func run(with argument: String, completion: @escaping(String, SKBashTaskStatus) -> Void = { _,_  in }) {
        run(with: argument) { (outputData, errorData, status) in
            let outputString = String(data: outputData, encoding: .utf8) ?? ""
            let errorString = String(data: errorData, encoding: .utf8) ?? ""

            let responseString = outputString.appending(errorString)
            completion(responseString, status)
        }
    }
}
