//
//  BindingOperatorTest.swift
//  BindingTests
//
//  Created by Sugeng Wibowo on 09/06/20.
//  Copyright © 2020 KmkLabs. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest

@testable import Binding

class BindingOperatorTest: XCTestCase {
    
    private final class InTestBindingContext: BindingContext {
        let disposeBag = DisposeBag()
    }
    
    private var bindingContext: BindingContext!
    private var testScheduler: TestScheduler!
    override func setUp() {
        bindingContext = InTestBindingContext()
        testScheduler = TestScheduler(initialClock: 0)
    }

    func testDriverBindToObserver() {
        let emittedEvents: [Recorded<Event<String>>] = [
            .next(1, "emit#1"),
            .next(5, "emit#2"),
            .next(10, "emit#3"),
            .next(20, "emit#4"),
            .completed(30)
        ]
        let observable = testScheduler.createColdObservable(emittedEvents)
        
        let observer = testScheduler.createObserver(String.self)
        bindingContext.binding {
            observable.asDriver(onErrorDriveWith: .never()) => observer
        }
        
        testScheduler.advanceTo(30)
        
        XCTAssertEqual(observer.events, emittedEvents)
    }
    
    func testDriverBindToObserverWithNilValue() {
        let observable = testScheduler.createColdObservable([
            .next(1, "emit#1"),
            .next(5, "emit#2"),
            .next(10, "emit#3"),
            .next(20, "emit#4"),
            .completed(30)
        ])
        
        let observer = testScheduler.createObserver(String?.self)
        bindingContext.binding {
            observable.asDriver(onErrorDriveWith: .never()) => observer
        }
        
        testScheduler.advanceTo(30)
        
        XCTAssertEqual(
            observer.events,
            [
                .next(1, "emit#1"),
                .next(5, "emit#2"),
                .next(10, "emit#3"),
                .next(20, "emit#4"),
                .completed(30)
            ]
        )
    }
    
    func testDriverBindToBlock() {
        let observable = Observable.from([ "A", "B", "C", "D" ])
        
        var capturedValues = [String]()
        bindingContext.binding {
            observable.asDriver(onErrorDriveWith: .never()) => { capturedValues.append($0) }
        }
        
        XCTAssertEqual(capturedValues, [ "A", "B", "C", "D" ])
    }
    
    func testSignalBindToObserver() {
        let emittedEvents: [Recorded<Event<String>>] = [
            .next(1, "emit#1"),
            .next(5, "emit#2"),
            .next(10, "emit#3"),
            .next(20, "emit#4"),
            .completed(30)
        ]
        let observable = testScheduler.createColdObservable(emittedEvents)
        
        let observer = testScheduler.createObserver(String.self)
        bindingContext.binding {
            observable.asSignal(onErrorSignalWith: .never()) => observer
        }
        
        testScheduler.advanceTo(30)
        
        XCTAssertEqual(observer.events, emittedEvents)
    }
    
    func testSignalBindToObserverWithNilValue() {
        let observable = testScheduler.createColdObservable([
            .next(1, "emit#1"),
            .next(5, "emit#2"),
            .next(10, "emit#3"),
            .next(20, "emit#4"),
            .completed(30)
        ])
        
        let observer = testScheduler.createObserver(String?.self)
        bindingContext.binding {
            observable.asSignal(onErrorSignalWith: .never()) => observer
        }
        
        testScheduler.advanceTo(30)
        
        XCTAssertEqual(
            observer.events,
            [
                .next(1, "emit#1"),
                .next(5, "emit#2"),
                .next(10, "emit#3"),
                .next(20, "emit#4"),
                .completed(30)
            ]
        )
    }
    
    func testSignalBindToBlock() {
        let observable = Observable.from([ "A", "B", "C", "D" ])
        
        var capturedValues = [String]()
        bindingContext.binding {
            observable.asSignal(onErrorSignalWith: .never()) => { capturedValues.append($0) }
        }
        
        XCTAssertEqual(capturedValues, [ "A", "B", "C", "D" ])
    }
    
    func testControlEventBindToObserver() {
        let observable = testScheduler.createColdObservable([
            .next(1, ()),
            .next(5, ()),
            .next(10, ()),
            .next(20, ()),
            .completed(30)
        ])
        
        var emittedCount = 0
        bindingContext.binding {
            ControlEvent(events: observable) => { emittedCount += 1 }
        }
        
        testScheduler.advanceTo(30)
        
        XCTAssertEqual(emittedCount, 4)
    }
    
    func testControlPropertyDefaultValue() {
        let nilSource = ControlProperty(
            values: Observable<String?>.from([ nil ]),
            valueSink: AnyObserver<String?> { _ in }
        )
        let nonNilSource = ControlProperty(
            values: Observable<String?>.from([ "non nil" ]),
            valueSink: AnyObserver<String?> { _ in }
        )
        
        func values<Value>(of property: ControlProperty<Value>) -> [Value] {
            var values = [Value]()
            property.subscribe(onNext: { values.append($0) }).dispose()
            return values
        }

        XCTAssertEqual(values(of: nilSource ?? ""), [ "" ])
        XCTAssertEqual(values(of: nilSource ?? "A"), [ "A" ])
        XCTAssertEqual(values(of: nilSource ?? "default"), [ "default" ])
        XCTAssertEqual(values(of: nonNilSource ?? "default"), [ "non nil" ])
    }
    
    func testControlPropertyDefaultPassAllEvents() {
        enum ErrorInTest: Error {
            case error
        }
        let errorSource = ControlProperty(
            values: Observable<String?>.error(ErrorInTest.error),
            valueSink: AnyObserver<String?> { _ in }
        )
        let completedSource = ControlProperty(
            values: Observable<String?>.empty(),
            valueSink: AnyObserver<String?> { _ in }
        )
        let multipleValuesSource = ControlProperty(
            values: Observable<String?>.from([ nil, "next" ]),
            valueSink: AnyObserver<String?> { _ in }
        )
        
        func events<Value>(of property: ControlProperty<Value>) -> [Recorded<Event<Value>>] {
            let observer = testScheduler.createObserver(Value.self)
            property.subscribe(observer).dispose()
            return observer.events
        }
        
        XCTAssertEqual(
            events(of: errorSource ?? ""), [ .error(0, ErrorInTest.error) ]
        )
        XCTAssertEqual(
            events(of: completedSource ?? ""), [ .completed(0) ]
        )
        XCTAssertEqual(
            events(of: multipleValuesSource ?? ""),
            [ .next(0, ""), .next(0, "next"), .completed(0) ]
        )
    }
    
    func testControlPropertyDefaultValuSink() {
        let observer = testScheduler.createObserver(String?.self)
        let source = ControlProperty(
            values: Observable<String?>.never(),
            valueSink: observer
        )
        let target = source ?? ""
        
        target.on(.next("A"))
        target.on(.next("B"))
        target.on(.completed)
        
        XCTAssertEqual(
            observer.events,
            [ .next(0, "A"), .next(0, "B"), .completed(0) ]
        )
    }
    
    func testTwoWayBindingControlPropertyBindInitialValueFromSource() throws {
        let propertySubject = BehaviorSubject(value: "initial value from property")
        let controlProperty = ControlProperty(
            values: propertySubject, valueSink: propertySubject
        )
        let relay = BehaviorRelay(value: "initial value from relay")
        bindingContext.binding {
            relay <=> controlProperty
        }
        
        XCTAssertEqual(relay.value, "initial value from relay")
        XCTAssertEqual(try propertySubject.value(), "initial value from relay")
    }

    func testTwoWayBindingControlPropertyOnChangeValue() throws {
        let propertySubject = BehaviorSubject(value: "")
        let controlProperty = ControlProperty(
            values: propertySubject.distinctUntilChanged(),
            valueSink: propertySubject
        )
        let relay = BehaviorRelay(value: "")
        bindingContext.binding {
            relay <=> controlProperty
        }
        
        propertySubject.onNext("new value 1")
        XCTAssertEqual(relay.value, "new value 1")
        
        propertySubject.onNext("new value 2")
        XCTAssertEqual(relay.value, "new value 2")
        
        relay.accept("value from relay")
        XCTAssertEqual(try propertySubject.value(), "value from relay")
    }

}
