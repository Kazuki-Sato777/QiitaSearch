import UIKit
import Alamofire
import SwiftyJSON
import Foundation
import FirebaseFirestore

class ListController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UIWebViewDelegate{
    
    var activityIndicatorView = UIActivityIndicatorView()
    var qiitaArray: [QiitaStruct] = []                  //データ配列
    let table = UITableView()                           //データテーブル
    let searchbar = UISearchBar()                       //検索バー
    let baseurl = "https://qiita.com/api/v2/items"      //URL
    var historyBarButtonItem = UIBarButtonItem()
    let database = Firestore.firestore()
    let dialog = UIAlertController(title: "データを取得できませんでした。", message: "もう一度やり直してください。", preferredStyle: .alert)
    let myWebView : UIWebView = UIWebView()
        
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //viewの作成
        SetView()
        
        //APIの取得
        getAPIInfo(url: baseurl)
        
    }
}

//*******************************************//
//                  viewの作成
//*******************************************//
extension ListController{
    
    func SetView() {
        // 検索バー
        searchbar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 44)
        searchbar.showsCancelButton = true
        searchbar.text = "タグ検索です。"
        searchbar.delegate = self
        
        //テーブル
        table.frame = view.frame
        table.tableHeaderView = searchbar
        table.contentOffset = CGPoint(x: 0, y: 44)
        view.addSubview(table)
        table.delegate = self
        table.dataSource = self
        
        //履歴ボタン
        historyBarButtonItem = UIBarButtonItem(title: "履歴", style: .done, target: self, action: #selector(historyBarButtonTapped(_:)))
        self.navigationItem.rightBarButtonItem = historyBarButtonItem
        
        //ダイアログ
        dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    }
}

//*******************************************//
//                  API通信
//*******************************************//
extension ListController{
    // APIデータの取得
    func getAPIInfo(url: String) {
        
        self.StartIndicatorView()
        
        let request = AF.request(url)
        
        request.responseJSON(){ (response) in
            do {
                guard let data = response.data else {
                    //アニメーションの終了
                    self.EndIndicatorView()
                    //データが返ってこない or 空ならダイアログを表示
                    self.present(self.dialog, animated: true, completion: nil)
    
                    return
                }
                let decode = JSONDecoder()
                let articles = try decode.decode([QiitaStruct].self, from: data)
                self.qiitaArray = articles
                
                //アニメーションの終了
                self.EndIndicatorView()
                
                self.table.reloadData()
            } catch {
                print("変換に失敗しました:",error)
            }
        }
    }
}

//*******************************************//
//                  セルイベント
//*******************************************//
extension ListController{
    //セルカウント
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return qiitaArray.count
    }
    
    //セルにデータ設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let article = qiitaArray[indexPath.row]
        let image:UIImage = getImageByUrl(url: article.user.profile_image_url)
        cell.textLabel?.text = article.title
        cell.detailTextLabel?.text = article.user.profile_image_url
        cell.imageView!.image = image
        return cell
    }
    
    //外部ブラウザでURLを開く
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = qiitaArray[indexPath.row]
        let url = URL(string: article.url)
        
        if UIApplication.shared.canOpenURL(url! as URL) {
                UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
        
        //閲覧履歴の保存
        SetData(title: article.title,url: article.url)
    }
}

//*******************************************//
//                  ボタンイベント
//*******************************************//
extension ListController {
    // 履歴ボタン押下
    @objc func historyBarButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goHistory", sender: nil)
    }
    
    //検索
   func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        getAPIInfo(url: baseurl + "?page=1&query=tag%3A" + searchBar.text!)
   }
    
    //キャンセルボタン
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchbar.text = ""
    }
}

//*******************************************//
//                  関数
//*******************************************//
extension ListController{
    
    //アニメーションの開始
    func StartIndicatorView() {
        //処理中ダイアログ
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .large
        activityIndicatorView.color = .purple
        view.addSubview(activityIndicatorView)
        
        activityIndicatorView.startAnimating()
    }

    //アニメーションの終了
    func EndIndicatorView() {
        activityIndicatorView.stopAnimating()
    }
    
    // 閲覧履歴の保存
    func SetData(title: String,url: String){
        // 閲覧履歴の格納
        database.collection("history").addDocument(data: [
            "title": title,
            "history": url
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
                return
            }
        }
    }
    
    // urlをimageに変える
    func getImageByUrl(url: String) -> UIImage{
        let url = URL(string: url)
        do {
            let data = try Data(contentsOf: url!)
            return UIImage(data: data)!
        } catch let err {
            print("Error : \(err.localizedDescription)")
        }
        return UIImage()
    }
}


