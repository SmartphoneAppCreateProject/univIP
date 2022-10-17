//
//  AgreementViewController.swift
//  univIP
//
//  Created by Akihiro Matsuyama on 2021/08/31.
//

import UIKit

final class AgreementViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var agreementButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    private let dataManager = DataManager.singleton
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // 登録ボタンの角を丸める
        agreementButton.layer.cornerRadius = 5.0
        textView.text = "「快適になる」をタップすると、プライバシーポリシーを理解し、サービス利用規約に同意したことになります。"
    }
    
    // MARK: - IBAction
    
    /// 同意ボタン
    /// 利用規約のバージョン更新を行う
    @IBAction func agreementButton(_ sender: Any) {
        dataManager.agreementVersion = Constant.latestTermsVersion
        dismiss(animated: true, completion: nil)
    }
}
