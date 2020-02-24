//
//  TerminationCommandStatus.swift
//  inspecto
//
//  Created by Kostis on 05/03/2019.
//  Copyright © 2019 silonK. All rights reserved.
//

import Foundation

public enum SKBashTaskStatus: Error, Equatable {
    case success
    case error(message: String, statusCode: Int32)
}
