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

        private var mIsVisible:                 Bool
        private var mState:                     State
        private var mBackgroundColor:           MITextColor

        public init(){
                mIsVisible              = false
                mState                  = .normal
                mBackgroundColor        = .white(false)
        }

        public var isVisible: Bool {
                get      { return mIsVisible }
                set(val) { mIsVisible = val }
        }

        public func generateCode() -> Array<MIEscapeCode> {
                if mIsVisible {
                        let codes: Array<MIEscapeCode> = [
                                .eraceFromCursorWithLength(1)
                        ]
                        return codes
                } else {
                        return []
                }
        }
}
