//
//  LoginAsyncTask.swift
//  K12Net
//
//  Created by Tarik Canturk on 23/06/15.
//  Copyright (c) 2015 Tarik Canturk. All rights reserved.
//

import Foundation;
import UIKit;
//import SplunkMint;

open class LoginAsyncTask : AsyncTask {
    
    var strData : NSString = "";
    
    var username : String;
    var password : String;
    
    static var lastOperationValue = false;
    static var urlError = false;
    static var connectionError = false;
    
    
    init(username : String, password : String) {
        self.username = username;
        self.password = password;
    }
    
    override func doInBackground(){
        LoginAsyncTask.loginOperation();
    }
    
    override func postExecute(){
        
    }
    
    static func loginOperation() {
        
        let response: AutoreleasingUnsafeMutablePointer<URLResponse?>?=nil
        
        let urlAsString = (K12NetUserPreferences.getHomeAddress() as String) + "/Authentication_JSON_AppService.axd/Login"
        var params : [String:String] = [:];
        params["userName"] = K12NetUserPreferences.getUsername();
        params["password"] = K12NetUserPreferences.getPassword();
        params["createPersistentCookie"] = "false";
        
        let request = K12NetWebRequest.retrievePostRequest(urlAsString, params: params);
        
        LoginAsyncTask.urlError = false;
                LoginAsyncTask.connectionError = false;
        
        if let data: Data = K12NetWebRequest.sendSynchronousRequest(request, returningResponse: response) {
            
            if(K12NetWebRequest.getLastError() == nil) {
                
                let jsonStr = NSString(data: data, encoding: String.Encoding.utf8.rawValue);
                
                print("logintex : \(jsonStr)");
                
                var json : NSDictionary?;
                
                do {
                    json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? NSDictionary
                } catch _ {
                    json = NSDictionary();
                }
                
                if let parseJSON = json {
                    if let success = parseJSON["d"] as? Bool {
                        LoginAsyncTask.lastOperationValue = success;
                          
                    }
                    else {
                        LoginAsyncTask.lastOperationValue = false;
                    }
                    
                }
            }
            else {
                print("lasterror");
                print(K12NetWebRequest.getLastError());
                if(K12NetWebRequest.getLastError()?.code == -1003) { //NSURLErrorDomain
                    LoginAsyncTask.urlError = true;
                }
                else if(K12NetWebRequest.getLastError()?.code == NSURLErrorTimedOut ||
                    K12NetWebRequest.getLastError()?.code == NSURLErrorCannotConnectToHost ||
                    K12NetWebRequest.getLastError()?.code == NSURLErrorNetworkConnectionLost ||
                    K12NetWebRequest.getLastError()?.code == NSURLErrorNotConnectedToInternet) {
                    LoginAsyncTask.connectionError = true;
                }
            }
        }
    }
}
