//
//  TopicsViewController.swift
//  Sqlite
//
//  Created by National Team on 02.11.2021.
//

import UIKit
import SQLite3

class TagButton: UIButton {
  var onChange: (() -> Void)?
  
  var isChecked: Bool = false {
    didSet {
      if isChecked {
        setTitleColor(.white, for: .normal)
        backgroundColor = .systemBlue
      } else {
        setTitleColor(.systemBlue, for: .normal)
        backgroundColor = .clear
      }
      
      onChange?()
    }
  }
  
  override var intrinsicContentSize: CGSize {
    CGSize(width: super.intrinsicContentSize.width + 16, height: 24)
  }
  
  init() {
    super.init(frame: .zero)
    titleLabel?.font = .systemFont(ofSize: 16)
    layer.cornerRadius = 12
    layer.borderColor = UIColor.systemBlue.cgColor
    layer.borderWidth = 1
    setTitleColor(.systemBlue, for: .normal)
    backgroundColor = .clear
    
    addTarget(self, action: #selector(handleTap), for: .touchUpInside)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @objc private func handleTap() {
    isChecked.toggle()
  }
}

class TopicsViewController: UIViewController {
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var textView: UITextView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    var query: OpaquePointer?
    let queryString = "SELECT topic_title FROM topic"
    
    if sqlite3_prepare_v2(DB.shared.db, queryString, -1, &query, nil) == SQLITE_OK {
      while sqlite3_step(query) == SQLITE_ROW {
        if let topicTitlePointer = sqlite3_column_text(query, 0) {
          let topicTitle = String(cString: topicTitlePointer)
          let button = TagButton()
          button.setTitle(topicTitle, for: .normal)
          button.onChange = { [weak self] in
            self?.search()
          }
          stackView.addArrangedSubview(button)
        }
      }
    }
  }
  
  func search() {
    let topicsArray = stackView.arrangedSubviews.compactMap { $0 as? TagButton }.filter(\.isChecked).compactMap(\.titleLabel?.text).map { "'\($0)'" }
    
    var query: OpaquePointer?
    let queryString = "SELECT tempTable.email, tempTable.user_name, GROUP_CONCAT(topic.topic_title), tempTable.topicsCount FROM (SELECT users.email, profile.user_name, profile.id, COUNT(*) as topicsCount from profile INNER JOIN profile_topic ON profile.id = profile_topic.profile_id INNER JOIN topic ON topic.id = profile_topic.topic_id INNER JOIN users ON profile.user_id = users.id WHERE topic.topic_title IN (\(topicsArray.joined(separator: ","))) GROUP BY profile.id) as tempTable INNER JOIN profile_topic ON tempTable.id = profile_topic.profile_id INNER JOIN topic on profile_topic.topic_id = topic.id GROUP BY tempTable.id HAVING tempTable.topicsCount = \(topicsArray.count)"
    
    textView.text = ""

    if sqlite3_prepare_v2(DB.shared.db, queryString, -1, &query, nil) == SQLITE_OK {
      while sqlite3_step(query) == SQLITE_ROW {
        if let emailPointer = sqlite3_column_text(query, 0),
           let namePointer = sqlite3_column_text(query, 1),
           let topicsPointer = sqlite3_column_text(query, 2) {
          let email = String(cString: emailPointer)
          let name = String(cString: namePointer)
          let topics = String(cString: topicsPointer)

          textView.text += "\(email)(\(name)): \(topics)\n\n"
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
