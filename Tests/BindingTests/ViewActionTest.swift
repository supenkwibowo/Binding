//
//  ViewActionTest.swift
//  BindingTests
//
//  Created by Sugeng Wibowo on 16/06/20.
//  Copyright © 2020 KmkLabs. All rights reserved.
//

import XCTest
import RxCocoa
import RxTest

@testable import Binding

class ViewActionTest: XCTestCase {

    func testActionWithArgument() {
        struct ContextModel {
            @ViewAction var notification: (String) -> Void
            
            mutating func notify(_ tag: String) {
                notification(tag)
            }
        }
        
        var context = ContextModel()
        
        let actionParamObserver = TestScheduler(initialClock: 0).createObserver(String.self)
        let disposable = context.$notification.emit(to: actionParamObserver)
        defer { disposable.dispose() }
        
        context.notify("do")
        context.notify("a")
        context.notify("deer")
        context.notify("a female deer")
        
        XCTAssertRecordedElements(
            actionParamObserver.events,
            [ "do", "a", "deer", "a female deer" ]
        )
    }
    
    func testActionWithoutArgument() {
        struct ContextModel {
            @ViewAction.NoParam var notification: () -> Void
            
            mutating func notify() {
                notification()
            }
        }
        
        var context = ContextModel()
        
        var callCount = 0
        let disposable = context.$notification.emit(onNext: { callCount += 1 })
        defer { disposable.dispose() }
        
        context.notify()
        context.notify()
        context.notify()
        
        XCTAssertEqual(callCount, 3)
    }

}
