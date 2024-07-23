# ExpiringStorage

<!-- [![CI Status](https://img.shields.io/travis/bivant/ExpiringStorage.svg?style=flat)](https://travis-ci.org/bivant/ExpiringStorage) -->
[![Version](https://img.shields.io/cocoapods/v/ExpiringStorage.svg?style=flat)](https://cocoapods.org/pods/ExpiringStorage)
[![License](https://img.shields.io/cocoapods/l/ExpiringStorage.svg?style=flat)](https://raw.githubusercontent.com/bivant/ExpiringStorage/master/LICENSE)
[![Platform](https://img.shields.io/cocoapods/p/ExpiringStorage.svg?style=flat)](https://cocoapods.org/pods/ExpiringStorage)

## Purpose

Implements circular/ring collection with expiring (based on an item insertion timestamp) elements.
It was originally created to extract the [Google Native Ads expiration logic](https://developers.google.com/admob/ios/native#request_ads) from the main codebase. I considered adding a Sequence/IteratorProcol conformance, but decided not to do it as default/non-looping iterator would need to keep track of collection updates to be able to stop from going over collection multiple/infinite times. Besides, it would make the implementaion more complex which is not needed (yet).

I tried to cover all possible edge cases with tests, please let me know if I should add any.

## Usage

This library was created to store some(small) number of elements those need to expire after some time.
Collection (**ExpiringStorage\<T>**) instance is intended to be shared across multiple places so implementation is based on class rather than a struct.
Collection removes expired elements on **addNew()** automatically (**clearExpired**), while keeping track on the last provided element (by **nextValid**) to support continious/circular "read" behavior.


Expiration is controlled by the **expirationInterval** in the collection constructor (**.init(expirationInterval: TimeInterval)**), once the time since item insertion timestamp exceeds this interval - item considered expired and is not returned by **nextValid**/**allValid** and going to be removed from the collection on **clearExpired** (or **addNew()**).

### Pseudocode(for a primitive ViewController(MVC))
```swift
import ExpiringStorage
...
private lazy var storage = ExpiringStorage<Object>(expirationInterval: 3600.0)	//1 hour
private let requiredNumberOfElements = 5
...
override func viewWillAppear(_ animated: Bool) { {
	super.viewWillAppear(animated)
	loadIfNeeded()
...
}
...
private func loadIfNeeded() {
	if storage.numberOfValidElements < requiredNumberOfElements {
		loadMore()
	}
}

private func loadMore() {
	network.getObject { object in
		storage.addNew(object)
		updateUI()
		loadIfNeeded()
	}
}

private func showObject(in parentView: UIView) {
	guard let object = storage.nextValid else {
		showObjectPlaceholder()
		return
	}
	...
}
```

## Installation

### Swift Package Manager
Add it to the dependencies value of your Package.swift:
``` swift
dependencies: [
  // ...
  .package(url: "https://github.com/bivant/ExpiringStorage.git"),
],
```

### Cocoapods

ExpiringStorage is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

``` ruby
pod 'ExpiringStorage'
```

## Author

bivant, 6350992+bivant@users.noreply.github.com

## License

ExpiringStorage is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
