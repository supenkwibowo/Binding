//
//  BindableTest.swift
//  BindingTests
//
//  Created by Sugeng Wibowo on 09/06/20.
//  Copyright © 2020 KmkLabs. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

@testable import Binding

class BindableTest: XCTestCase {

    func testEmitValueChanged() {
        struct ContextModel {
            @Bindable var value: Int
        }
        
        var model = ContextModel(value: 7)
        
        let valueObserver = TestScheduler(initialClock: 0).createObserver(Int.self)
        let disposeBag = DisposeBag()
        model.$value.drive(valueObserver).disposed(by: disposeBag)
        
        model.value = 5
        model.value = 1
        model.value = 99
        model.value = 99
        
        XCTAssertRecordedElements(valueObserver.events, [ 7, 5, 1, 99, 99 ])
    }
    
    func testWrappedValueChangeShouldNotBeManipulated() {
        var bindable = Bindable(wrappedValue: 1)
        XCTAssertEqual(bindable.wrappedValue, 1)
        
        bindable.wrappedValue = 10
        XCTAssertEqual(bindable.wrappedValue, 10)
        
        bindable.wrappedValue = 99
        XCTAssertEqual(bindable.wrappedValue, 99)
        
        bindable.wrappedValue = 1000000000
        XCTAssertEqual(bindable.wrappedValue, 1000000000)
        
        bindable.wrappedValue = -99
        XCTAssertEqual(bindable.wrappedValue, -99)
    }

}
