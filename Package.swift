// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Binding",
    platforms: [.iOS(.v9), .macOS(.v10_10), .watchOS(.v3), .tvOS(.v9)],
    products: [
        .library(
            name: "Binding",
            targets: ["Binding"]),
        .library(
            name: "Binding-Dynamic",
            type: .dynamic,
            targets: ["Binding"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .exact("6.2.0"))
    ],
    targets: [
        .target(
            name: "Binding",
            dependencies: [
                "RxSwift",
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "RxRelay", package: "RxSwift")
            ]),
        .testTarget(
            name: "BindingTests",
            dependencies: [
                "Binding",
                .product(name: "RxTest", package: "RxSwift")
            ]),
    ]
)
