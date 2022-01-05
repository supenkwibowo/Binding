//
//  Binding.swift
//  Binding
//
//  Created by Sugeng Wibowo on 09/06/20.
//  Copyright © 2020 KmkLabs. All rights reserved.
//

import Foundation
import RxRelay
import RxCocoa

@propertyWrapper
public struct Bindable<Value> {
    public var wrappedValue: Value {
        get { observableValue.value }
        set { observableValue.accept(newValue) }
    }
    
    public let projectedValue: Driver<Value>
    
    private let observableValue: BehaviorRelay<Value>
    public init(wrappedValue: Value) {
        observableValue = BehaviorRelay(value: wrappedValue)
        projectedValue = observableValue.asDriver()
    }
}

@propertyWrapper
public struct Mutable<Value> {
    public var wrappedValue: Value {
        get { projectedValue.value }
        set { projectedValue.accept(newValue) }
    }
    
    public let projectedValue: BehaviorRelay<Value>
    
    public init(wrappedValue: Value) {
        projectedValue = BehaviorRelay(value: wrappedValue)
    }
}

@propertyWrapper
public struct ViewAction<Value> {
    private let publisher = PublishRelay<Value>()
    public let projectedValue: Signal<Value>
    
    public let wrappedValue: (Value) -> Void
    
    public init() {
        let publisher = self.publisher
        projectedValue = publisher.asSignal()
        wrappedValue = { publisher.accept($0) }
    }
}

extension ViewAction {
    public typealias NoParam = NoParamViewAction
}

@propertyWrapper
public struct NoParamViewAction {
    private let publisher = PublishRelay<Void>()
    public let projectedValue: Signal<Void>
    
    public let wrappedValue: () -> Void
    
    public init() {
        let publisher = self.publisher
        projectedValue = publisher.asSignal()
        wrappedValue = { publisher.accept(()) }
    }
}
