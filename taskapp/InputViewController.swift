//
//  InputViewController.swift
//  taskapp
//
//  Created by 小林真理子 on 2017/03/02.
//  Copyright © 2017年 小林真理子. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryTextField: UITextField!
    let realm = try! Realm()
    var task: Task!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        //dismissKeyboardメソッドって、画面背景のタップジェスチャーを認識したらキーボードを閉じるってことかな？
        self.view.addGestureRecognizer(tapGesture) //レコナイザー(認識装置)
        
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date as Date
        categoryTextField.text = task.category
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //遷移する際に、画面が非表示になるとき呼ばれるメソッド(Disappear;消失する)
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date as NSDate
            self.task.category = self.categoryTextField.text!
            self.realm.add(self.task, update: true)
           
        }
        
        // タスクのローカル通知を登録する
        func setNotification(task: Task) {
            let content = UNMutableNotificationContent()//UNMutableNotificationContentクラスのインスタンスを使って通知内容を設定
            content.title = task.title
            content.body  = task.contents       // bodyが空だと音しか出ない
            content.sound = UNNotificationSound.default()
            
            // ローカル通知が発動するtrigger（日付マッチ）を作成 通知が発動するトリガー（日時など）を設定
            let calendar = NSCalendar.current
            let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date as Date)
            let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)
            
            // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
            let request = UNNotificationRequest.init(identifier: String(task.id), content: content, trigger: trigger)
            
            // ローカル通知を登録
            let center = UNUserNotificationCenter.current()
            center.add(request) { (error) in
                if error != nil {
                print(error!)
                }
            }
            
            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
       
        setNotification(task: task)
        super.viewWillDisappear(animated)
    }
    
    func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
