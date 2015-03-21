//
//  AppWarpHelper.swift
//  FightNinja
//
//  Created by Shephertz on 20/06/14.
//  Copyright (c) 2014 Shephertz. All rights reserved.
//

import UIKit


class AppWarpHelper: NSObject
{

    var api_key = "cad2bfab6310acd9696187b98682925125e469ab0d0d585db0b00609f461b791"
    var secret_key = "55811709916e7ce4405cde0cdc5a254cf4b506fbafdae05760a73100b8080b67"
    var roomId = ""
    var enemyName: String = ""
    var playerName: String = ""
    
    var gameViewController: GameViewController? = nil
    var gameScene: GameScene? = nil
    
    class var sharedInstance:AppWarpHelper{
        struct Static{
            static var instance:AppWarpHelper?
            static var token: dispatch_once_t = 0
            }
            
            dispatch_once(&Static.token){
                Static.instance = AppWarpHelper()
            }
            return Static.instance!
    }

    func initializeWarp()
    {
        WarpClient.initWarp(api_key, secretKey: secret_key)
        var warpClient:WarpClient = WarpClient.getInstance()
        warpClient.enableTrace(true)
        warpClient.setRecoveryAllowance(60);
        
        var connectionListener: ConnectionListener = ConnectionListener()
        warpClient.addConnectionRequestListener(connectionListener)
        
        
        var zoneListener: ZoneListener = ZoneListener()
        warpClient.addZoneRequestListener(zoneListener)
        
        var notificationListener:NotificationListener = NotificationListener()
        warpClient.addNotificationListener(notificationListener)
        
        var roomListener: RoomListener = RoomListener()
        warpClient.addRoomRequestListener(roomListener)
    }
    
    func connectWithAppWarpWithUserName(userName:String)
    {
        var uNameLength = userName.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        if uNameLength>0
        {
            var warpClient:WarpClient = WarpClient.getInstance()
            warpClient.connectWithUserName(userName)
        }
    }
    
    
    func updatePlayerDataToServer(dataDict:NSMutableDictionary)
    {
        if dataDict == NSNull()
        {
            return
        }
        println(dataDict)
        var convertedData = NSJSONSerialization.dataWithJSONObject(dataDict, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        //var convertedData = NSPropertyListSerialization.dataWithPropertyList(dataDict, format: NSPropertyListFormat.XMLFormat_v1_0, options: 0, error: nil)
        
        if convertedData == nil
        {
            return
        }
        
        if WarpClient.getInstance().getConnectionState()==0
        {
            println("updatePlayerDataToServer")
            WarpClient.getInstance().sendUpdatePeers(convertedData)
        }
    }
    
    func receivedEnemyStatus(data:NSData)
    {
        println("receivedEnemyStatus...1")
        println(data)

        if data == NSNull()
        {
            println(data)
        }
        else
        {
            println("receivedEnemyStatus...2")
            
            var error: NSError? = nil;
            var responseDict: NSMutableDictionary = NSJSONSerialization.JSONObjectWithData(data,options: NSJSONReadingOptions.MutableContainers, error:&error) as NSMutableDictionary
            
            //var propertyListFormat:NSPropertyListFormat? = nil
            //var responseDict: NSDictionary = NSPropertyListSerialization.propertyListWithData(data, options: 0, format:&propertyListFormat, error: nil) as NSDictionary
            println(responseDict)
            //println(error!.value)
            //gameScene!.updateEnemyStatus(responseDict)
            
            if (error == nil)
            {
                println("receivedEnemyStatus...3")
                
                if enemyName.isEmpty
                {
                    var userName : (String!) = responseDict.objectForKey("userName") as String
                    let isEqual = playerName.hasPrefix(userName)
                    if !isEqual
                    {
                        enemyName = responseDict.objectForKey("userName") as String
                        gameScene!.updateEnemyStatus(responseDict)
                    }
                }
                else
                {
                    var userName : (String!) = responseDict.objectForKey("userName") as String
                    let isEqual = enemyName.hasPrefix(userName)
                    if isEqual
                    {
                        gameScene!.updateEnemyStatus(responseDict)
                    }
                }
            }

        }
        
    }
}
