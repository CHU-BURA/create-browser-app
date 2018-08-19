//
//  ViewController.swift
//  BrowserApp
//
//  Created by Sho Nozaki on 2018/04/22.
//  Copyright © 2018年 Sho Nozaki. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIWebViewDelegate, UITextFieldDelegate {

    // URL入力欄
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var browserWebView: UIWebView!
    
    // 戻るボタン
    @IBOutlet weak var backButton: UIBarButtonItem!
    // 進むボタン
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    // 更新ボタン
    @IBOutlet weak var reloadButton: UIToolbar!
    // サイト読み込みアイコン
    @IBOutlet weak var browserActivityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.browserWebView.delegate = self
        self.urlTextField.delegate = self
        
        // 初期表示はサイト読み込みアイコンを隠す
        self.browserActivityIndicatorView.hidesWhenStopped = true
    }
    
    /* リターンキー押下時の処理 */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // textFieldの検証
        if textField != self.urlTextField {
            // urlTextField(UITextField)でない場合
            return true
        }
        if let urlString = textField.text {
            self.loadUrl(urlString: urlString)
        }
        
        // UITextField入力後にキーボードを閉じる
        textField.resignFirstResponder()
//        self.view.endEditing(true)
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // textFieldの検証
        if textField != self.urlTextField {
            // urlTextField(UITextField)でない場合
            return
        }
        /* URLの全選択を可能とさせる処理 */
        // 遅延処理 → 0.1秒後に実行
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // textFieldの選択範囲を最初から最後まで(全選択)にする
            textField.selectedTextRange = textField.textRange(
                from: textField.beginningOfDocument,
                to: textField.endOfDocument)
        }
    }
    
    /* ページ読み込み開始時に呼ばれる */
    func webViewDidStartLoad(_ webView: UIWebView) {
        // サイト読み込みのアニメーションを開始する
        self.browserActivityIndicatorView.startAnimating()
    }
    
    /* ページ読み込み終了時に呼ばれる */
    func webViewDidFinishLoad(_ webView: UIWebView) {
        // サイトのURLを表示する
        if let urlString = self.browserWebView.request?.url?.absoluteString {
            self.urlTextField.text = urlString
        }
        // サイト読み込みのアニメーションを終了する
        self.browserActivityIndicatorView.stopAnimating()
        // 戻る・進むボタンの無効化
        self.backButton.isEnabled = self.browserWebView.canGoBack
        self.forwardButton.isEnabled = self.browserWebView.canGoBack
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 表示するURLを定義
        let urlString = "https://qiita.com/_CHUBURA"
//        let urlString = ""
        self.loadUrl(urlString: urlString)
        self.addBorder()
    }
    
    // 境界線を表示する
    func addBorder() {
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0.0, y: 0.0, width: self.browserWebView.frame.size.width, height: 1.0)
        topBorder.backgroundColor = UIColor.lightGray.cgColor
        self.browserWebView.layer.addSublayer(topBorder)
    }
    
    // nullチェック時のアラートを表示する
    func showAlert(_ message: String) {
        // アラートの作成
        let alertConroller = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        // アラートアクションの作成
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        // アラートにアクションを追加
        alertConroller.addAction(defaultAction)
        // アラートの表示
        self.present(alertConroller, animated: true, completion: nil)
    }
    
    /* URLの読み込み検証する */
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        // 読み込みエラーの場合
        // エラー除外処理
        if (error as! URLError).code == URLError.cancelled {
            // リクエストキャンセル時などの場合は、エラー除外対象とする
            return
        }
        // エラー処理
        self.showAlert("Network Error") // アラート表示
        self.browserWebView.stopLoading() // loadingの停止
        self.browserActivityIndicatorView.stopAnimating()
    }
        
    /* URL文字列のバリデーションチェック */
    func getValidatedUrl(urlString: String) -> URL? {
        // URL前後の空白・タブをチェック
        let trimmed = urlString.trimmingCharacters(in: NSCharacterSet.whitespaces)
        // URL文字列のnullチェック
        if URL(string: trimmed) == nil {
            print("Invalid URL")
            self.showAlert("Invalid URL")
            return nil
        }
        return URL(string: self.appendScheme(trimmed))
    }
    
    // ロードするURLに対して「http://」や「https://」を自動付与させる
    func appendScheme(_ urlString: String) -> String {
        if URL(string: urlString)?.scheme == nil {
            return "http:/" + urlString
        }
        return urlString
    }
    
    // URLをもとにサイト表示
    func loadUrl(urlString: String) {
        if let url = self.getValidatedUrl(urlString: urlString) {
            let urlRequest = URLRequest(url: url)
            self.browserWebView.loadRequest(urlRequest)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func goBack(_ sender: Any) {
        self.browserWebView.goBack()
    }
    
    @IBAction func goForward(_ sender: Any) {
        self.browserWebView.goForward()
    }
    
    @IBAction func reload(_ sender: Any) {
        self.browserWebView.reload()
    }
    
}

