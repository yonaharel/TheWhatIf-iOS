//
//  Goal + Extensions.swift
//  The What If
//
//  Created by Yona Harel on 04/06/2022.
//

import Foundation
import Shared

extension Goal {
    func getProgress() -> Float {
        Float(progress / target)
    }
}
