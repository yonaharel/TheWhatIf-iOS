//
//  Goal + Extensions.swift
//  The What If
//
//  Created by Yona Harel on 04/06/2022.
//

import Foundation

extension Goal {
    func getProgress() -> Float {
        Float(progress / target)
    }
}
