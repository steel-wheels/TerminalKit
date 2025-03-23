//
//  ViewController.swift
//  Terminal_iOS
//
//  Created by Tomoo Hamada on 2025/03/23.
//

import TerminalKit
import UIKit

class ViewController: UIViewController {

        @IBOutlet weak var mTerminalView: MITerminalView!

        override func viewDidLoad() {
                super.viewDidLoad()

                // Do any additional setup after loading the view.
                let storage = mTerminalView.terminalStorage
                storage.setContentsSize(width: 28, height: 40)
                let codes: Array<MIEscapeCode> = [
                        .string("HELLO, WORLD")
                ]
                storage.execute(codes: codes)
        }


}

