//
//  SearchVC.swift
//  GoGrocer
//
//  Created by Komal Gupta on 29/05/20.
//  Copyright © 2020 Komal Gupta. All rights reserved.
//

import UIKit
import IBAnimatable

class SearchVC: UIViewController {

    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var txtFieldSearch: AnimatableTextField!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var tblView: UITableView!
    
    var searchTimer: Timer?
    var myloader = MyLoader()
    var arrCaregoryData = [CategoryProduct_data]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        tblView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchTableViewCell")
      
        searchText()
        // Do any additional setup after loading the view.
    }
    
    func serverHitForSearch(searchText: String) {
        arrCaregoryData.removeAll()
        self.myloader.showLoader(controller: self)
        // email, password, Auth-key
        let dict = ["keyword":searchText,"lat":"12.70","lng":"74.94", "city":"Manjeshwar"]
        //"ddk_wallet_id":txtFldDDDKWalletID.text!,
        WebServices().POSTFunctiontoGetDetails(data: dict as [String : Any], serviceType: "search", showIndicator: false){ (responseData) in
            DispatchQueue.main.async {
                self.myloader.removeLoader(controller: self)
                let jsonData = responseData?.toJSONString1().data(using: .utf8)!
                let decoder = JSONDecoder()
                let obj = try! decoder.decode(CategoryProduct.self, from: jsonData!)
                if obj.status == "1"{
                 if let arrFeed = obj.data {
                        _  =   arrFeed.map{
                            self.arrCaregoryData.append($0)
                        }
                        self.tblView.reloadData()
                        self.tblView.delegate = self
                        self.tblView.dataSource = self
                    }
                }
            }
        }
    }
}

//MARK:- UITableViewDelegate, UITableViewDataSource
extension SearchVC: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCaregoryData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath) as? SearchTableViewCell
        cell?.lblName.text = arrCaregoryData[indexPath.row].productName
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let storyboard = UIStoryboard.init(name: "Base", bundle: nil)
         let viewController = storyboard.instantiateViewController(withIdentifier: "ProductDetailVC") as! ProductDetailVC
        viewController.CategoryProductDetail = arrCaregoryData[indexPath.row]
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}

extension SearchVC: UITextFieldDelegate {
//MARK:- SearchBoxTextChange
func searchText() -> Void {
    txtFieldSearch?.delegate = self
    txtFieldSearch?.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
}

//MARK:- textFieldDidChange
@objc func textFieldDidChange(textField:UITextField) -> Void {
 
    if textField.text!.count >= 3 {
        if self.searchTimer != nil {
            self.searchTimer?.invalidate()
            self.searchTimer = nil
        }
        if textField == txtFieldSearch {
            self.searchTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(searchForKeyword), userInfo: txtFieldSearch!.text, repeats: false)
        }
    }
}

func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    self.view.endEditing(true)
    return false
}
//MARK:- searchForKeyword
@objc func searchForKeyword(timer:Timer) -> Void {
    let keyword = timer.userInfo
    self.serverHitForSearch(searchText:keyword as! String)
}
}

