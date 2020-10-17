
import UIKit
import SDWebImage

class AllProductVC: UIViewController {
    
    @IBOutlet weak var listingTblView: UITableView!
    @IBOutlet weak var lblNavigationTitle: UILabel!
    
    var myloader = MyLoader()
    var Index = Int()
    var selectedItem = Int()
    var arrDetailList: PastOrderDetail_Data?
    var isOrderDetail = false
    var arrListing = [Listing_Data]()
    
    var varientID = Int()
    var qtyValue = Int()
    var selectIndex = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isOrderDetail {
            self.listingTblView.register(UINib(nibName: "OrderDetailsTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderDetailsTableViewCell")
            lblNavigationTitle.text = "Order Detail"
            listingTblView.delegate = self
            listingTblView.dataSource = self
        } else {
            listingTblView.register(UINib(nibName: "ProductTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductTableViewCell")
            listingTblView.delegate = self
            listingTblView.dataSource = self
            
            if selectedItem == 0 {
                serverHitPopularList()
            } else if selectedItem == 1 {
                serverHitRecentList()
            } else if selectedItem == 1 {
                serverHitOfferList()
            } else {
                serverHitNewList()
            }
        }
        
        //
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
}


// MARK:- Tableview Delegate and datasourse
extension AllProductVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isOrderDetail {
            return arrDetailList?.varient?.count ?? 0
        } else {
            return arrListing.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        Index = indexPath.row
        if isOrderDetail {
            let cell = (listingTblView.dequeueReusableCell(withIdentifier: "OrderDetailsTableViewCell", for: indexPath) as? OrderDetailsTableViewCell)!
            let value = arrDetailList?.varient?[indexPath.row]
            let imageUrl = URL(string : ImgBaseUrl +  UnwarppingValue(value: value?.varientImage))
            cell.imgProduct.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: ""))
            cell.lblProductName.text =  "\(value?.productName ?? "")"
            cell.lblDescription.text =  "\(value?.varientDescription ?? "")"
            cell.lblPrice.text = "Rs. \(value?.price ?? 0)"
            cell.lblQuantity.text = "Qty - \(value?.quantity ?? 0)" + ((value?.unit)!)
            return cell
            
            
        } else {
            let cell = listingTblView.dequeueReusableCell(withIdentifier: "ProductTableViewCell") as! ProductTableViewCell
            let value = arrListing[indexPath.row]
            let imageUrl = URL(string : ImgBaseUrl +  UnwarppingValue(value: value.productImage))
            
            cell.imgProduct.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.imgProduct.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: ""))
            cell.lblProduct.text = value.productName
            cell.lblDiscription.text = value.productName
            cell.lblOfferPrice.text = "Rs. \(value.mrp ?? 0)"
            cell.lblPrice.text = "Rs. \(value.price ?? 0)"
            cell.lblQuantity.text = "\(value.quantity ?? 0)"
            cell.lblKg.text = value.unit.rawValue
            varientID = value.varientID!
            
            if let varientId = value.varientID {
                let productCount = ProductDetailManager.sharedInstance.getProductCount(productId:"\(varientId)")
                cell.viewAdd.isHidden = (productCount > 0)
                cell.viewAddCart.isHidden = !(productCount > 0)
                cell.lblNumberItem.text = "\(productCount)"
                cell.lblNumberofItem = productCount
                
            } else {
                cell.lblNumberItem.text = "0"
                cell.lblNumberofItem = 0
            }
            
            cell.btnAdd.addTarget(self, action: #selector(addAction(sender:)), for: .touchUpInside)
            cell.btnMin.addTarget(self, action: #selector(minAction(sender:)), for: .touchUpInside)
            cell.btnIncreese.addTarget(self, action: #selector(Increese(sender:)), for: .touchUpInside)
            cell.btnAdd.tag = Index
            cell.btnMin.tag = Index
            cell.btnIncreese.tag = Index
            return cell
        }
        
        
    }
    @objc func goToNextScreen(selectedDate: Date? = nil) {
        
    }
    
    //MARK:- Cell IBAction
    @objc func addAction(sender : UIButton) {
        selectIndex = sender.tag
        
        let cell = listingTblView.cellForRow(at: IndexPath(item: sender.tag, section: 0)) as? ProductTableViewCell
        varientID = arrListing[sender.tag].varientID!
        
        cell?.viewAdd.isHidden = true
        cell?.viewAddCart.isHidden = false
        cell?.lblNumberofItem = 1
        qtyValue = cell!.lblNumberofItem
        cell?.lblNumberItem.text = String(describing: qtyValue)
        ProductDetailManager.sharedInstance.onIncreaseTapped(productId: "\(varientID)")
        UserDefaults.standard.set(ProductDetailManager.sharedInstance.productDetails, forKey: "productDetails")
        serverHitForAddItemCart()
        
    }
    
    @objc func minAction(sender : UIButton) {
        selectIndex = sender.tag
        
        let cell = listingTblView.cellForRow(at: IndexPath(item: sender.tag, section: 0)) as? ProductTableViewCell
        varientID = arrListing[sender.tag].varientID!
        if cell!.lblNumberofItem > 1 {
            cell?.lblNumberofItem = cell!.lblNumberofItem - 1
            cell?.lblNumberItem.text = String(describing: cell!.lblNumberofItem)
            qtyValue = cell!.lblNumberofItem
        } else {
            cell?.viewAdd.isHidden = false
        }
        serverHitForAddItemCart()
        ProductDetailManager.sharedInstance.onDecreaseTapped(productId: "\(varientID )")
        UserDefaults.standard.set(ProductDetailManager.sharedInstance.productDetails, forKey: "productDetails")
        
    }
    
    @objc func Increese(sender : UIButton) {
        selectIndex = sender.tag
        
        let cell = listingTblView.cellForRow(at: IndexPath(item: sender.tag, section: 0)) as? ProductTableViewCell
        print("incress")
        varientID = arrListing[sender.tag].varientID!
        
        cell?.lblNumberofItem = cell!.lblNumberofItem + 1
        cell?.lblNumberItem.text = String(describing: cell!.lblNumberofItem)
        qtyValue = cell!.lblNumberofItem
        ProductDetailManager.sharedInstance.onIncreaseTapped(productId: "\(varientID)")
        UserDefaults.standard.set(ProductDetailManager.sharedInstance.productDetails, forKey: "productDetails")
        serverHitForAddItemCart()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name: "Base", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ProductDetailVC") as! ProductDetailVC
        viewController.homeProduct = arrListing[indexPath.row]
        viewController.homeScreen = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isOrderDetail {
            return 150
        } else {
            return 150
        }
    }
    
}

//MARK:- Api
extension AllProductVC {
    
    func serverHitPopularList(){
        arrListing.removeAll()
        self.myloader.showLoader(controller: self)
        // email, password, Auth-key
        let dict = ["lat":"12.70","lng":"74.94", "city":"Manjeshwar"]
        //current device location
        //"ddk_wallet_id":txtFldDDDKWalletID.text!,
        WebServices().POSTFunctiontoGetDetails(data: dict as [String : Any], serviceType: "top_selling", showIndicator: false){ (responseData) in
            DispatchQueue.main.async {
                self.myloader.removeLoader(controller: self)
                let jsonData = responseData?.toJSONString1().data(using: .utf8)!
                let decoder = JSONDecoder()
                let obj = try! decoder.decode(Listing.self, from: jsonData!)
                
                if obj.status == "1" {
                    if let arrFeed = obj.data {
                        _  =   arrFeed.map{
                            self.arrListing.append($0)
                        }
                        self.listingTblView.reloadData()
                        self.listingTblView.delegate = self
                        self.listingTblView.dataSource = self
                    }
                }
            }
        }
    }
    
    // Popular Api
    func serverHitRecentList(){
        arrListing.removeAll()
        
        self.myloader.showLoader(controller: self)
        let dict = ["lat":"12.70","lng":"74.94", "city":"Manjeshwar"]
        //"ddk_wallet_id":txtFldDDDKWalletID.text!,
        WebServices().POSTFunctiontoGetDetails(data: dict as [String : Any], serviceType: "recentselling", showIndicator: false){ (responseData) in
            DispatchQueue.main.async {
                self.myloader.removeLoader(controller: self)
                let jsonData = responseData?.toJSONString1().data(using: .utf8)!
                let decoder = JSONDecoder()
                let obj = try! decoder.decode(Listing.self, from: jsonData!)
                
                if obj.status == "1" {
                    if let arrFeed = obj.data {
                        _  =   arrFeed.map{
                            self.arrListing.append($0)
                        }
                        self.listingTblView.reloadData()
                        self.listingTblView.delegate = self
                        self.listingTblView.dataSource = self
                    }
                }
            }
        }
    }
    
    // Recent Api
    func serverHitOfferList(){
        arrListing.removeAll()
        
        self.myloader.showLoader(controller: self)
        let dict = ["lat":"12.70","lng":"74.94", "city":"Manjeshwar"]
        //"ddk_wallet_id":txtFldDDDKWalletID.text!,
        WebServices().POSTFunctiontoGetDetails(data: dict as [String : Any], serviceType: "dealproduct", showIndicator: false){ (responseData) in
            DispatchQueue.main.async {
                self.myloader.removeLoader(controller: self)
                let jsonData = responseData?.toJSONString1().data(using: .utf8)!
                let decoder = JSONDecoder()
                let obj = try! decoder.decode(Listing.self, from: jsonData!)
                
                if obj.status == "1" {
                    if let arrFeed = obj.data {
                        _  =   arrFeed.map{
                            self.arrListing.append($0)
                        }
                        self.listingTblView.reloadData()
                        self.listingTblView.delegate = self
                        self.listingTblView.dataSource = self
                    }
                }
            }
        }
    }
    
    // Recent Api
    func serverHitNewList(){
        arrListing.removeAll()
        
        self.myloader.showLoader(controller: self)
        let dict = ["lat":"12.70","lng":"74.94", "city":"Manjeshwar"]
        //"ddk_wallet_id":txtFldDDDKWalletID.text!,
        WebServices().POSTFunctiontoGetDetails(data: dict as [String : Any], serviceType: "whatsnew", showIndicator: false){ (responseData) in
            DispatchQueue.main.async {
                self.myloader.removeLoader(controller: self)
                let jsonData = responseData?.toJSONString1().data(using: .utf8)!
                let decoder = JSONDecoder()
                let obj = try! decoder.decode(Listing.self, from: jsonData!)
                
                if obj.status == "1" {
                    if let arrFeed = obj.data {
                        _  =   arrFeed.map{
                            self.arrListing.append($0)
                        }
                        self.listingTblView.reloadData()
                        self.listingTblView.delegate = self
                        self.listingTblView.dataSource = self
                    }
                }
            }
        }
    }
    
    func serverHitForAddItemCart() {
        // email, password, Auth-key
        let dict = ["user_id":userID, "varient_id":varientID, "qty":qtyValue , "store_id" : 2] as [String : Any]
        //"ddk_wallet_id":txtFldDDDKWalletID.text!,
        WebServices().POSTFunctiontoGetDetails(data: dict as [String : Any], serviceType: "ios_cart_add", showIndicator: false){ (responseData) in
            DispatchQueue.main.async {
                self.myloader.removeLoader(controller: self)
                let jsonData = responseData?.toJSONString1().data(using: .utf8)!
                let decoder = JSONDecoder()
                let obj = try! decoder.decode(AddCart.self, from: jsonData!)
                if obj.status == "1" {
                    let cell = self.listingTblView.cellForRow(at: IndexPath(item: self.selectIndex, section: 0)) as? ProductTableViewCell
                    for i in obj.cartItems! {
                        cell?.lblPrice.text = "RS. \(i.price ?? 0)"
                    }
                } else {
                    
                }
            }
        }
    }
    
}

