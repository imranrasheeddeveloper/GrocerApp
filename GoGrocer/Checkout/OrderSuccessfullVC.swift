
import UIKit

class OrderSuccessfullVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func shopAction(_ sender: Any) {
        popToHome()
        //poptheViewController()
        tabBarController?.selectedIndex = 0
        
    }
    
    
    func poptheViewController(){
        let storyboard = UIStoryboard.init(name: "Base", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "CartVC") as! CartVC
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    func popToHome() {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        for vc in viewControllers{
            if vc.isKind(of:TabBarVC.self){
                self.navigationController!.popToViewController(vc, animated: true)
                break
            }
        }
    }
    
}
