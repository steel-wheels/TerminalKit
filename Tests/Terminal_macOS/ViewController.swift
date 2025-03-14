//
//  ViewController.swift
//  Terminal_macOS
//
//  Created by Tomoo Hamada on 2025/03/06.
//

import TerminalKit
import Cocoa

class ViewController: NSViewController
{
        @IBOutlet weak var mTerminalView: TMTerminalView!

        override func viewDidLoad() {
                super.viewDidLoad()

                // Do any additional setup after loading the view.
                let storage = mTerminalView.terminalStorage
                let codes: Array<TMEscapeCode> = [
                        .string("HELLO, WORLD")
                ]
                storage.execute(codes: codes)
        }

        override var representedObject: Any? {
                didSet {
                // Update the view, if already loaded.
                }
        }
}

