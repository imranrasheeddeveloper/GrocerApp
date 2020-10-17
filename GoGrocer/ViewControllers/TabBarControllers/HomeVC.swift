
import UIKit
import SDWebImage
import ExpandingMenu
import RandomColorSwift
import IBAnimatable
import CoreLocation

protocol MenuActionDelegate {
    func openSegue(_ segueName: String, sender: AnyObject?)
    func reopenMenu()
}

class HomeVC: UIViewController {
    
    //MARK:- Random color Declaration
    var colors: [UIColor]!
    fileprivate var count = 99
    fileprivate var hue: Hue = .random
    fileprivate var luminosity: Luminosity = .bright
    
    //MARK:- IBOutlet
    @IBOutlet weak var bannerCollectionView: UICollectionView!
    @IBOutlet weak var footerBannerCollectionView: UICollectionView!
    @IBOutlet weak var topCategoryColllectionView: UICollectionView!
    @IBOutlet weak var tabViewCollectionView: UICollectionView!
    @IBOutlet weak var listingTblView: UITableView!
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var viewFooter: UIView!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var viewSearch: UIScrollView!
    @IBOutlet weak var txtFieldSearchBar: AnimatableTextField!
    @IBOutlet weak var txtFieldSearch: AnimatableTextField!
    @IBOutlet weak var tblView: UITableView!
    
    var Index = Int()
    var IndexItem = Int()
    let interactor = Interactor()
    var myloader = MyLoader()
    var arrTabListing = ["TOP SELLING","RECENT","DEALS OF THE DAY","WHAT'S NEW"]
    var arrBanner = [Banner_Data]()
    var arrFooterBanner = [Footerbanner_Data]()
    var arrListing = [Listing_Data]()
    var arrTopCategory = [TopCategory_Data]()
    var getImage: UIImage?
    var documentInteractionController:UIDocumentInteractionController!
    var searchTimer: Timer?
    var arrCaregoryData = [CategoryProduct_data]()
    var varientID = Int()
    var qtyValue = Int()
    var selectIndex = Int()
    
    
    //MARK:- CoreLoction Declaration
    let locationManager = CLLocationManager()
    var geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        configureExpandingMenuButton()
        getCurrentLocation()
        
        searchText()
        tblView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchTableViewCell")
        bannerCollectionView.register(UINib(nibName: "BannerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BannerCollectionViewCell")
        footerBannerCollectionView.register(UINib(nibName: "BannerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BannerCollectionViewCell")
        tabViewCollectionView.register(UINib(nibName: "CategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCollectionViewCell")
        listingTblView.register(UINib(nibName: "ProductTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductTableViewCell")
        topCategoryColllectionView.register(UINib(nibName: "TopCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TopCategoryCollectionViewCell")
        
        serverHitBannerList()
        serverHitPopularList()
        serverHitTopCategoryList()
        serverHitBottomBannerList()
        tabViewCollectionView.delegate = self
        tabViewCollectionView.dataSource = self
        listingTblView.tableHeaderView = viewHeader
        listingTblView.tableFooterView = viewFooter
        listingTblView.estimatedRowHeight = 150
        listingTblView.rowHeight = UITableView.automaticDimension
        // Do any additional setup after loading the view.
    }
    
    //    override func viewDidAppear(_ animated: Bool) {
    //        super.viewDidAppear(true)
    //        self.viewSearch.isHidden = true
    //        refresh()
    //    }
    //
    //    override func viewWillAppear(_ animated: Bool) {
    //        super .viewWillAppear(true)
    //        self.viewSearch.isHidden = true
    //
    //        refresh()
    //    }
    override func viewWillAppear(_ animated: Bool) {
        self.viewSearch.isHidden = true
        //
        refresh()
        listingTblView.reloadData()
    }
    
    
    func refresh() {
        colors = randomColors(count: count, hue: hue, luminosity: luminosity)
        topCategoryColllectionView?.reloadData()
        tblView.reloadData()
    }
    
    
    //MARK:- IBAction
    @IBAction func locationAction(_ sender: UIButton) {
        let storyboard = UIStoryboard.init(name: "Chekout", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "AddressMapVC") as! AddressMapVC
        viewController.getCurrenAddress = lblAddress.text!
        self.navigationController?.pushViewController(viewController, animated: true)    }
    
    @IBAction func profileAction(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Base", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func viewAllAction(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Base", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "AllProductVC") as! AllProductVC
        viewController.selectedItem = IndexItem
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}

// MARK:- UITableViewDelegate, UITableViewDataSource
extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case listingTblView:
            return arrListing.count
        case tblView:
            return arrCaregoryData.count
        default:
            return arrListing.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //var imageUrl : URL?
        switch tableView {
        case listingTblView:
            Index = indexPath.row
            let cell = listingTblView.dequeueReusableCell(withIdentifier: "ProductTableViewCell") as! ProductTableViewCell
            let value = arrListing[indexPath.row]
            let url = ImgBaseUrl + arrListing[indexPath.row].productImage!
            let imageUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            cell.imgProduct.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.imgProduct.sd_setImage(with: URL(string: imageUrl!) , placeholderImage: UIImage(named: "Finalised Logo-1"), options: SDWebImageOptions.refreshCached, progress: nil, completed: { (image, error, cache, url) in
                if error == nil {
                    cell.imgProduct.image = image
                }
                else{
                    print(error?.localizedDescription ?? "Error")
                }
            })
            
            cell.lblProduct.text = value.productName
            cell.lblDiscription.text = value.datumDescription
            cell.lblOfferPrice.text = "Rs. \(value.mrp ?? 0)"
            cell.lblOfferPrice.textColor = .black
            cell.lblPrice.text = "Rs. \(value.price ?? 0)"
            cell.lblPrice.textColor = .red
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
            
        case tblView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath) as? SearchTableViewCell
            cell?.lblName.text = arrCaregoryData[indexPath.row].productName
            return cell!
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath) as? SearchTableViewCell
            cell?.lblName.text = arrCaregoryData[indexPath.row].productName
            return cell!
        }
        
        
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
        
        switch tableView {
        case listingTblView:
            let storyboard = UIStoryboard.init(name: "Base", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ProductDetailVC") as! ProductDetailVC
            viewController.homeProduct = arrListing[indexPath.row]
            viewController.homeScreen = true
            self.navigationController?.pushViewController(viewController, animated: true)
        case tblView:
            let storyboard = UIStoryboard.init(name: "Base", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ProductDetailVC") as! ProductDetailVC
            viewController.CategoryProductDetail = arrCaregoryData[indexPath.row]
            viewController.homeScreen = true
            self.navigationController?.pushViewController(viewController, animated: true)
        default:
            let storyboard = UIStoryboard.init(name: "Base", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ProductDetailVC") as! ProductDetailVC
            viewController.CategoryProductDetail = arrCaregoryData[indexPath.row]
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    //MARK:- I@IBAction
    @IBAction func SideMenuAction(_ sender: Any) {
        self.performSegue(withIdentifier: "openMenu", sender: nil)
    }
    
    @IBAction func edgePanGestureAction(_ sender: UIScreenEdgePanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        let progress = MenuHelper.calculateProgress(translation, viewBounds: view.bounds, direction: .right)
        
        MenuHelper.mapGestureStateToInteractor(
            sender.state,
            progress: progress,
            interactor: interactor){
            self.performSegue(withIdentifier: "openMenu", sender: nil)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? MenuViewController {
            destinationViewController.transitioningDelegate = self
            destinationViewController.interactor = interactor
            destinationViewController.menuActionDelegate = self
        }
        
    }
}


//MARK:- collectionview delegate datasource
extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource,  UICollectionViewDelegateFlowLayout
{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch collectionView {
        case tabViewCollectionView:
            return arrTabListing.count
        case bannerCollectionView:
            return arrBanner.count
        case footerBannerCollectionView:
            return arrFooterBanner.count
        case topCategoryColllectionView:
            return arrTopCategory.count
        default:
            return 10
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView {
        case tabViewCollectionView:
            let cell = tabViewCollectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as? CategoryCollectionViewCell
            cell?.lblName.text = arrTabListing[indexPath.item]
            
            if IndexItem == indexPath.item {
                cell?.lblName.textColor = #colorLiteral(red: 0.662745098, green: 0.1215686275, blue: 0.3058823529, alpha: 1)
                cell?.lblLine.backgroundColor = #colorLiteral(red: 0.662745098, green: 0.1215686275, blue: 0.3058823529, alpha: 1)
            } else {
                cell?.lblName.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                cell?.lblLine.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            }
            
            return cell!
            
        case bannerCollectionView:
            let cell = bannerCollectionView.dequeueReusableCell(withReuseIdentifier: "BannerCollectionViewCell", for: indexPath) as? BannerCollectionViewCell
            let value = arrBanner[indexPath.item]
            let imageUrl = URL(string : ImgBaseUrl +  UnwarppingValue(value: value.bannerImage))
            cell?.imgBanner.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell?.imgBanner.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: ""))
            return cell!
        case footerBannerCollectionView:
            let cell = footerBannerCollectionView.dequeueReusableCell(withReuseIdentifier: "BannerCollectionViewCell", for: indexPath) as? BannerCollectionViewCell
            let value = arrFooterBanner[indexPath.item]
            let imageUrl = URL(string : ImgBaseUrl +  UnwarppingValue(value: value.bannerImage))
            cell?.imgBanner.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell?.imgBanner.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: ""))
            return cell!
        case topCategoryColllectionView:
            let cell = topCategoryColllectionView.dequeueReusableCell(withReuseIdentifier: "TopCategoryCollectionViewCell", for: indexPath) as? TopCategoryCollectionViewCell
            let value = arrTopCategory[indexPath.item]
            let imageUrl = URL(string : ImgBaseUrl +  UnwarppingValue(value: value.image))
            cell?.imgIcon.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell?.imgIcon.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: ""))
            cell?.lblName.text = value.title
            cell?.viewMain.backgroundColor = colors[indexPath.item]
            
            return cell!
        default:
            let cell = bannerCollectionView.dequeueReusableCell(withReuseIdentifier: "BannerCollectionViewCell", for: indexPath) as? BannerCollectionViewCell
            return cell!
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch collectionView {
        case tabViewCollectionView:
            let width = (self.tabViewCollectionView.frame.width - 30) / 4
            let height = (self.tabViewCollectionView.frame.height - 10)
            return CGSize(width: width, height: height)
        case bannerCollectionView:
            let width = (self.bannerCollectionView.frame.width - 120)
            let height = (self.bannerCollectionView.frame.height - 10)
            return CGSize(width: width, height: height)
        case footerBannerCollectionView:
            let width = (self.footerBannerCollectionView.frame.width - 120)
            let height = (self.footerBannerCollectionView.frame.height - 10)
            return CGSize(width: width, height: height)
        case topCategoryColllectionView:
            let width = (self.topCategoryColllectionView.frame.width - 25) / 3
            let height = (self.topCategoryColllectionView.frame.height - 25) / 2
            return CGSize(width: width, height: height)
        default:
            let width = (self.bannerCollectionView.frame.width - 10) / 4
            let height = (self.bannerCollectionView.frame.height - 10)/2
            return CGSize(width: width, height: height)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        IndexItem = indexPath.item
        
        switch collectionView {
        case tabViewCollectionView:
            tabViewCollectionView.reloadData()
            switch IndexItem {
            case 0:
                serverHitPopularList()
            case 1:
                serverHitRecentList()
            case 2:
                serverHitOfferList()
            case 3:
                serverHitNewList()
            default:
                print("sds")
            }
        case topCategoryColllectionView:
            let obj = UIStoryboard(name: "Base", bundle: nil).instantiateViewController(withIdentifier: "CategoryProductVC") as! CategoryProductVC
            obj.catId =  arrTopCategory[indexPath.row].catID!
            self.navigationController?.pushViewController(obj, animated: true)
        default:
            print("dfd")
        }
        
    }
    
}


//MARK:- UITextFieldDelegate
extension HomeVC: UITextFieldDelegate {
    // SearchBoxTextChange
    func searchText() -> Void {
        txtFieldSearchBar?.delegate = self
        txtFieldSearchBar?.addTarget(self, action: #selector(self.textFieldDidChangeBar(textField:)), for: UIControl.Event.editingChanged)
        txtFieldSearch?.delegate = self
        txtFieldSearch?.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
    }
    
    // textFieldDidChange
    @objc func textFieldDidChangeBar(textField:UITextField) -> Void {
        
        if textField.text!.count == 1 {
            self.viewSearch.isHidden = false
        }
    }
    
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
    // searchForKeyword
    @objc func searchForKeyword(timer:Timer) -> Void {
        let keyword = timer.userInfo
        self.serverHitForSearch(searchText:keyword as! String)
    }
    // SearchApi
    func serverHitForSearch(searchText: String) {
        arrCaregoryData.removeAll()
        self.myloader.showLoader(controller: self)
        // email, password, Auth-key
        let dict = ["keyword":searchText, "lat":"12.70","lng":"74.94", "city":"Manjeshwar"]
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




// MARK:- Api Function
extension HomeVC {
    func serverHitBannerList(){
        arrBanner.removeAll()
        
        WebServices().hitAPiTogetDetails(serviceType : baseUrlTest + "banner"){ (responseData) in
            let jsonData = responseData?.toJSONString1().data(using: .utf8)!
            let decoder = JSONDecoder()
            let obj = try! decoder.decode(Banner.self, from: jsonData!)
            if obj.status == "1" {
                //   if obj.data!.count > 0 {
                if let arrFeed = obj.data {
                    _  =   arrFeed.map{
                        self.arrBanner.append($0)
                    }
                    self.bannerCollectionView.reloadData()
                    self.bannerCollectionView.delegate = self
                    self.bannerCollectionView.dataSource = self
                }
            }
        }
    }
    
    func serverHitBottomBannerList(){
        arrFooterBanner.removeAll()
        
        WebServices().hitAPiTogetDetails(serviceType : baseUrlTest + "secondary_banner"){ (responseData) in
            let jsonData = responseData?.toJSONString1().data(using: .utf8)!
            let decoder = JSONDecoder()
            let obj = try! decoder.decode(Footerbanner.self, from: jsonData!)
            if obj.status == "1" {
                //   if obj.data!.count > 0 {
                if let arrFeed = obj.data {
                    _  =   arrFeed.map{
                        self.arrFooterBanner.append($0)
                    }
                    self.footerBannerCollectionView.reloadData()
                    self.footerBannerCollectionView.delegate = self
                    self.footerBannerCollectionView.dataSource = self
                }
            }
        }
    }
    
    func serverHitPopularList(){
        arrListing.removeAll()
        self.myloader.showLoader(controller: self)
        // email, password, Auth-key
        let dict = ["lat":"12.70","lng":"74.94", "city":"Manjeshwar"]
        //"ddk_wallet_id":txtFldDDDKWalletID.text!,
        WebServices().POSTFunctiontoGetDetails(data: dict as [String : Any], serviceType: "top_selling", showIndicator: false){ (responseData) in
            DispatchQueue.main.async {
                self.myloader.removeLoader(controller: self)
                let jsonData = responseData?.toJSONString1().data(using: .utf8)!
                let decoder = JSONDecoder()
                do{
                    let obj = try decoder.decode(Listing.self, from: jsonData!)
                    if obj.status == "1" {
                        if let arrFeed = obj.data {
                            _  =   arrFeed.map{
                                self.arrListing.append($0)
                            }
                            for v in self.arrListing {
                                print(v.productImage)
                            }
                            self.listingTblView.reloadData()
                            self.listingTblView.delegate = self
                            self.listingTblView.dataSource = self
                        }
                    }
                }
                catch{
                    print(error.localizedDescription)
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
    
    //topcategory Api
    func serverHitTopCategoryList(){
        arrTopCategory.removeAll()
        self.myloader.showLoader(controller: self)
        let dict = ["lat":"12.70","lng":"74.94", "city":"Manjeshwar"]
        //"ddk_wallet_id":txtFldDDDKWalletID.text!,
        WebServices().POSTFunctiontoGetDetails(data: dict as [String : Any], serviceType: "topsix", showIndicator: false){ (responseData) in
            DispatchQueue.main.async {
                self.myloader.removeLoader(controller: self)
                let jsonData = responseData?.toJSONString1().data(using: .utf8)!
                let decoder = JSONDecoder()
                let obj = try! decoder.decode(TopCategory.self, from: jsonData!)
                
                if obj.status == "1" {
                    if let arrFeed = obj.data {
                        _  =   arrFeed.map{
                            self.arrTopCategory.append($0)
                        }
                        self.topCategoryColllectionView.reloadData()
                        self.topCategoryColllectionView.delegate = self
                        self.topCategoryColllectionView.dataSource = self
                    }
                }
            }
        }
    }
    
    
    //Add cart api
    func serverHitForAddItemCart() {
        // email, password, Auth-key
        let dict = ["user_id":userID, "qty":qtyValue ,"varient_id":varientID , "store_id" : 2] as [String : Any]
        con.holdValue = "cart"
        //"ddk_wallet_id":txtFldDDDKWalletID.text!,
        WebServices().POSTFunctiontoGetDetails(data: dict as [String : Any], serviceType: "ios_cart_add", showIndicator: false){ (responseData) in
            DispatchQueue.main.async {
                print(responseData!)
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
//MARK:- SideMenu Delegate
extension HomeVC: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentMenuAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissMenuAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}

// MARK:- SideMenuActionDelegateDelegate
extension HomeVC : MenuActionDelegate {
    func openSegue(_ segueName: String, sender: AnyObject?) {
        dismiss(animated: true){
            self.performSegue(withIdentifier: segueName, sender: sender)
            
        }
    }
    func reopenMenu(){
        self.performSegue(withIdentifier: "openMenu", sender: nil)
        //performSegue(withIdentifier: "openMenu", sender: nil)
    }
}

// MARK:- Expend Button
extension HomeVC {
    
    fileprivate func configureExpandingMenuButton() {
        let menuButtonSize: CGSize = CGSize(width: 30.0, height: 30.0)
        let menuButton = ExpandingMenuButton(frame: CGRect(origin: CGPoint.zero, size:  CGSize(width: 70.0, height: 70.0)), image: UIImage(named: "chooser-button-tab")!, rotatedImage: UIImage(named: "chooser-button-tab-highlighted")!)
        menuButton.center = CGPoint(x: self.view.bounds.width - 40.0, y: self.view.bounds.height - 130.0)
        self.view.addSubview(menuButton)
        
        func showAlert(_ title: String) {
            let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        let item1 = ExpandingMenuItem(size: menuButtonSize, image: #imageLiteral(resourceName: "share_via") , highlightedImage: #imageLiteral(resourceName: "share_via"), backgroundImage: UIImage(named: "chooser-moment-button"), backgroundHighlightedImage: UIImage(named: "chooser-moment-button-highlighted")) { () -> Void in
            let items = ["This app is my favorite itms-apps://itunes.apple.com/app/id1534372332"]
            let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
            self.present(ac, animated: true)
        }
        
        let item2 = ExpandingMenuItem(size: menuButtonSize, image: #imageLiteral(resourceName: "reviews") , highlightedImage: #imageLiteral(resourceName: "reviews"), backgroundImage: UIImage(named: "chooser-moment-button"), backgroundHighlightedImage: UIImage(named: "chooser-moment-button-highlighted")) { () -> Void in
            self.openAppStore()
        }
        
        let item3 = ExpandingMenuItem(size: menuButtonSize, image: #imageLiteral(resourceName: "my_whatsapp-1") , highlightedImage: #imageLiteral(resourceName: "my_whatsapp-1"), backgroundImage: UIImage(named: "chooser-moment-button"), backgroundHighlightedImage: UIImage(named: "chooser-moment-button-highlighted")) { () -> Void in
            self.whatspp()

        }
        
        let item4 = ExpandingMenuItem(size: menuButtonSize, image: #imageLiteral(resourceName: "call_answer"), highlightedImage: #imageLiteral(resourceName: "call_answer"), backgroundImage: UIImage(named: "chooser-moment-button"), backgroundHighlightedImage: UIImage(named: "chooser-moment-button-highlighted")) { () -> Void in
            guard let number = URL(string: "tel://" + "+919995514341") else { return }
            UIApplication.shared.open(number)
        
        }
        
        menuButton.addMenuItems([item1, item2, item3, item4])
        
        menuButton.willPresentMenuItems = { (menu) -> Void in
            print("MenuItems will present.")
        }
        
        menuButton.didDismissMenuItems = { (menu) -> Void in
            print("MenuItems dismissed.")
        }
    }
    //MARK:- Whatsapp
    func whatspp() {
        
        let phoneNumber =  "+919995514341" // you need to change this number
        let appURL = URL(string: "https://wa.me/\(phoneNumber)")!
        if UIApplication.shared.canOpenURL(appURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(appURL)
            }
        }

    }
    
    //MARK:- openAppStore
    func openAppStore() {
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id1534372332"),
           UIApplication.shared.canOpenURL(url){
            UIApplication.shared.open(url, options: [:]) { (opened) in
                if(opened){
                    print("App Store Opened")
                }
            }
        } else {
            print("Can't Open URL on Simulator")
        }
    }
    
}
//MARK:- CORE LOCATION
extension HomeVC: CLLocationManagerDelegate {
    
    func getCurrentLocation() {
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate =  self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else {
            return
        }
        print( "location = \(locValue.latitude) \(locValue.longitude)")
        getAddressFromLatLon(Latitude: locValue.latitude, Longitude: locValue.longitude)
    }
    
    func getAddressFromLatLon(Latitude: Double, Longitude: Double) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = Latitude
        center.longitude = Longitude
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        print("Location is", loc)
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
                                    {(placemarks, error) in
                                        if (error != nil)
                                        {
                                            print("reverse geodcode fail: \(error!.localizedDescription)")
                                        }
                                        else{
                                        let pm = placemarks! as [CLPlacemark]
                                        
                                        if pm.count > 0 {
                                            let pm = placemarks![0]
                                            var addressString : String = ""
                                            
                                            if pm.subLocality != nil {
                                                addressString = addressString + pm.subLocality! + ", "
                                            }
                                            if pm.thoroughfare != nil {
                                                addressString = addressString + pm.thoroughfare! + ", "
                                            }
                                            if pm.locality != nil {
                                                addressString = addressString + pm.locality! + ", "
                                            }
                                            if pm.country != nil {
                                                addressString = addressString + pm.country! + ", "
                                            }
                                            if pm.postalCode != nil {
                                                addressString = addressString + pm.postalCode! + " "
                                            }
                                            self.lblAddress.text = "\(addressString)"
                                            
                                            print(addressString)
                                        }
                                        }
                                    })
    }
}

