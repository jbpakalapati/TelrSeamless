//
//  File.swift
//  
//
//  Created by MacBook  on 10/20/22.
//

import Foundation


public struct trxData{
    
    
    public var custTitle : String
    public var custFirstName : String
    public var custLastName : String
    public var addLine: String
    public var addCity: String
    public var addRegion : String
    public var addCountry : String
    public var email : String
    public var IPaddrress : String
    public var storeID : String
    public var authKey : String
    public var cartID : String
    public var cartDesc : String
    public var currency : String
    public var trxAmount : Int
    public var test : Int
    public var custref : String
    
    public init(custTitle: String, custFirstName : String, custLastName : String, addLine: String, addCity: String, addRegion : String, addCountry : String, email : String, IPaddrress : String, storeID : String, authKey : String, cartID : String, cartDesc : String, currency : String, trxAmount : Int, test : Int, custref : String) {
        
        self.custTitle = custTitle
        self.custFirstName = custFirstName
        self.custLastName = custLastName
        self.addLine = addLine
        self.addCity = addCity
        self.addRegion = addRegion
        self.addCountry = addCountry
        self.email = email
        self.IPaddrress = IPaddrress
        self.storeID = storeID
        self.authKey = authKey
        self.cartID = cartID
        self.cartDesc = cartDesc
        self.currency = currency
        self.trxAmount = trxAmount
        self.test = test
        self.custref = custref
        
        }
}





