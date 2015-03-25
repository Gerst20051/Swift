##The App


This tutorial will walk you through the creation of a geolocation based alarm app for travelers.  The concept is simple: users create a new alarm by selecting both a geographic region and music item from their library.  When the phone detects itself crossing the region boundary of an alarm (enter or exit) the relevant music plays.   

The app will begin with a rough prototype and grow through the series, culminating in the App Store submission of the final product.  Just like all prototypes, the initial build will be ugly and barely functional.  By the end I hope to cover all the edge cases and beautify the UI with interactive view controller transitions and animations. I believe we've got some time to kill before Swift apps can be submitted. 

Thanks to [Jon Kneen](http://www.linkedin.com/in/jonkneen) for the app idea.  

Everything (including the Markdown for these posts) is available on [GitHub](https://github.com/ChrisChares/swift-alarm)

##Why

Swift is brand new, exciting and a tiny bit scary.  We programmers learn new things by taking on new projects.  However, when our project code is never seen by anyone else there can be an incentive to cut corners and not fully explore why something worked or the right way to do it.  Putting this out to the world forces me to learn more and hopefully helps someone else learn too. 

I am by no means an expert on Swift, just discovered it yesterday along with everyone else.  There may be things in this series that are misguided, maybe others that are completely wrong.  Please point such things out in the comments section and I will do my best to update the error quickly.  This way we can all learn together.  

##Who

This is aimed at iOS developers familiar with Objective-C who are looking to explore Swift. Beginner to intermediate iOS devs may find the building of the app itself useful, while more advanced devs will find more value in the discussions on comparisons between Swift and Objective-C.    

##About Swift


####Read the Damn Manual
1. At the very least read the getting started guide in the [book](https://itunes.apple.com/us/book/the-swift-programming-language/id881256329?mt=11). 
2. Install the Xcode 6 beta
3. Install iOS 8 on a device

####Other resources

+ [We Heart Swift](http://www.weheartswift.com/) - Swift has been out for all of three days and they already have two high quality posts up.  
+ [iOS-Blog](http://ios-blog.co.uk/tutorials/developing-ios-apps-using-swift-part-1/) - Jameson Quave is also exploring Swift and documenting his code/experiences
+ [Ray Wanderlich's Swift Cheat Sheet](http://www.raywenderlich.com/73967/swift-cheat-sheet-and-quick-reference)
+ [How to use Cocoapods with Swift](https://medium.com/swift-programming/swift-cocoapods-da09d8ba6dd2)
+ [Chris Lattner's Homepage](http://nondot.org/sabre/) - Apple's head of Developer Tools
+ [Swift Criticisms](http://studentf.wordpress.com/2014/06/03/swift-not-quite-there-but-too-far-gone-too/)


Analyses of the language itself

+ [From a creator of Rust](http://graydon2.dreamwidth.org/5785.html)
+ [From Code School](http://blog.codeschool.com/post/87704128233/early-thoughts-on-swift-apples-new-programming)


##Let's get started!
[Part 1 - Prototype](http://chares.ghost.io/lets-make-a-swift-app-part-1/)