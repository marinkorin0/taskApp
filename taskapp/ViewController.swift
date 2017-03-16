//
//  ViewController.swift
//  taskapp
//
//  Created by 小林真理子 on 2017/02/28.
//  Copyright © 2017年 小林真理子. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications



//UITableViewにデータを表示するために任せるクラスを指定する．
class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var search: UISearchBar!

   
    
    // Realmインスタンスを取得する
    let realm = try! Realm()  // ←追加
    
    
    // DB内のタスクが格納されるリスト。
    // 日付の近い順．降順
    // アップデートすると自動的にリストが更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byProperty: "date", ascending: false)   // ←追加
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate = self
        tableView.dataSource = self
        search.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var searchFlag: Bool = false
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        search.resignFirstResponder()
    }
    
    // searchバーのテキスト処理を終えた時
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchFlag = true
        taskArray = try! Realm().objects(Task.self).filter("category CONTAINS[c] %@", searchBar.text!)
            tableView.reloadData()

        
    
    }
    // 検索をキャンセルした時の処理
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchFlag = false
        taskArray = try! Realm().objects(Task.self).filter("category CONTAINS[c] %@", searchBar.text!)
        tableView.reloadData()
    }
    
    
//MARK: UITableViewDataSourceプロトコルのメソッド？？？？？
    //データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return taskArray.count
    }
   //各cellの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
       
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Cellに値を設定する
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date as Date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各cellを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue",sender: nil)
    }
    
    //cellが削除可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
   
       
    
    // segue で画面遷移するに呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()
            task.date = NSDate()
            
            if taskArray.count != 0 {
                task.id = taskArray.max(ofProperty: "id")! + 1
            }
            
            inputViewController.task = task
        }
    }
    
    
    // Delete ボタンが押された時に呼ばれるメソッド(タスクを削除するときに通知をキャンセルする)
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            // 削除されたタスクを取得する タスクを並べる(Array並べる配置する)
            let task = self.taskArray[indexPath.row]
            
            // ローカル通知をキャンセルする(通知リクエストを解除する．ここでのPending(未決？目前？)は何？)
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            // データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.fade)
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
    }
  
    
    // 入力画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
}

