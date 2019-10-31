# AdHash-iOS

# How to setup AdHash
#### 1. Install pod 'AdHash-iOS'
#### 2. Conform your UIView to AdHashView
#### 3. Configure AdHashManager in AppDelegate file:
    	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    		AdHashManager.publisherID = "0x89c430444df3dc8329aba2c409770fa196b65d3c"
    		AdHashManager.analyticsURL = "https://bidder.adhash.org/protocol.php?action=rtb_sdk"
    		AdHashManager.bidderURL = "https://adhash.org/bidder/protocol.php?action=click"
    		AdHashManager.publisherURL = "https://publisher.whatismycar.com/protocol.php?action=click"
    		AdHashManager.reportURL = "https://google.com.ua"
    		AdHashManager.apiVersion = 1.0
    		return true
    	}
#### 4. Setup your ViewController:
    import UIKit
    import AdHash_iOS
    
    final class ViewController: UIViewController, AdHashViewDelegate {
    	
    	@IBOutlet weak var banner: AdHashView!
    	
    	override func viewDidLoad() {
    		super.viewDidLoad()
    		AdHashManager.bannerWidth = 300
            AdHashManager.bannerHeight = 250
    		banner.adTagId = "AdID"
    		banner.delegate = self
    	}
    	
    	func didClickOnAd(adId: String) {
    		print("Tapped on ad with bannerID: \(adId)")
    	}
    
    	func didClickOnReport(adId: String) {
    		print("Tapped on report with bannerID: \(adId)")
    	}
    
    }
#### 5. Enjoy ;)
 
 ___
 
##### All configurable parameters:
| Property name  |  Type |
| ------------ | ------------ |
| timeZone | Int |
| location | String  |
| publisherID  | String  |
| screenWidth  |  CGFloat |
|  screenHeight |  CGFloat |
| platform  |  String |
|  language |  String |
| model  | String |
| type  | String  |
| connection  | String  |
|  isp | String  |
|  orientation | String  |
|  gps | String  |
| bannerWidth  |  CGFloat |
| bannerHeight  |  CGFloat |
| blockedAdvertisers  | [String]  |
| currentTimestamp  |  String |
| recentAds  |  [[Any]]  |
| apiVersion  | Float  |
| analyticsURL |  String |
| analyticsScreenShotURL  | String  |
|  bidderURL |  String |
|  publisherURL | String  |
|  reportURL | String  |

#### Available delegate methods:
    func didClickOnAd(adId: String)
    func didClickOnReport(adId: String)

