# Factual IOS SDK

## Get an API Key
Obtain an oauth key and secret from Factual at [https://www.factual.com/api-keys/request](https://www.factual.com/api-keys/request).  Do not expose your _secret_ to third-parties (keep it secret).

## Installation

### Distribution

1.	Download the latest driver [version 1.3.8](https://github.com/Factual/factual-ios-sdk/blob/develop/downloads/factual-ios-sdk-1.3.8.tgz?raw=true)
2.	Untar and add the FactualSDK.framework to your appropriate XCode project directory. Add it to the list of linked frameworks in your project. 
    
### Source

1.	Download the driver source
2.	Run makeFramework.sh.
3.	Add build/Framework/FactualSDK.framework to your appropriate XCode project directory.  Add it to the list of linked frameworks in your project. 


## Sample Code

Refer to the Factual IOS SDK Demo project at [https://github.com/Factual/factual-ios-sdk-demo]( https://github.com/Factual/factual-ios-sdk-demo ) for an example of how to use the SDK. 

## Supported Platforms

The SDK supports armv6, armv7, and armv7s architectures. It is built to support IOS versions 3.2 and 
onwards but it officially supports devices running IOS 4.3 and higher.  ARC is supported by the SDK.

## Special Considerations

The SDK currently is built as a static library. IOS applications linking against the SDK must specify 
the -all_load linker flag as documented here ( http://developer.apple.com/library/mac/#qa/qa1490/_index.html ).
