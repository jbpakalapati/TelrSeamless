#Telr Seamless SDK

Import Package Dependencies:

Github url : https://github.com/jbpakalapati/TelrSeamless.git 

 

![image](https://media.giphy.com/media/FkqGHZv7G5tgjNWdK7/giphy.gif).      ![image](https://media.giphy.com/media/WiloFfKKy7ZUNHqRbp/giphy.gif)

## Telr React Native
![image](https://media.giphy.com/media/BVFlNHPzXeNZA4pAiL/giphy.gif)


Confirm to TelrControllerDelegate & implement 

didpaymentCancel()
didPaymentSuccess(Response)
didPaymentFailed()


## Change Banner Colours

paymentPage = TelrViewController()
        paymentPage?.primaryColour = UIColor(red: 0.0, green: 1.5, blue: 0.57, alpha: 1)
        paymentPage?.secoundryColour = UIColor(red: 0.45, green: 0.46, blue: 0.47, alpha: 1.0)
        paymentPage?.backgroundColour = UIColor(red: 1.89, green: 1.9, blue: 1.93, alpha: 1.0)
        paymentPage?.textColour = UIColor.darkText
        paymentPage?.pageTitle = "SMC Auto Payment"



Provide payment information:

paymentPage?.getSavedCards = ["api_storeid ":"15996", "api_authkey":"BG88b#FBFpX^xSzw","api_testmode":"0", "api_custref":"JB123456"] as Dictionary<String, String>
        
        
        paymentPage?.tranDetails = trxData(custTitle: "Mr", custFirstName: "CustTest", custLastName: "CustTestLast", addLine: "Dubai Silicon", addCity: "DSO", addRegion: "Dubai", addCountry: "AE", email: "jb@gmail.com", IPaddrress: "217.165.137.87", storeID: "15996", authKey: "BG88b#FBFpX^xSzw", cartID: "Trx_123456", cartDesc: "testing Trx", currency: "AED", trxAmount: 1, test: 0, custref: "JB123456" )
        
        
![image](https://user-images.githubusercontent.com/116155833/214555991-b528f9a1-51c9-4cb0-bf02-7a7386ec6803.png)


