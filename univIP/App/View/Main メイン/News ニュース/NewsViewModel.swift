//
//  NewsViewModel.swift
//  univIP
//
//  Created by Akihiro Matsuyama on 2022/11/06.
//

import Foundation
import Kanna
import Alamofire
import SwiftyJSON

final class NewsViewModel {
    
    private let dataManager = DataManager.singleton
    private let apiManager = ApiManager.singleton
    
    
    struct NewsData {
        let title: String
        let date: String
        let urlStr: String
    }
    // Newsの基本データ情報を保存
    public var newsDatas = [
        NewsData(title: "",
                 date: "",
                 urlStr: "")
    ]
    // Newsの写真データ情報を保存
    public var newsImgStr:[String] = []
    
    
    //MARK: - STATE ステータス
    enum State {
        case busy           // 準備中 -->
        case ready          // 準備完了 -->
        case error          // エラー発生 -->
    }
    public var state: ((State) -> Void)?
    
    public func getNewsData() {
        state?(.busy) // 通信開始（通信中）
        let urlString = "https://api.rss2json.com/v1/api.json?rss_url=https://www.tokushima-u.ac.jp/recent/rss.xml"
        
        apiManager.request(urlString,
                            success: { [weak self] (response) in
            guard let self = self else { // SearchViewModelのself
                AKLog(level: .FATAL, message: "[self] FatalError")
                fatalError()
            }
            
            self.newsDatas.removeAll()
            
            for i in 0..<10 {
                let data = NewsData(title: response["items"][i]["title"].string!,
                                    date: response["items"][i]["pubDate"].string!,
                                    urlStr: response["items"][i]["link"].string!)
                self.newsDatas.append(data)
            }
            sleep(5)
            self.state?(.ready) // 通信完了
        }, failure: { [weak self] (error) in
            AKLog(level: .ERROR, message: "[API] userUpdate: failure:\(error.localizedDescription)")
            self?.state?(.error) // エラー表示
        })
    }
    
    public func getImage() {
        state?(.busy) // 通信開始（通信中）
        let urlString = "https://www.tokushima-u.ac.jp/recent/"
        let url = URL(string: urlString)! // fatalError
        
        do {
            // URL先WebページのHTMLデータを取得
            let data = try NSData(contentsOf: url) as Data
            let doc = try HTML(html: data, encoding: String.Encoding.utf8)
            
            newsImgStr.removeAll()
            
            // タグ(HTMLでのリンクの出発点と到達点を指定するタグ)を抽出
            for node in doc.xpath("//div") {
                // 属性(HTMLでの目当ての資源の所在を指し示す属性)に設定されている文字列を出力
                if let str = node["style"] {
                    let result = str.replacingOccurrences(of:"background-image: url(", with:"")
                    let result2 = result.replacingOccurrences(of:");", with:"")
                    let url = "https://www.tokushima-u.ac.jp/" + result2
                    newsImgStr.append(url)
                }
            }
            sleep(5)
            self.state?(.ready) // 通信完了
        } catch {
            AKLog(level: .ERROR, message: "[Data取得エラー]: HTMLデータパースエラー\n urlString:\(url.absoluteString)")
            self.state?(.error) // エラー表示
        }
    }
}
