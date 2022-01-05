//
//  BindingContext.swift
//  Binding
//
//  Created by Sugeng Wibowo on 09/06/20.
//  Copyright © 2020 KmkLabs. All rights reserved.
//

import Foundation
import RxSwift

public protocol BindingContext: AnyObject {
    var disposeBag: DisposeBag { get }
}

extension BindingContext {
    public func binding(@BindingDisposables disposables: () -> Disposable) {
        disposables().disposed(by: disposeBag)
    }
}

#if swift(>=5.4)
@resultBuilder
public struct BindingDisposables {
    public static func buildBlock(_ disposables: Disposable...) -> Disposable {
        return CompositeDisposable(disposables: disposables)
    }
}
#else
@_functionBuilder
public struct BindingDisposables {
    public static func buildBlock(_ disposables: Disposable...) -> Disposable {
        return CompositeDisposable(disposables: disposables)
    }
}
#endif
