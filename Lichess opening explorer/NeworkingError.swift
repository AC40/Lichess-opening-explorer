//
//  NeworkingError.swift
//  Lichess opening explorer
//
//  Created by AC Richter on 28.05.22.
//

import Foundation

enum NetworkingError: Error {
    case invalidURL
    case serversideError
    case unknownError
}
