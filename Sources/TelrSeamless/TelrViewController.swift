//
//  ViewController.swift
//  IosAppMPI3DS2
//
//  Created by MacBook  on 7/21/22.
//

import UIKit
import WebKit

public protocol TelrControllerDelegate {
    
    func didPaymentCancel()
    
    func didPaymentSuccess(response:TelrResponseRresult)
    
    func didPaymentFail(messge:String)
}

public class TelrViewController: UIViewController, XMLParserDelegate, UICollectionViewDelegate {
    
    public var delegate : TelrControllerDelegate?
    
//    public struct trxData{
//        var custTitle : String
//        var custFirstName : String
//        var custLastName : String
//        var addLine: String
//        var addCity: String
//        var addRegion : String
//        var addCountry : String
//        var email : String
//        var IPaddrress : String
//        var storeID : String
//        var authKey : String
//        var cartID : String
//        var cartDesc : String
//        var currency : String
//        var trxAmount : Int
//        var test : Int
//        var custref : String
//    }
    
    public var tranDetails :trxData = trxData(custTitle: "Mr", custFirstName: "CustTest", custLastName: "CustTestLast", addLine: "Dubai Silicon", addCity: "DSO", addRegion: "Dubai", addCountry: "AE", email: "jb@gmail.com", IPaddrress: "192.168.1.2", storeID: "15164", authKey: "w7HrQ-N5xKK^5nrV", cartID: "Trx_123456", cartDesc: "testing Trx", currency: "AED", trxAmount: 1, test: 1, custref: "JB123" )
    public var customBackButton : UIButton?
    public var pageTitle : String = "Payment"
    
    //UI Colour
    public var primaryColour = UIColor(red: 0.0, green: 1.5, blue: 0.57, alpha: 1)
    public var secoundryColour = UIColor(red: 0.45, green: 0.46, blue: 0.47, alpha: 1.0)
    public var backgroundColour = UIColor(red: 1.89, green: 1.9, blue: 1.93, alpha: 1.0)
    public var textColour = UIColor.darkText
    
    private var scrollView: UIScrollView!
    private var myTableView: UITableView!
    private var savedCardView: UIView!
    private var indexSelected : Int!
    private var newCardUiview: UIView!
    private var cvvtext: UITextField!
    private var cardNumber : SwiftMaskField!
    private var cardMmYy : SwiftMaskField!
    private var cardCvv : UITextField!
    
    private var saveCard :Int = 1
    private var cardlen = 19
    private var cvvLen = 3
    private var mmyyLen = 5
    
    private var SCardList : [Scard] = []
    
    public struct Scard {
        var Expiry : String
        var Name : String
        var Transaction_ID : String
    }
    
    private let webView: WKWebView = WKWebView()

    private var sessionID :String = ""
    private var redirectHTML: String = ""
    private var requestBody : String = ""
    private var cardNumberFormated = ""
    
    public var getSavedCards = ["api_storeid ":"15164", "api_authkey":"w7HrQ-N5xKK^5nrV","api_testmode":"1", "api_custref":"JB123"] as Dictionary<String, String>
    
 
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
        showActivityInd(message: "Checking for Saved Cards")
        
        
//        getCardsinfo { result in
//            self.hideActivityInd()
//            print(self.SCardList)
//
//        }
        self.navigationItem.title = pageTitle
        print(tranDetails.IPaddrress)
        createScrollView()
        createTableView()
        self.hideKeyboardWhenTappedAround()
        addNewCardView()
        addWebView()
        addBackButton()
    }
    public override func viewWillAppear(_ animated: Bool) {
        getCardsinfo { result in
            self.hideActivityInd()
            print(self.SCardList)
            
        }
    }
    
    func addWebView()  {
        webView.navigationDelegate = self
        webView.frame  = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        webView.scrollView.alwaysBounceVertical = false
        
        webView.scrollView.isDirectionalLockEnabled = true
        
        webView.backgroundColor = UIColor.white
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        webView.scrollView.minimumZoomScale = 1.0;
        self.scrollView.addSubview(webView)
        webView.isHidden = true
    }
    
    func createScrollView(){
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        scrollView.backgroundColor = backgroundColour//.systemTeal
                // Set the contentSize to 100 times the height of the phone's screen so that we can add 100 images in the next step
                scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: UIScreen.main.bounds.height+UIScreen.main.bounds.height/8)
        scrollView.delegate = self
                view.addSubview(scrollView)
    }
    
    func createTableView(){
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        savedCardView = UIView(frame: CGRect(x: 10, y: barHeight, width: self.view.frame.width - 20, height: 50))
        savedCardView.backgroundColor = primaryColour
        let label = UILabel()
        label.frame = CGRect(x: 10, y: 13, width: 200, height: 20)
        label.text = "Pay by Card"
        label.textColor = textColour
        label.font = UIFont.systemFont(ofSize: 20)
        savedCardView.addSubview(label)
        scrollView.addSubview(savedCardView)
        
        cvvtext = UITextField(frame: CGRect(x: UIScreen.main.bounds.width-150, y: 5, width: 100, height: 40))
        cvvtext.placeholder = "CVV"
        //cvvtext.backgroundColor = UIColor.gray
        cvvtext.font = UIFont.systemFont(ofSize: 17)
        cvvtext.borderStyle = UITextField.BorderStyle.roundedRect
        cvvtext.autocorrectionType = UITextAutocorrectionType.no
        cvvtext.keyboardType = UIKeyboardType.numberPad
        cvvtext.returnKeyType = UIReturnKeyType.done
        cvvtext.clearButtonMode = UITextField.ViewMode.whileEditing
        cvvtext.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        
        cvvtext.delegate = self
        cvvtext.layer.borderWidth = 1.5
        cvvtext.layer.cornerRadius = 5
        cvvtext.layer.borderColor = secoundryColour.cgColor
       
        savedCardView.addSubview(cvvtext)

        
        myTableView = UITableView()
        //UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
        myTableView.frame = CGRect(x: 10, y: barHeight+50, width: self.view.frame.width - 20, height: 200)
        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
        myTableView.dataSource = self
        myTableView.delegate = self
        myTableView.layer.borderWidth = 0.5
        myTableView.layer.borderColor = UIColor.gray.cgColor
        scrollView.addSubview(myTableView)
    }
    
    func addNewCardView(){
        newCardUiview = UIView(frame: CGRect(x: 10, y: myTableView.bounds.height+105, width: UIScreen.main.bounds.width-20, height: 200))
        newCardUiview.backgroundColor = backgroundColour
        newCardUiview.layer.borderWidth = 0.5
        newCardUiview.layer.borderColor = UIColor.gray.cgColor
        
        scrollView.addSubview(newCardUiview)
        
        let addCard = UIView(frame: CGRect(x: 0, y: 0, width: newCardUiview.bounds.width, height: 50))
        addCard.backgroundColor = primaryColour
        newCardUiview.addSubview(addCard)
        let label = UILabel()
        label.frame = CGRect(x: 10, y: 13, width: 200, height: 20)
        label.text = "Add Credit/Debit Card"
        label.textColor = textColour
        label.font = UIFont.systemFont(ofSize: 20)
        addCard.addSubview(label)
        let visaImg = UIImageView(frame: CGRect(x: addCard.bounds.width-100, y: 5, width: 45, height: 30))
        visaImg.image = UIImage (named: "visa icon.png") ?? nil
        //addCard.addSubview(visaImg)
        
        cardNumber = SwiftMaskField(frame: CGRect(x: 10, y: 55,    width: newCardUiview.bounds.width - 20, height: 40))
        cardNumber.placeholder = "16 Digit Card Number"
        //cvvtext.backgroundColor = UIColor.gray
        cardNumber.font = UIFont.systemFont(ofSize: 17)
        cardNumber.borderStyle = UITextField.BorderStyle.roundedRect
        cardNumber.autocorrectionType = UITextAutocorrectionType.no
        cardNumber.keyboardType = UIKeyboardType.numberPad
        cardNumber.returnKeyType = UIReturnKeyType.done
        cardNumber.clearButtonMode = UITextField.ViewMode.whileEditing
        cardNumber.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        cardNumber.delegate = self
        cardNumber.layer.borderWidth = 1.5
        cardNumber.layer.cornerRadius = 5
        cardNumber.layer.borderColor = secoundryColour.cgColor
        cardNumber.maskString = "NNNN NNNN NNNN NNNN"
        cardNumber.textAlignment = .center
        newCardUiview.addSubview(cardNumber)
        
        cardMmYy = SwiftMaskField(frame: CGRect(x: 10, y: 100,    width: (newCardUiview.bounds.width/2) - 20, height: 40))
        cardMmYy.placeholder = "MM/YY"
        //cvvtext.backgroundColor = UIColor.gray
        cardMmYy.font = UIFont.systemFont(ofSize: 17)
        cardMmYy.borderStyle = UITextField.BorderStyle.roundedRect
        cardMmYy.autocorrectionType = UITextAutocorrectionType.no
        cardMmYy.keyboardType = UIKeyboardType.numberPad
        cardMmYy.returnKeyType = UIReturnKeyType.done
        cardMmYy.clearButtonMode = UITextField.ViewMode.whileEditing
        cardMmYy.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        cardMmYy.delegate = self
        cardMmYy.layer.borderWidth = 1.5
        cardMmYy.layer.cornerRadius = 5
        cardMmYy.layer.borderColor = secoundryColour.cgColor
        cardMmYy.maskString = "NN/NN"
        cardMmYy.textAlignment = .center
        newCardUiview.addSubview(cardMmYy)
        
        cardCvv = UITextField(frame: CGRect(x: (newCardUiview.bounds.width/2) , y: 100,    width: (newCardUiview.bounds.width/2) - 10, height: 40))
        cardCvv.placeholder = "CVV"
        //cvvtext.backgroundColor = UIColor.gray
        cardCvv.font = UIFont.systemFont(ofSize: 17)
        cardCvv.borderStyle = UITextField.BorderStyle.roundedRect
        cardCvv.autocorrectionType = UITextAutocorrectionType.no
        cardCvv.keyboardType = UIKeyboardType.numberPad
        cardCvv.returnKeyType = UIReturnKeyType.done
        cardCvv.clearButtonMode = UITextField.ViewMode.whileEditing
        cardCvv.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        cardCvv.delegate = self
        cardCvv.layer.borderWidth = 1.5
        cardCvv.layer.cornerRadius = 5
        cardCvv.layer.borderColor = secoundryColour.cgColor
        cardCvv.textAlignment = .center
        newCardUiview.addSubview(cardCvv)
        
        let saveCardSwitch = UISwitch(frame:CGRect(x: 20, y: 150, width: 0, height: 0))
        saveCardSwitch.isOn = true
        saveCardSwitch.setOn(true, animated: false)
        saveCardSwitch.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)
        newCardUiview.addSubview(saveCardSwitch)
        
        let label1 = UILabel()
        label1.frame = CGRect(x: 80, y: 155, width: 300, height: 20)
        label1.text = "Save this card for future payments"
        label1.textColor = UIColor.black
        label1.font = UIFont.systemFont(ofSize: 14)
        newCardUiview.addSubview(label1)
        
        let button = UIButton()
        button.frame = CGRect(x: scrollView.frame.size.width/4, y: 520, width: scrollView.frame.size.width/2, height: 50)
        button.backgroundColor = primaryColour
        button.titleColor(for: .normal)
        button.setTitle("Pay (AED: \(tranDetails.trxAmount))", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        button.setTitleColor(textColour, for: .normal)
        scrollView.addSubview(button)
    }
    
    @objc func insertchar(textfield: UITextField){
        
    }
    
    func addBackButton() {
        
        if let customBackButton = self.customBackButton {
            
            customBackButton.addTarget(self, action: #selector(self.backAction(_:)), for: .touchUpInside)
            
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customBackButton)
        
        }else{
            
            let backButton = UIButton(type: .custom)
            
            backButton.setTitle("Close", for: .normal)
            
            backButton.setTitleColor(backButton.tintColor, for: .normal)
            
            backButton.addTarget(self, action: #selector(self.backAction(_:)), for: .touchUpInside)
            
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        }
       
    }
    @objc func backAction(_ sender: UIButton) {
       
        self.delegate?.didPaymentCancel()
    
        self.dismiss(animated: true, completion: nil)
    
        let _ = self.navigationController?.popViewController(animated: true)
    }

    @objc func buttonAction() {
       print("Button tapped")
        let CnumText = cardNumber.text?.replacingOccurrences(of: " ", with: "")
        let CmmyyText = cardMmYy.text!
        let CcvvText = cardCvv.text!
        let CcvvText1 = cvvtext.text!
        
        if ((CnumText?.count == 16) && (CmmyyText.count == mmyyLen) && (CcvvText.count == cvvLen)) {
            print(CmmyyText)
            print(CmmyyText.prefix(2))
            print(CmmyyText.suffix(2))
            print(CnumText ?? "")
            let mm = Int(CmmyyText.prefix(2)) ?? 0
            if(mm > 12){
                showAlerrt(title: "Wrong Expiry", msg: "Please enter the correct expiry")
            }else{
                requestBody = """
        <?xml version="1.0" encoding="UTF-8"?>
        <remote>
            <store>\(tranDetails.storeID)</store>
            <key>\(tranDetails.authKey)</key>
            <tran>
                <type>Sale</type>
                <class>ecom</class>
                <cartid>\(tranDetails.cartID)</cartid>
                <description>\(tranDetails.cartDesc)</description>
                <currency>\(tranDetails.currency)</currency>
                <amount>\(tranDetails.trxAmount)</amount>
                <test>\(tranDetails.test)</test>
                <threeds2enabled>1</threeds2enabled>
                <firstref></firstref>
            </tran>
            <card>
                <number>\(CnumText ?? "")</number>
                <expiry>
                    <month>\(CmmyyText.prefix(2))</month>
                    <year>\(CmmyyText.suffix(2))</year>
                </expiry>
                <savecard>\(saveCard)</savecard>
                <cvv>\(CcvvText)</cvv>
                <custref>\(tranDetails.custref)</custref>
            </card>
            <browser>
                <agent>Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36</agent>
                <accept>*/*</accept>
            </browser>
            <mpi>
             <returnurl>https://www.telr.com</returnurl>
          </mpi>
        </remote>
        """
                startMPICAll(requestBody: requestBody)
            }
        }else if((indexSelected != nil) && (CcvvText1.count == cvvLen)){
            print(indexSelected ?? 0)
            requestBody = """
    <?xml version="1.0" encoding="UTF-8"?>
    <remote>
        <store>\(tranDetails.storeID)</store>
        <key>\(tranDetails.authKey)</key>
        <tran>
            <type>Sale</type>
            <class>ecom</class>
            <cartid>\(tranDetails.cartID)</cartid>
            <description>\(tranDetails.cartDesc)</description>
            <currency>\(tranDetails.currency)</currency>
            <amount>\(tranDetails.trxAmount)</amount>
            <test>\(tranDetails.test)</test>
            <threeds2enabled>1</threeds2enabled>
            <firstref>\(self.SCardList[indexSelected].Transaction_ID)</firstref>
        </tran>
        <card>
            <number>4440000009900010</number>
            <expiry>
                <month>1</month>
                <year>29</year>
            </expiry>
            <savecard>1</savecard>
            <cvv>\(CcvvText1)</cvv>
            
        </card>
        <browser>
            <agent>Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36</agent>
            <accept>*/*</accept>
        </browser>
        <mpi>
         <returnurl>https://www.telr.com</returnurl>
      </mpi>
    </remote>
    """
            startMPICAll(requestBody: requestBody)
        }else{
            showAlerrt(title:"Error", msg: "Please enter Valid card details to proceed")
        }
        
    }
    
    @objc func switchValueDidChange(_ sender: UISwitch!) {
        if (sender.isOn){
            print("on")
            saveCard = 1
        }
        else{
            saveCard = 0
            print(saveCard)
        }
    }
    
    @IBAction func startAPiCallMethod(_ sender: Any) {
        
        self.showAlerrt(title: "MPI #3DS2 API", msg: "All calling is started, please wait for few movements as we connecting to server for OTP challenge!")
        
        //startMPICAll()
        
    }
    
    // Observe value
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if let key = change?[NSKeyValueChangeKey.newKey] {
//            print("observeValue \(key)") // url value
//        }
//    }
    
    func loadWebView(redirectHtml:String){
        
        let htmlStg :String = """
        <html>
        <head></head>
        <body>
        <script type="text/javascript">
        function show3DSChallenge(){
                var redirect_html="\(redirectHtml)";
                var txt = document.createElement("textarea");
                txt.innerHTML = redirect_html;
                redirect_html_new = decodeURIComponent(txt.value);
                document.body.innerHTML = redirect_html_new;
                eval(document.getElementById('authenticate-payer-script').text)
                }
        show3DSChallenge();
        </script>
        </body>
        </html>
        """
        let htmlStg1 :String = """
        <html>
        <head></head>
        <body>
        <script type="text/javascript">
        function show3DSChallenge(){
                var redirect_html="%3cdiv%20id%3d%22threedsChallengeRedirect%22%20xmlns%3d%22http%3a%2f%2fwww.w3.org%2f1999%2fhtml%22style%3d%22%20height%3a%20100vh%22%3e%20%3cform%20id%20%3d%22threedsChallengeRedirectForm%22%20method%3d%22POST%22%20action%3d%22https%3a%2f%2fap.gateway.mastercard.com%2facs%2fvisa%2fv2%2fprompt%22%20target%3d%22challengeFrame%22%3e%20%3cinput%20type%3d%22hidden%22%20name%3d%22creq%22%20value%3d%22eyJ0aHJlZURTU2VydmVyVHJhbnNJRCI6ImQxZGIxMzE3LTI3ODItNGU5Yi05NGIxLTk5NGYyMGFhOTU5MCJ9%22%20%2f%3e%20%3c%2fform%3e%20%3ciframe%20id%3d%22challengeFrame%22%20name%3d%22challengeFrame%22%20width%3d%22100%25%22%20height%3d%22100%25%22%20%3e%3c%2fiframe%3e%20%3cscript%20id%3d%22authenticate-payer-script%22%3e%20var%20e%3ddocument.getElementById(%22threedsChallengeRedirectForm%22);%20if%20(e)%20%7b%20e.submit();%20if%20(e.parentNode%20!%3d%3d%20null)%20%7b%20e.parentNode.removeChild(e);%20%7d%20%7d%20%3c%2fscript%3e%20%3c%2fdiv%3e";
                var txt = document.createElement("textarea");
                txt.innerHTML = redirect_html;
                redirect_html_new = decodeURIComponent(txt.value);
                document.body.innerHTML = redirect_html_new;
                eval(document.getElementById('authenticate-payer-script').text)
                }
        show3DSChallenge();
        </script>
        </body>
        </html>
        """
        print(htmlStg)
        hideActivityInd()
        
        webView.isHidden = false
        webView.loadHTMLString(htmlStg, baseURL: nil)
        webView.scrollView.minimumZoomScale = 4.0;
        //self.navigationController?.pushViewController(webView, animated: true)
    }

    func startMPICAll(requestBody: String){
        showActivityInd(message: "Loading... Please wait")
        let session = URLSession(configuration: .default)
        //let url = URL(string: "https://uat-secure.telrdev.com/gateway/remote_mpi.xml")! //<-
        //https://aws-local.telrdev.com/gateway/remote_mpi.xml
        //https://secure.telr.com/gateway/remote_mpi.xml
        let url = URL(string: "https://secure.telr.com/gateway/remote_mpi.xml")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type") //<-
        request.httpBody = """
        <?xml version="1.0" encoding="UTF-8"?>
        <remote>
            <store>15164</store>
            <key>w7HrQ-N5xKK^5nrV</key>
            <tran>
                <type>sale</type>
                <class>ecom</class>
                <cartid>atZGs9C762</cartid>
                <description>Test Remote API</description>
                <currency>AED</currency>
                <amount>1</amount>
                <test>1</test>
                <threeds2enabled>1</threeds2enabled>
            </tran>
            <card>
                <number>4440000009900010</number>
                <expiry>
                    <month>01</month>
                    <year>29</year>
                </expiry>
                <cvv>123</cvv>
            </card>
            <browser>
                <agent>Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36</agent>
                <accept>*/*</accept>
            </browser>
                <mpi>
                <returnurl>https://www.telr.com</returnurl>
            </mpi>
        </remote>
        """.data(using: .utf8)
        print(requestBody)
        request.httpBody = requestBody.data(using: .utf8)
        let task = session.dataTask(with: request) { data, response, error in
            // do something with the result
            print(data)
            
            if let data = data {
                print(String(data: data, encoding: .utf8))
                
                let str = String(data: data, encoding: .utf8)!
                print(str)

                
                let parser = XMLParser(data: data)
                parser.delegate = self
                parser.parse()

                DispatchQueue.main.async {
                    let xmlresponse = XML.parse(data)
                    if let meg = xmlresponse["remote", "mpi", "redirecthtml"].text{
                    self.sessionID = xmlresponse["remote", "mpi", "session"].text!
                        print(self.sessionID)
                    self.redirectHTML =  xmlresponse["remote", "mpi", "redirecthtml"].text!
                        if (self.redirectHTML.isEmpty){
                        //print(self.redirectHTML)
                            
                            self.showAlerrt(title: "Error", msg: "Card is not supported")
                        }else{
                            self.updateActivityIndMessage(message: "Preparing for OTP Challenge")
                            self.loadWebView(redirectHtml: self.redirectHTML)
                        }
                    }
                    else{
                        DispatchQueue.main.async {
                            self.hideActivityInd()
                            self.delegate?.didPaymentFail(messge: "Card is not supported")
                            self.navigationController?.popViewController(animated: true)
                            //self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
                
                //print(message)
            } else {
                print("no data")
            }
        }
        task.resume()

    }
    
    func verifyAuthAPICall(){
        
        let session = URLSession(configuration: .default)
        //let url = URL(string: "https://uat-secure.telrdev.com/gateway/remote.xml")! //<-
        //https://secure.telr.com/gateway/remote.xml
        let url = URL(string: "https://secure.telr.com/gateway/remote.xml")! //<-
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type") //<-
        //<threeds2enabled>1</threeds2enabled> - added for backword compatibility
        // //<firstref>\(self.SCardList[indexSelected].Transaction_ID)</firstref>
        var reqBody = ""
        self.cardNumberFormated = cardNumber.text?.replacingOccurrences(of: " ", with: "") ?? ""
        if((indexSelected != nil) && (cvvtext.text?.count == cvvLen)){
            reqBody = """
            <?xml version="1.0" encoding="UTF-8"?>
            <remote>
                <store>\(tranDetails.storeID)</store>
                <key>\(tranDetails.authKey)</key>
                <tran>
                    <type>sale</type>
                    <class>ecom</class>
                    <cartid>\(tranDetails.cartID)</cartid>
                    <description>\(tranDetails.cartDesc)</description>
                    <test>\(tranDetails.test)</test>
                    <currency>\(tranDetails.currency)</currency>
                    <amount>\(tranDetails.trxAmount)</amount>
                    <threeds2enabled>1</threeds2enabled>
                           <firstref>\(self.SCardList[indexSelected].Transaction_ID)</firstref>
                </tran>
                <card>
                     <number>4440000009900010</number>
                     <expiry>
                         <month>1</month>
                         <year>29</year>
                    </expiry>
                    <cvv>\(cvvtext.text ?? "")</cvv>
                </card>
                <billing>
                    <name>
                        <title>\(tranDetails.custTitle)</title>
                        <first>\(tranDetails.custFirstName)</first>
                        <last>\(tranDetails.custLastName)</last>
                    </name>
                    <address>
                        <line1>\(tranDetails.addLine)</line1>
                        <city>\(tranDetails.addCity)</city>
                        <region>\(tranDetails.addRegion)</region>
                        <country>\(tranDetails.addCountry)</country>
                    </address>
                    <email>\(tranDetails.email)</email>
                    <ip>\(tranDetails.IPaddrress)</ip>
                </billing>
                <mpi>
                    <session>\(self.sessionID)</session>
                </mpi>
            </remote>
            """
        }else{
            reqBody = """
            <?xml version="1.0" encoding="UTF-8"?>
            <remote>
                <store>\(tranDetails.storeID)</store>
                <key>\(tranDetails.authKey)</key>
                <tran>
                    <type>sale</type>
                    <class>ecom</class>
                    <cartid>\(tranDetails.cartID)</cartid>
                    <description>\(tranDetails.cartDesc)</description>
                    <test>\(tranDetails.test)</test>
                    <currency>\(tranDetails.currency)</currency>
                    <amount>\(tranDetails.trxAmount)</amount>
                    <threeds2enabled>1</threeds2enabled>
                </tran>
                <card>
                     <number>\(cardNumberFormated)</number>
                     <expiry>
                         <month>\(cardMmYy.text?.prefix(2) ?? "")</month>
                         <year>\(cardMmYy.text?.suffix(2) ?? "")</year>
                    </expiry>
                    <cvv>\(cardCvv.text ?? "")</cvv>
                    
                </card>
                <billing>
                    <name>
                        <title>\(tranDetails.custTitle)</title>
                        <first>\(tranDetails.custFirstName)</first>
                        <last>\(tranDetails.custLastName)</last>
                    </name>
                    <address>
                        <line1>\(tranDetails.addLine)</line1>
                        <city>\(tranDetails.addCity)</city>
                        <region>\(tranDetails.addRegion)</region>
                        <country>\(tranDetails.addCountry)</country>
                    </address>
                    <email>\(tranDetails.email)</email>
                    <ip>\(tranDetails.IPaddrress)</ip>
                </billing>
                <mpi>
                    <session>\(self.sessionID)</session>
                </mpi>
            </remote>
            """
        }
        
        print(reqBody)
        request.httpBody = reqBody.data(using: .utf8)
        let task = session.dataTask(with: request) { data, response, error in
            // do something with the result
            print(data)
            if let data = data {
                print(String(data: data, encoding: .utf8))
                
                let str = String(data: data, encoding: .utf8)!
                print(str)

                let parser = XMLParser(data: data)
                parser.delegate = self
                parser.parse()

                DispatchQueue.main.async {
                    let xmlresponse = XML.parse(data)
                    if let meg = xmlresponse["remote", "auth", "message"].text{
                    let messg = xmlresponse["remote", "auth", "message"].text!
                        print(self.sessionID)
                        
                        let trsrRref =  xmlresponse["remote", "auth", "tranref"].text!
                        let authStatus =  xmlresponse["remote", "auth", "status"].text!
                            self.hideActivityInd()
                            //self.showAlerrt(title: messg, msg: "Auth Status: **\(authStatus)** with Transaction refference:\(trsrRref)")
                        if (messg == "Authorised"){
                            let resp = TelrResponseRresult()
                            resp.status = xmlresponse["remote", "auth", "status"].text!
                            resp.code = xmlresponse["remote", "auth", "code"].text!
                            resp.message = xmlresponse["remote", "auth", "message"].text!
                            resp.transRref = xmlresponse["remote", "auth", "tranref"].text!
                            resp.avs =  xmlresponse["remote", "auth", "avs"].text!
                            resp.trace =  xmlresponse["remote", "auth", "trace"].text!
                            resp.cardDesc = xmlresponse["remote", "payment", "description"].text!
                            resp.cardEnd = xmlresponse["remote", "payment", "card_end"].text!
                            resp.cardBin = xmlresponse["remote", "payment", "card_bin"].text!
                            print(resp.message ?? "")
                            DispatchQueue.main.async {
                                self.delegate?.didPaymentSuccess(response: resp)
                                self.navigationController?.popViewController(animated: true)
                                //self.dismiss(animated: true, completion: nil)
                            }
                            
                        
                           // let _ = self.navigationController?.popViewController(animated: true)
                        }else{
                            self.delegate?.didPaymentFail(messge: messg)
                        
                            self.navigationController?.popViewController(animated: true)
                        
                          //  let _ = self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
                //print(message)
            } else {
                self.hideActivityInd()
                print("no data")
            }
        }
        task.resume()

    }
    
    
    func showAlerrt(title:String, msg:String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alert, animated: true)
    }
    
    func showActivityInd(message: String)  {
        let Ac = ALLoadingView.manager
        Ac.resetToDefaults()
        Ac.blurredBackground = true
        Ac.animationDuration = 1.0
        Ac.itemSpacing = 30.0
        Ac.showLoadingView(ofType: .messageWithIndicator, windowMode: .fullscreen)
        Ac.messageText = message
        //Ac.hideLoadingView(withDelay: 5.0)
    }
    
    func updateActivityIndMessage(message: String){
        ALLoadingView.manager.messageText = message
    }
    
    func hideActivityInd() {
        ALLoadingView.manager.hideLoadingView(withDelay: 0.0)
    }
    
    public func getCardsinfo(completion: @escaping(Bool) -> ()) {
        
        //let params = ["api_storeid ":tranDetails.storeID, "api_authkey":tranDetails.authKey,"api_testmode":tranDetails.test,"api_custref":tranDetails.custref] as Dictionary<String, String>
        print(getSavedCards)
        //var request = URLRequest(url: URL(string: "https://secure.telr.com/gateway/savedcardslist.json")!)
        
        //var request = URLRequest(url: URL(string: "https://aws-local.telrdev.com/gateway/savedcardslist.json")!)
        //https://aws-local.telrdev.com/gateway/savedcardslist.json
    //https://secure.telr.com/gateway/savedcardslist.json
        var request = URLRequest(url: URL(string: "https://secure.telr.com/gateway/savedcardslist.json")!)// liveURL
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = getSavedCards.percentEncoded()
        URLSession.shared.dataTask(with: request) {data, res, err in
            if let data = data {
                
                let json = try? JSONSerialization.jsonObject(with: data) as? Dictionary<String, AnyObject>
                print(json as Any)
                if let SavedCardListResponse = json?["SavedCardListResponse"] as?  Dictionary<String, AnyObject> {
                    //print("response :\(SavedCardListResponse)")
                    if let code = SavedCardListResponse["Code"] as? Int {
                        if(code==200){
                            if let data2 = SavedCardListResponse["data"] as? [Any] {
                                guard let data = try? JSONSerialization.data(withJSONObject: data2, options: []) else {
                                    //completion("")
                                    return
                                }
                                let theList = SavedCardListResponse["data"] as! NSArray
                                self.SCardList.removeAll()
                                for name in theList {
                                    print((name as AnyObject).object(forKey: "Expiry") as! String)
                                    let exp = (name as AnyObject).object(forKey: "Expiry") as! String
                                    let nam = (name as AnyObject).object(forKey: "Name") as! String
                                    let trx = (name as AnyObject).object(forKey: "Transaction_ID") as! String
                                    let cobj = Scard(Expiry: exp, Name: nam, Transaction_ID: trx)
                                    self.SCardList.append(cobj)
                                    DispatchQueue.main.async {
                                        self.myTableView.reloadData()
                                    }
                                }
                                
                                let convertedString = String(data: data, encoding: String.Encoding.utf8)
                                //print("converted Array\(theList)" )
                                
                                DispatchQueue.main.async {
                                    completion(true)
                                    self.hideActivityInd()
                                 
                                }
                            }else {
                                DispatchQueue.main.async {
                                completion(false)
                                self.hideActivityInd()
                                    self.delegate?.didPaymentFail(messge: "Authkey mismatch")
                                self.navigationController?.popViewController(animated: true)
                                }
                            }
                        }else {
                            if (code == 105){
                                completion(false)
                                self.hideActivityInd()
                            }else {
                            DispatchQueue.main.async {
                            completion(false)
                            self.hideActivityInd()
                                self.delegate?.didPaymentFail(messge: "Authkey mismatch")
                            self.navigationController?.popViewController(animated: true)
                            }
                            }
                        }
                       
                        
                    }else {
                        DispatchQueue.main.async {
                        completion(false)
                        self.hideActivityInd()
                            self.delegate?.didPaymentFail(messge: "Authkey mismatch")
                        self.navigationController?.popViewController(animated: true)
                        }
                    }
                }else {
                    DispatchQueue.main.async {
                    completion(false)
                    self.hideActivityInd()
                    self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }.resume()
        
    }

}



extension TelrViewController : WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate{
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error)
      {
            print(error.localizedDescription)
       }
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            
            if let host = navigationAction.request.url?.host {
                //print(#function, host)
                if host.contains("telr.com") {
                    
                    decisionHandler(.cancel)
                    DispatchQueue.main.async {
                        
                        webView.isHidden = true
                        self.showActivityInd(message: "Verifying the Payment")
                        self.verifyAuthAPICall()
                    }
                    return
                }
            }
            
            decisionHandler(.allow)
        }
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!)
       {
            //        UIApplication.shared.isNetworkActivityIndicatorVisible = true
            print("Strat to load")
           let when = DispatchTime.now() + 10  // No waiting time
           DispatchQueue.main.asyncAfter(deadline: when) {
               
           }
       }

//    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//        print("in challenge")
//    }
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

        if (webView.url?.path.contains("https://www.telr.com"))!{
            print("redirect happening!!")
        }
    }
    public func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("redirect happening!! new ")
        
    }
}


extension TelrViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
        print("Value: \(SCardList[indexPath.row])")
        indexSelected = indexPath.row
        DispatchQueue.main.async {
            tableView.reloadData()
        }
        
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SCardList.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath)
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: "MyCell")

        if ((SCardList.count) != 0){
            
            cell.textLabel?.text = "XXXX XXXX XXXX \(SCardList[indexPath.row].Name.suffix(4))"
        cell.detailTextLabel?.text = SCardList[indexPath.row].Expiry as! String
            if SCardList[indexPath.row].Name.range(of:"Vi") != nil {
                cell.imageView?.image = UIImage.init(named: "visa icon.png")
                
            }else{
                cell.imageView?.image = UIImage.init(named: "Mastercard-logo.png")
            }
        }else{
            cell.textLabel?.text = ""
            cell.detailTextLabel?.text = ""
            if #available(iOS 13.0, *) {
                cell.imageView?.image = UIImage(systemName: "creditcard")
            } else {
                // Fallback on earlier versions
            }
        }
        
        if(indexPath.row == indexSelected){
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        }else{
            cell.accessoryType = UITableViewCell.AccessoryType.none
        }
            return cell
       
    }
    
    public  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

extension TelrViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(TelrViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


extension TelrViewController : UITextFieldDelegate {

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if(textField == cardNumber){
           let currentText = textField.text! + string
            print(currentText.count)
           return currentText.count <= cardlen
        }
        
        if(textField == cardCvv || textField == cvvtext){
           let currentText = textField.text! + string
            print(currentText.count)
           return currentText.count <= cvvLen
        }
        if(textField == cardMmYy){
            var currentText = textField.text! + string
            print(currentText.count)
//            if (currentText.count == 2){
//                currentText.insert("/", at: currentText.endIndex)
//                cardMmYy.text = currentText
//                //print(currentText+"/")
//            }
            
           return currentText.count <= mmyyLen
            
        }

        return true;
      }
}

extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    public static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}


