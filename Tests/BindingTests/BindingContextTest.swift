//
//  BindingContextTest.swift
//  BindingTests
//
//  Created by Sugeng Wibowo on 09/06/20.
//  Copyright © 2020 KmkLabs. All rights reserved.
//

import XCTest
import RxSwift

@testable import Binding

class BindingContextTest: XCTestCase {

    func testDisposeAllAfterContextDeinitDisposeBag() {
        final class Context: BindingContext {
            let disposeBag = DisposeBag()
        }
        
        var disposalCount = 0
        var context: Context? = Context()
        context?.binding {
            Observable<Void>.never().subscribe(onDisposed: { disposalCount += 1 })
            Observable<Void>.never().subscribe(onDisposed: { disposalCount += 1 })
            Observable<Void>.never().subscribe(onDisposed: { disposalCount += 1 })
            Observable<Void>.never().subscribe(onDisposed: { disposalCount += 1 })
            Observable<Void>.never().subscribe(onDisposed: { disposalCount += 1 })
        }
        
        let disposableCountBeforeDeinit = disposalCount
        context = nil
        let disposableCountAfterDeinit = disposalCount
        
        XCTAssertEqual(disposableCountBeforeDeinit, 0)
        XCTAssertEqual(disposableCountAfterDeinit, 5)
    }
    
}
