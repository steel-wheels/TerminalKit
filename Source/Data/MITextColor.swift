/*
 * @file MITextColor.swift
 * @description Extend MITextColor class
 * @par Copyright
 *   Copyright (C) 2026 Steel Wheels Project
 */

import MultiUIKit
import MultiDataKit
#if os(OSX)
import AppKit
#else
import UIKit
#endif

public extension MITextColor
{
        func toNativeColor() -> MIColor {
                let color:      MIColor
                switch self {
                case .black:            color = MIColor.black
                case .red:              color = MIColor.red
                case .green:            color = MIColor.green
                case .yellow:           color = MIColor.yellow
                case .blue:             color = MIColor.blue
                case .magenta:          color = MIColor.magenta
                case .cyan:             color = MIColor.cyan
                case .white:            color = MIColor.white
                @unknown default:
                        NSLog("[Error] Unknown color at \(#file)")
                        color = MIColor.black
                }
                return color
        }
}
