//
//  BindingOperator.swift
//  Binding
//
//  Created by Sugeng Wibowo on 09/06/20.
//  Copyright © 2020 KmkLabs. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

precedencegroup BindingOperator {
    associativity: left
    higherThan: LogicalConjunctionPrecedence
    lowerThan: NilCoalescingPrecedence
}

infix operator => : BindingOperator
infix operator <=> : BindingOperator

public func => <Value, Observer: ObserverType> (driver: Driver<Value>, observer: Observer)
    -> Disposable where Observer.Element == Value {
        return driver.drive(observer)
}

public func => <Value, Observer: ObserverType> (driver: Driver<Value>, observer: Observer)
    -> Disposable where Observer.Element == Value? {
        return driver.drive(observer)
}

public func => <Value> (driver: Driver<Value>, block: @escaping (Value) -> Void) -> Disposable {
    return driver.drive(onNext: block)
}

public func => <Value, Observer: ObserverType> (signal: Signal<Value>, observer: Observer)
    -> Disposable where Observer.Element == Value {
        return signal.emit(to: observer)
}

public func => <Value, Observer: ObserverType> (signal: Signal<Value>, observer: Observer)
    -> Disposable where Observer.Element == Value? {
        return signal.emit(to: observer)
}

public func => <Value> (signal: Signal<Value>, block: @escaping (Value) -> Void) -> Disposable {
    return signal.emit(onNext: block)
}

public func => <Value> (controlEvent: ControlEvent<Value>, block: @escaping (Value) -> Void) -> Disposable {
    return controlEvent.subscribe(onNext: block)
}

public func <=> <Value, PropertyType: ControlPropertyType> (
    relay: BehaviorRelay<Value>, property: PropertyType
) -> Disposable where PropertyType.Element == Value {
    return CompositeDisposable(
        relay.asDriver().drive(property),
        property.bind(to: relay)
    )
}

public func ?? <Value> (property: ControlProperty<Value?>, defaultValue: Value)
    -> ControlProperty<Value> {
        let observer = AnyObserver<Value> { event in
            switch event {
            case .next(let value): property.onNext(value)
            case .error(let error): property.onError(error)
            case .completed: property.onCompleted()
            }
        }
        return ControlProperty(
            values: property.compactMap { $0 ?? defaultValue }, valueSink: observer
        )
}
