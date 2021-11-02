//
//  DB.swift
//  Sqlite
//
//  Created by National Team on 02.11.2021.
//

import Foundation
import SQLite3

struct DB {
  private(set) var db: OpaquePointer?
  
  static var shared = DB()
  
  private init() {
    guard let path = Bundle.main.path(forResource: "db", ofType:"db") else { return }
    if sqlite3_open(path, &db) == SQLITE_OK {
      print("DB Opened")
    } else {
      print("Failed to open db")
    }
  }
}
