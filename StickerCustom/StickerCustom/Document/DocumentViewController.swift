//
//  DocumentViewController.swift
//  StickerCustom
//
//  Created by 刘菁楷 on 2021/12/30.
//

import UIKit
import WebKit

fileprivate let DocumentCellIdentifier = "DocumentCellIdentifier"

class DocumentViewController: SCViewController {

    private var cellData: [String] = []

    private let webView = WKWebView()
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "开发文档"
        tempSetup()
//        setupDocumentData()
//        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        // 不知道为啥，切到其他界面再回来会发现文档变成一片白了，必须重新加载才行
        guard let filePath = Bundle.main.path(forResource: "Documentation", ofType: "pdf") else {
            return
        }
        webView.load(URLRequest(url: URL(fileURLWithPath: filePath)))
    }

    // 临时这样糊弄一下
    private func tempSetup() {
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.top.equalTo(StatusBarH + NavBarH)
            make.leading.trailing.bottom.equalToSuperview()
        }
        webView.uiDelegate = self
        webView.navigationDelegate = self
    }

    private func setupDocumentData() {
        cellData = [
            "{新建画板，画板宽度，画板高度，绘画内容}",
            "{画图片，一个图片，图片左边距画板距离，图片上边距画板距离，图片画出宽度，图片画出高度}",
            "{图像圆角化，一个图片}",
            "{取图片宽度}",
            "{取图片高度}",
            "{取颜色，红色值，绿色值，蓝色值，不透明度}",
            "{循环，循环次数，循环变量，循环内容}",
            "{创建动图，内容}",
            "{添加帧，图片}",
            "{设置帧延迟，延迟时间}",
        ]
    }

    private func setup() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.backgroundColor = UIColor.backgroundDark
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor.tintGreen
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: DocumentCellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
}

extension DocumentViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DocumentCellIdentifier, for: indexPath)
        cell.backgroundColor = .clear
        cell.textLabel?.text = cellData[indexPath.row]
        cell.textLabel?.textColor = UIColor.tintGreen
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension DocumentViewController: WKUIDelegate, WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("页面开始加载")
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("页面加载失败")
    }
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("内容开始返回")
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("页面加载完成")
    }
}
