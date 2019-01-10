# EtsySwift 🖼

EtsySwift is built on top of RxAlamofire for your iOS projects written in Swift 4.2. for easy API connection with Etsy.

## Installation  
1. Add `pod 'EtsySwift'` to your Podfile
2. Run `pod install`
3. Add `import EtsySwift` wherever you want to use the library

## Setup ⚒
To setup the library, you need to pass your consumer key and consumer secret keys.  
**Never leave your confidential keys in your repository - use any form of obfuscation or cryptography to keep your data safe.**

```swift
class API {
    let shared = API()
    let etsy: EtsySwift
    init() {
        etsy = EtsySwift(consumerKey: "CONSUMER_KEY", consumerSecret: "CONSUMER_SECRET")
    }
}

```

## Login
After that you need to login, passing your required scope, as [defined in Etsy API](https://www.etsy.com/developers/documentation/getting_started/oauth#section_permission_scopes).

```swift
API.shared.etsy.login(["email_r"], callback: "etsyintegration://oauth-callback")
```

The second argument you pass is the callback URL that will be triggered after user will log in - Etsy uses oAuth authorization - the library will open a Safari window for you. You need to register your custom scheme in your application and pass it there.
Additionally, you need to add following method to your `AppDelegate`:

```swift
func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
    API.shared.etsy.callbackCalled(url: url)
    return true
}
```

## Making Requests
After you authorize with the login method, you can easilly call any method from Etsy API that you have access to. I've also added a handy Rx extension for decoding the response from the API.

For now, the API only supports one resource (shops), but you can use the `request(method:url:)` method to request any resource you might need.
Let me know if you will need any other resources to be added to the library or submit a pull request.

```swift
API.shared.etsy.request(.shops("__SELF__")).decodedAs(EtsyResponse<EtsyShop>.self)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Add your changes
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request

## License
MIT



