# Binding
Data binding framework (view model binding on MVVM) written using `@propertyWrapper` and `@resultBuilder`
## Requirement
Swift 5.1+, RxSwift ([link](https://github.com/ReactiveX/RxSwift))
## Usage
### Property
The property wrapper used for observable property in view model that can be binded to view property by using `RxCocoa`.
There are 3 types of wrapper (2 for observable value, and 1 for observable action).
#### Bindable
One-way binding type of property with `Driver` as its `projectedValue` [doc](https://github.com/apple/swift-evolution/blob/master/proposals/0258-property-wrappers.md#projections), and can use any type for its property type (`wrappedValue`).
```swift
final class ViewModel {
  @Bindable private(set) var name: String = ""
  @Bindable private(set) var description: String = ""
  
  func change() {
      name = "haha"
      description = "description"
  }
}
```
For the usage in `View` we could bind it by using the projected value
```swift
disposeBag.insert(
  vm.$name.drive(nameLabel.rx.text),
  vm.$description.drive(descLabel.rx.text)
)
```
#### Mutable
Two-way binding type of property with `BehaviorRelay` as its `projectedValue`, also same as `Bindable` it can use any type for its property type.
```swift
final class ViewModel {
  @Mutable var typedText: String = ""
  @Mutable var selectedTarget: Target = .vidioAdmin
}
```
For usage in `View` we cound bind it same as `Bindable` by using the projected value, but since its type is `BehaviorRelay`, it can also accept value from view.
```swift
disposeBag.insert(
  vm.$typedText.asDriver().drive(textInput.rx.text),
  textInput.rx.text.subscribe(onNext: { vm.$typedText.accept($0) /* or vm.typedText = $0 */ })
)
```
#### ViewAction
One parameter observable function, use to trigger view action from view model. Example of action would be show alert, open view controller, dismiss, etc. Note that the wrapped value type has to be a function with single parameter and `Void` return type and it will have `Signal` as the projected value.
```swift
final class ViewModel {
  @ViewAction var alert: (Message) -> Void
  
  func change() {
      alert(Message("Changed!"))
  }
}
```
To bind it in view,
```swift
disposeBag.insert(
  vm.$alert.emit(onNext: { [weak self] in self?.showAlert($0.textMessage) })
)
```
##### ViewAction without argument
Since `ViewAction` needs the wrapped value to be single argument function, it will be awkward to use Void as the parameter type. For this, we could use another type of `ViewAction`, `ViewAction.NoParam`. It's the same as `ViewAction`, with exception of wrapped value type has to be no argument function `() -> Void`.
```swift
final class ViewModel {
  @ViewAction.NoParam var dismiss:() -> Void
}
```
### BindingContext
When using RxSwift to bind view and property, the subscription needs to be dispose at some point, this usually be done after the view for the binding has been disposed. 
To implement this, usually we use `DisposeBag` and add the subscriptions to it to let it auto dispose all the subscription when the `DisposeBag` disposed by the view.
```swift
// example
let disposeBag = DisposeBag()
view.rx.text.subscribe(onNext: { /*...*/ }).disposed(by: disposeBag)
// or when there are multiple subscription we use
disposeBag.insert(
  textObservable.subscribe(),
  nameObservable.subscribe()
)
```
When using binding, a protocol called `BindingContext` is introduced to provide a context where the binding should be done.
When implementing this protocol, a property `disposeBag` need to be implemented for it will be used to dispose all subscriptions added inside the context when de-inited. 
`binding(@BindingDisposables disposables: () -> Disposable)` in `BindingContext` can be used as the scope for the subscriptions.
For any subscriptions done in this function builder, it will be inserted into the `disposeBag`.

*Note:* `@_functionBuilder` is used to implement this behavior [proposal doc](https://github.com/apple/swift-evolution/blob/9992cf3c11c2d5e0ea20bee98657d93902d5b174/proposals/XXXX-function-builders.md) [more learning](https://www.swiftbysundell.com/articles/the-swift-51-features-that-power-swiftuis-api/) (apparently, it's been changed to `@functionBuilder` in the newer version)
```swift
final class ViewController: BindingContext {
  ...
  let disposeBag = DisposeBag() 
  override func viewDidLoad() {
    super.viewDidLoad()
    ...
    binding {
      viewModel.$text.drive(textLabel.rx.text)  // notice we don't add comma here, since it is not needed when using function builder
      viewModel.$description.drive(descLabel.rx.text)
      viewModel.$alert.emit(onNext: { [weak self] in self?.alert($0) })
    }
  }
}
```
### Binding Operators
To simplify the binding, custom operators added to this library.
There are 2 binding operators that can be use to bind the view with view model.
#### One-way Binding Operator
To handle one-way binding, operator `=>` can be used with left-hand operand to be `Driver` or `Signal`(for `ViewAction` binding).

The right-hand operand for both `Driver` and `Signal` can be:
- `ObserverType` with value type both `optional` or not, and it can also be function with one argument.
- function with one argument `(ValueType) -> Void`.
```swift
binding {
  viewModel.$text => textLabel.rx.text // Driver with Binder as receiver
  viewModel.$description => { print("description: \($0)") } // Driver with function as receiver
  viewModel.$alert => { [weak self] in self?.alert($0) } // Signal with function as receiver
}
```
#### Two-way Binding Operator
To handle two-way binding, operator `<=>` can be used with left-hand operand to be `BehaviorRelay` and `ControlPropertyType` as the right-hand operand.
```swift
binding {
  // notice in this example text control property is not being used
  // instead it is using custom control property with non optional value
  // since, <=> cannot accept ControlPropertyType with element optional
  // for optional type a new operator will introduced
  viewModel.$inputText <=> textField.rx.nonNullText
}
```
#### Optional Operator
This operator is especially used for `ControlProperty` with default value.
It has to be done this way because of how `UIKit` was implemented in the past, and `RxCocoa` has to adapt to it (e.g. `text` property in text field has `String?` type).

The operator for this case is re-using the same operator for Nil-coalescing (`??`) in swift.
```swift
binding {
  viewModel.$inputText <=> textField.rx.text ?? "default value"
}
```
