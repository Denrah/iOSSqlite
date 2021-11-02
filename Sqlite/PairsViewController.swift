//
//  PairsViewController.swift
//  Sqlite
//
//  Created by National Team on 02.11.2021.
//

import UIKit
import SQLite3

class PairsViewController: UIViewController {
  @IBOutlet weak var textView: UITextView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    var query: OpaquePointer?
    let queryString = "SELECT * FROM (SELECT ROW_NUMBER() OVER (Order by messages.created_at) as rownumber, profile.user_name, messages.text, messages.created_at, ROW_NUMBER() OVER (Order by messages1.created_at) as rownumber1, profile1.user_name, messages1.text, messages1.created_at FROM messages INNER JOIN messages as messages1 on messages.chat_id == messages1.chat_id INNER JOIN profile ON messages.user_id = profile.user_id INNER JOIN profile as profile1 on messages1.user_id = profile1.user_id WHERE ABS(messages.created_at - messages1.created_at) < 900) WHERE rownumber - rownumber1 = 1"
    
    if sqlite3_prepare_v2(DB.shared.db, queryString, -1, &query, nil) == SQLITE_OK {
      while sqlite3_step(query) == SQLITE_ROW {
        if let userName1Pointer = sqlite3_column_text(query, 1),
           let messageText1Pointer = sqlite3_column_text(query, 2),
           let userName2Pointer = sqlite3_column_text(query, 5),
           let message2ext1Pointer = sqlite3_column_text(query, 6) {
          let date1Pointer = sqlite3_column_int(query, 3)
          let date2Pointer = sqlite3_column_int(query, 7)
          
          let userName1 = String(cString: userName1Pointer)
          let messageText1 = String(cString: messageText1Pointer)
          let date1 = Date(timeIntervalSince1970: TimeInterval(date1Pointer))
          let userName2 = String(cString: userName2Pointer)
          let messageText2 = String(cString: message2ext1Pointer)
          let date2 = Date(timeIntervalSince1970: TimeInterval(date2Pointer))
          
          let formatter = DateFormatter()
          formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
          
          textView.text += "[\(userName1)]\n\(messageText1)\n\(formatter.string(from: date1))\n[\(userName2)]\n\(messageText2)\n\(formatter.string(from: date2))\n\n"
        }
      }
    }
  }
  
}
