/*
 * @file MICursor.swift
 * @description Define MICursor class
 * @par Copyright
 *   Copyright (C) 2025 Steel Wheels Project
 */

#if os(OSX)
import  Cocoa
#else   // os(OSX)
import  UIKit
#endif  // os(OSX)
import  MultiUIKit
import MultiDataKit

public class MICursor
{
        public enum State: Int {
                case normal     = 0
                case reverse    = 1
        }

        private var mTextStorage: MITextStorage
        private var mState:       State

        public init(storage strg: MITextStorage){
                mTextStorage    = strg
                mState          = .normal
        }

        public func generateCode() -> Array<MIEscapeCode> {
                let codes: Array<MIEscapeCode> = [

                ]
                return codes
        }
}
