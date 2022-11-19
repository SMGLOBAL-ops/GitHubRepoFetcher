//
//  ReposFetcherUITestsLaunchTests.swift
//  ReposFetcherUITests
//
//  Created by Mustafa, Saif (GT RET Consumer Servicing - Com Bank L, Group Transformation) on 18/11/2022.
//

import XCTest

class ReposFetcherUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
