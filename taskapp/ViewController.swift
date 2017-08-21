//
//  ViewController.swift
//  taskapp
//
//  Created by 西田稔 on 2017/08/16.
//  Copyright © 2017年 minoru.nishida. All rights reserved.
//
/*
 課題：タスク管理アプリの機能追加
 
 タスク管理アプリにCategory（カテゴリ）を追加して、TableViewの画面でカテゴリによるTaskの絞り込みをさせるようにしてください。
 
 下記の要件を満たしてください。
 
 本レッスンで制作した taskapp プロジェクトを基に制作してください　*
 TaskクラスにcategoryというStringプロパティを追加してください  *
 タスク作成画面でcategoryを入力できるようにしてください         *
 一覧画面に文字列検索用の入力欄を設置し、categoryと合致するTaskのみ絞込み表示させてください
 Auto Layoutを使用して、iPhone5, 6s, 6s plusの画面サイズでレイアウトが崩れないようにしてください
 要件を満たすものであれば、どのようなものでも構いません。 例えば、保存ボタンやキャンセルボタンを作ったり、CocoaPodsでUI用のライブラリなどの追加を検討してみてください。 見栄え良く、自分でも使いやすいタスク管理アプリを目指しましょう！
 
 ヒント
 https://realm.io/jp/docs/swift/latest/#section-28
 以下のRealmのドキュメントを確認しましょう。
 検索条件を指定する | Realm
*/
import UIKit
import RealmSwift   // ←追加
import UserNotifications    // 追加

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var serchTextBar: UISearchBar!
    
    // Realmインスタンスを取得する
    let realm = try! Realm()  // ←追加
    
    // DB内のタスクが格納されるリスト。
    // 日付近い順\順でソート：降順
    // 以降内容をアップデートするとリスト内は自動的に更新される。

    //category が検索するプロパティ名　=
    //searchText が検索したい値
    
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)  // ←追加

    
    var searchResult = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        
        tableView.delegate = self
        tableView.dataSource = self
        serchTextBar.delegate = self 
        //searchResult = taskArray as! String
        print(taskArray)
        print(searchResult)
        
    }
    
    override func didReceiveMemoryWarning() {

        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: UITableViewDataSourceプロトコルのメソッド
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count  // ←追加する
    }

    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
            // 再利用可能な cell を得る
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
            
            // Cellに値を設定する.
            let task = taskArray[indexPath.row]
            cell.textLabel?.text = task.title
            
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            let dateString:String = formatter.string(from: task.date as Date)
            cell.detailTextLabel?.text = dateString
        
        return cell
        
    }
    
    // MARK: UITableViewDelegateプロトコルのメソッド
    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue",sender: nil)
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
    
    // 入力画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        print("入力画面から戻ってきた時のちょくぜん")
    }
    
    /////////////////*
    /*
     * 各indexPathのcellの高さを指定します．
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            // 削除されたタスクを取得する
            let task = self.taskArray[indexPath.row]
            
            // ローカル通知をキャンセルする
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        taskArray = try! Realm().objects(Task.self).filter("category LIKE '\(searchText)*'")
        tableView.reloadData()
        //キーボード閉じる
        serchTextBar.endEditing(true);

        print("search 直後")
        
    }

}

