//
//  MagicWrapperTests.swift
//  
//
//  Created by john on 2023/8/28.
//

import XCTest
@testable import MagicWrapper

final class MagicWrapperTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExtension() async throws {
        let wrapper = MagicWrapper()
        
        let zip = Bundle.module.url(forResource: "01B0650B-D6D0-447C-87A4-8FDE7D6730C9", withExtension: "zip")!
        let extesion = try wrapper.file(zip, flags: .extension)
        XCTAssertEqual(extesion, "zip/cbz")
        
        let torrent = Bundle.module.url(forResource: "0102ACAC-0D92-4F2C-8902-8E96590914B9", withExtension: "torrent")!
        let extesion1 = try wrapper.file(torrent, flags: .extension)
        XCTAssertEqual(extesion1, "torrent")
    }
    
    func testMIME() async throws {
        let wrapper = MagicWrapper()
        
        let zip = Bundle.module.url(forResource: "01B0650B-D6D0-447C-87A4-8FDE7D6730C9", withExtension: "zip")!
        let extesion = try wrapper.file(zip, flags: .mimeType)
        XCTAssertEqual(extesion, "application/zip")
        
        let torrent = Bundle.module.url(forResource: "0102ACAC-0D92-4F2C-8902-8E96590914B9", withExtension: "torrent")!
        let extesion1 = try wrapper.file(torrent, flags: .mimeType)
        XCTAssertEqual(extesion1, "application/x-bittorrent")
    }
}
