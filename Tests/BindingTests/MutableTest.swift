//
//  MutableTest.swift
//  BindingTests
//
//  Created by Sugeng Wibowo on 17/06/20.
//  Copyright © 2020 KmkLabs. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

@testable import Binding

class MutableTest: XCTestCase {

    func testEmitValueChanged() {
        struct ContextModel {
            @Mutable var value: Int
        }
        
        var model = ContextModel(value: 7)
        
        let valueObserver = TestScheduler(initialClock: 0).createObserver(Int.self)
        let disposeBag = DisposeBag()
        model.$value.bind(to: valueObserver).disposed(by: disposeBag)
        
        model.value = 5
        model.value = 1
        model.value = 99
        model.value = 99
        
        XCTAssertRecordedElements(valueObserver.events, [ 7, 5, 1, 99, 99 ])
    }
    
    func testWrappedValueChangeShouldNotBeManipulated() {
        var mutable = Mutable(wrappedValue: 1)
        XCTAssertEqual(mutable.wrappedValue, 1)
        
        mutable.wrappedValue = 10
        XCTAssertEqual(mutable.wrappedValue, 10)
        
        mutable.wrappedValue = 99
        XCTAssertEqual(mutable.wrappedValue, 99)
        
        mutable.wrappedValue = 1000000000
        XCTAssertEqual(mutable.wrappedValue, 1000000000)
        
        mutable.wrappedValue = -99
        XCTAssertEqual(mutable.wrappedValue, -99)
    }
    
    func testProjectedValueUpdateShouldBeReflectedToWrappedValue() {
        struct ContextModel {
            @Mutable var value: Int
        }
        
        let model = ContextModel(value: 0)
        
        model.$value.accept(99)
        XCTAssertEqual(model.value, 99)
        
        model.$value.accept(1)
        XCTAssertEqual(model.value, 1)
        
        model.$value.accept(-7)
        XCTAssertEqual(model.value, -7)
    }

}
