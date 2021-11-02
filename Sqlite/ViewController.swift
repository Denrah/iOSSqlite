//
//  ViewController.swift
//  Sqlite
//
//  Created by National Team on 01.11.2021.
//

import UIKit
import SQLite3

class ViewController: UIViewController {
  @IBOutlet weak var textView: UITextView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    var query: OpaquePointer?
    let queryString = "SELECT profile.user_name, COUNT(user_name) FROM users INNER JOIN messages ON users.id = messages.user_id INNER JOIN profile on users.id = profile.user_id INNER JOIN attachments ON messages.id = attachments.message_id GROUP BY users.id"
    
    if sqlite3_prepare_v2(DB.shared.db, queryString, -1, &query, nil) == SQLITE_OK {
      while sqlite3_step(query) == SQLITE_ROW {
        if let userNamePointer = sqlite3_column_text(query, 0) {
          let usersCountPointer = sqlite3_column_int(query, 1)
          let userName = String(cString: userNamePointer)
          let userCount = Int(usersCountPointer)
          
          textView.text += "\(userName): \(userCount)\n"
        }
      }
    }
  }
}
