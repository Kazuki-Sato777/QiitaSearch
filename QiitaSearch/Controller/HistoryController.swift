//
//  HistoryController.swift
//  QiitaSearch
//
//  Created by 佐藤　一輝 on 2021/06/29.
//
import UIKit
import Foundation
import FirebaseFirestore

class HistoryController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    var activityIndicatorView = UIActivityIndicatorView()
    private var histories = [HistoryStruct]()
    private let table = UITableView()
    let database = Firestore.firestore()
    
    override func viewWillAppear(_ animated: Bool) {
        //処理中ダイアログ
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .large
        activityIndicatorView.color = .purple
        view.addSubview(activityIndicatorView)
        
        activityIndicatorView.startAnimating()
    }
    
    func EndIndicatorView() {
        self.activityIndicatorView.stopAnimating()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //テーブル
        table.frame = view.frame
        table.contentOffset = CGPoint(x: 0, y: 0)
        view.addSubview(table)
        table.delegate = self
        table.dataSource = self
        
        selectData { (histories) in
            self.histories = histories
            
            self.EndIndicatorView()
            
            self.table.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return histories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let article = histories[indexPath.row]
        cell.textLabel?.text = article.title
        return cell
    }
    
    //外部ブラウザでURLを開く
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = histories[indexPath.row]
        let url = URL(string: article.history)
        
        if UIApplication.shared.canOpenURL(url! as URL) {
                UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
    }
    
    func selectData(compeltion: @escaping ([HistoryStruct]) -> Void){
        
        database.collection("history").getDocuments{ (snapshot, err) in
            if let err = err {
                print("閲覧履歴の取得に失敗しました",err)
                return
            }
//            var histories = [HistoryStruct]()
//
//            snapshot?.documents.forEach({ (snapshot) in
//                let dic = snapshot.data()
//                let history = HistoryStruct(dic: dic)
//                histories.append(history)
//            })
            
            let histories = snapshot?.documents.map({ (snapshot) -> HistoryStruct in
                let dic = snapshot.data()
                let history = HistoryStruct(dic: dic)
                return history
            })
            
            compeltion(histories ?? [HistoryStruct]())
        }
    }
    
}
