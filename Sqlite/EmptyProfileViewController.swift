//
//  EmptyProfileViewController.swift
//  Sqlite
//
//  Created by National Team on 02.11.2021.
//

import UIKit
import SQLite3

class EmptyProfileViewController: UIViewController {
  @IBOutlet weak var textView: UITextView!
  
    override func viewDidLoad() {
        super.viewDidLoad()

      var query: OpaquePointer?
      let queryString = "SELECT users.email from users INNER JOIN profile on users.id = profile.user_id WHERE profile.user_name IS NULL or profile.avatar is NULL or profile.about_myself is NULL"
      
      if sqlite3_prepare_v2(DB.shared.db, queryString, -1, &query, nil) == SQLITE_OK {
        while sqlite3_step(query) == SQLITE_ROW {
          if let userNamePointer = sqlite3_column_text(query, 0) {
            let userName = String(cString: userNamePointer)
            
            textView.text += "\(userName)\n"
          }
        }
      }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
