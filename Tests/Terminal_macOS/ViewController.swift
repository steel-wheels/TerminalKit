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
        @IBOutlet weak var mTerminalView: MITerminalView!

        override func viewDidLoad() {
                super.viewDidLoad()

                // Do any additional setup after loading the view.
                let storage = mTerminalView.terminalStorage
                storage.setContentsSize(width: 40, height: 20)
                let codes: Array<MIEscapeCode> = [
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

