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
        func toNativeColor() -> (Bool, MIColor) {
                let isfg:       Bool
                let color:      MIColor
                switch self {
                case .black(let fg):    isfg = fg ; color = MIColor.black
                case .red(let fg):      isfg = fg ; color = MIColor.red
                case .green(let fg):    isfg = fg ; color = MIColor.green
                case .yellow(let fg):   isfg = fg ; color = MIColor.yellow
                case .blue(let fg):     isfg = fg ; color = MIColor.blue
                case .magenta(let fg):  isfg = fg ; color = MIColor.magenta
                case .cyan(let fg):     isfg = fg ; color = MIColor.cyan
                case .white(let fg):    isfg = fg ; color = MIColor.white
                @unknown default:
                        NSLog("[Error] Unknown color at \(#file)")
                        isfg = true ; color = MIColor.black
                }
                return (isfg, color)
        }
}
