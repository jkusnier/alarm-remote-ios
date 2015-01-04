//
//  alarm_remote_iosTests.swift
//  alarm-remote-iosTests
//
//  Created by Jason Kusnier on 12/24/14.
//  Copyright (c) 2014 Jason Kusnier. All rights reserved.
//

import UIKit
import XCTest

class alarm_remote_iosTests: XCTestCase {
    
    let userName = "test"
    let password = "encryptedpassword"
    var accessToken: String?
    var deviceId: String?
    var alarmId: String?
    
    override func setUp() {
        super.setUp()
        
        let api = APIController()
        let expectation = expectationWithDescription("Get Access Token")
        api.getAccessToken(userName, password: password, failure: nil, success: { accessToken in
            self.accessToken = accessToken
            expectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(10) { (error) in
            XCTAssertNil(error)
        }
        
        let expectation2 = expectationWithDescription("Get Device Id")
        api.updateDevices(
            accessToken: accessToken!,
            success: { devices in
                self.deviceId = devices.keys.first
                expectation2.fulfill()
        })
        
        waitForExpectationsWithTimeout(10) { (error) in
            XCTAssertNil(error)
        }
        
        let expectation3 = expectationWithDescription("Get Alarm Id")
        api.getDeviceAlarms(accessToken: accessToken!, deviceId: deviceId!, success: { alarms in
            self.alarmId = alarms.keys.first
            expectation3.fulfill()
        })
        
        waitForExpectationsWithTimeout(10) { (error) in
            XCTAssertNil(error)
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testAuth() {
        let api = APIController()
        api.getAccessToken(self.userName, password: self.password,
            failure: { error in
                XCTAssertTrue(false)
            },
            success: { accessToken in
                XCTAssertNotNil(accessToken, "Token is nill")
                
                api.testAccessToken(self.userName, accessToken: accessToken,
                    failure: { error in
                        XCTAssertTrue(false, "Token is invalid")
                    },
                    success: {
                        XCTAssertTrue(true)
                        self.accessToken = accessToken
                })
        })
    }
    
    func testUpdateDevices() {
        XCTAssertNotNil(self.accessToken, "Access Token Not Found")
        
        let api = APIController()
        
        api.updateDevices(
            accessToken: self.accessToken!,
            failure: { error in
                XCTAssertTrue(false, "Error Retrieving Devices")
            },
            success: { devices in
                XCTAssertTrue(devices.count > 0, "No Devices Found")
        })
    }
    
    func testGetDeviceAlarms() {
        XCTAssertNotNil(self.accessToken, "Access Token Not Found")
        XCTAssertNotNil(self.deviceId, "Device Id Not Found")
        
        let api = APIController()
        
        api.getDeviceAlarms(accessToken: self.accessToken, deviceId: self.deviceId,
            failure: { error in
                XCTAssertTrue(false, "Error Retrieving Alarms")
            },
            success: { alarms in
                XCTAssertTrue(alarms.count > 0, "No Alarms Found")
        })
    }
    
    func testEnableAlarm() {
        XCTAssertNotNil(self.accessToken, "Access Token Not Found")
        XCTAssertNotNil(self.deviceId, "Device Id Not Found")
        XCTAssertNotNil(self.alarmId, "Alarm Id Not Found")
        
        let api = APIController()
        
        api.setAlarmStatus(accessToken: self.accessToken, deviceId: self.deviceId, alarmId: self.alarmId, alarmStatus: true,
            failure: { error in
                XCTAssertTrue(false, "Error Setting Alarm Status")
            },
            success: {
                XCTAssertTrue(true)
        })
    }
    
    func testDisableAlarm() {
        XCTAssertNotNil(self.accessToken, "Access Token Not Found")
        XCTAssertNotNil(self.deviceId, "Device Id Not Found")
        XCTAssertNotNil(self.alarmId, "Alarm Id Not Found")
        
        let api = APIController()
        
        api.setAlarmStatus(accessToken: self.accessToken, deviceId: self.deviceId, alarmId: self.alarmId, alarmStatus: false,
            failure: { error in
                XCTAssertTrue(false, "Error Setting Alarm Status")
            },
            success: {
                XCTAssertTrue(true)
        })
    }
}
