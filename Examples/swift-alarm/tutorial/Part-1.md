##Part 1 - Prototype

####Get the code

If you want the code in a state that lets you follow along

`git clone -b one-start git@github.com:ChrisChares/swift-alarm.git`

Or if you just want the finished code

`git clone git@github.com:ChrisChares/swift-alarm.git`

##Overview
As you will notice, the project is not empty.  6 .swift files exist, the storyboard is set up and IBOutlets are connected to their respective files.  There are also two .gpx files that will come in handy for testing location based services.  We're going to walk through and put code into the existing .swift files.

####Alarm.swift
Our model object, it will consist of a title, the region to watch, and the music item to play.

####AppDelegate.swift
Ah the infamous app delegate.  It will be responsible for listening to CLLocationManager updates and triggering alarms

####MasterViewController.swift
A table of alarms and a button to create new ones

####AlarmCreationViewController.swift
A UITableViewController subclass that handles the creation of new alarms

####MapViewController.swift
An interactive view controller for selecting the target region

##Party Time

Let's go file by file and fill in the requisite properties and methods, while taking note of key syntax and differences from Obj-C.  

###Alarm.swift

Add the following code to the class body
	
    var title:String
    var region:CLCircularRegion
    var media:MPMediaItem
    
    init( title:String, region:CLCircularRegion, media:MPMediaItem ) {
        self.title = title
        self.region = region
        self.media = media
    }
    
These are mandatory variables, and must be initialized either inline with their declaration or in the init context.  Try and remove `self.title = title`, see the compiler error?  We'll talk more about mandatory/optional variables later.  

###MasterViewController.swift

Add the table view's backing array to the top of the class definition
	
    var objects: Alarm[] = []

Note the explicit typing here.  This is an array of alarms, trying to put any kind of different object (Hat, Dog, Int, Float, Manhandler etc) into it is an exception.  This is a sharp contrast to the type agnostic nature of `NSArray` and `NSMutableArray`.

Now let's fill in the UITableViewDataSourceMethods below `viewDidLoad()`

	// #pragma mark - UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

        let object = objects[indexPath.row] as Alarm
        cell.textLabel.text = object.title
        return cell
    }

This is our first method declaration and there are a few things going on 

+ We are explicitely overriding superclass methods with the `override` keyword.  Keep in mind that this is because we subclassed `UITableViewController`, the `override` keyword is not necessary when implementing protocol methods.  

+ Use `let` instead of `var` whenever you know the value won't change

+ 3 word long parameter definitions.  Yes this is a thing, and especially common when interacting with Cocoa APIs.  The format goes like this `[externalName] [internalName]:[class]`.  Internal names are used inside the function, and external names are used when calling the function. i.e. that last method could be called as `self.tableView(tableView: aTableView, cellForRowAtIndexPath: aIndexPath)`.  In your own custom function declarations you do not need an external name.  

+ The `as` keyword is used to typecast variables.  It is also effected by the `?` operator.  If you use `as` and the typecast fails (on a nil or invalid object), it is a runtime error.  If you cannot be sure the typecast will succeed, use `as?` instead, which will return nil in the case of failure


###AppDelegate.swift
Add the following instance variables alongside `window`

	var window:UIWindow?
	var alarms: Dictionary<String, Alarm> = Dictionary(minimumCapacity: 0)
    let locationManager: CLLocationManager = CLLocationManager()
    var masterViewController : MasterViewController!
    
Notice how global variables can be defined inline and the dictionary definition uses generics to strongly type itself.  This is pretty similar to syntax for Java generics.

If you didn't get an adequate description of the `?` and `!` operators from the Swift book's getting started guide (I certainly didn't), read on  
    
--------
####A word about optional variables and unwrapping

Objective-C has a blunt way of dealing with the infamous NullPointerException, namely  not throwing an exception for messaging nil objects.  While it effectively removed the tyranny of that exception, nil messaging can lead to some unintended and difficult to debug behaviours.  

Swift takes a declarative approach to handling nil variables

#####Optional variables

	var window:UIWindow?

This is an optional variable and probably the closest thing to Obj-C's properties.  It can be nil.  You must unwrap its value with the ! operator in order to access its methods and properties.  If you try and unwrap a nil object it will throw a runtime exception so don't forget to check it first!
	
 	if ( window ) window!.makeKeyAndVisible()
    
#####Mandatory variables

	let locationManager: CLLocationManager = CLLocationManager()

This is a mandatory value.  In fact if you don't assign it a value inline with the variable declaration, you must do so in an init method.  To not do so is a compile-time error.

	locationManager.delegate = self
    
#####Implicitly Unwrapped

	var masterViewController : MasterViewController!

This is an implicitly unwrapped variable.  While it can be nil, it is assumed to contain a value and therefore implicitly unwrapped upon use.  Note that this can be dangerous as a nil, as these variables will still throw a runtime error when accessed. 

	masterViewController.view
    
------

Back to the AppDelegate, make your `didFinishLaunchingWithOptions:` look as follows

  	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        
        locationManager.delegate = self;
        
        if ( ios8() ) {
            locationManager.requestAlwaysAuthorization()
        }
        
        //get the master view controller
        let nav = application.windows[0].rootViewController as UINavigationController
        masterViewController = nav.viewControllers[0] as MasterViewController
        
        return true
    }

In iOS 8 you must call either `locationManager.requestAlwaysAuthorization()` or `locationManager.requestWhenInUseAuthorization()` before using location services.  They also require a matching Info.plist value to display to users during authorization.  Check the documentation or open up the Info.plist for more.  

Now lets add the following methods
	
    func addAlarm(alarm:Alarm!) {
        
        alarms.updateValue(alarm, forKey: alarm.region.identifier)
        locationManager.startMonitoringForRegion(alarm.region)
        
        masterViewController.objects.append(alarm)
        masterViewController.tableView.reloadData()
    }
    
    func launchAlarmViewController(alarm:Alarm!) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let alarmVC = storyboard.instantiateViewControllerWithIdentifier("alarm") as AlarmViewController
        alarmVC.alarm = alarm
        let nav = UINavigationController(rootViewController: alarmVC)
        masterViewController.presentViewController(nav, animated: true, completion: {})
        
    }
    
    func alarmForRegionIdentifier(identifier:String!) -> Alarm? {
        
        if let alarm = alarms[identifier] as? Alarm {
            return alarm
        } else {
            return nil
        }
        
    }
    
Couple thoughts on this. 

+ We are storing alarms in a dictionary with their region's identifier as the key. This makes them easy to find later when we get region monitoring updates from `locationManager`
+ `dictionary.updateValue(value, key)` is the Dictionary equivalent of `NSMutableDictionary`'s `setObjectForKey:`
+ The `if-let` keyword is great.  It allows you to summarize something like
	
    	if ( dictionary["key"] ) {
        	let obj = dictionary["key"]
            //do something with obj
        }
 as
 		
        if let obj = dictionary["key"] {
        	//do something with obj
        }

Now add the `CLLocationManagerDelegate` methods
	
    //#pragma mark - CLLocationManagerDelegate
    
    func locationManager(manager:CLLocationManager, didEnterRegion region:CLRegion) {
        
        println("Entered Region " + region.identifier );
        if let alarm = alarmForRegionIdentifier(region.identifier) {
            launchAlarmViewController(alarm)
        }
        
    }
    
    func locationManager(manager:CLLocationManager, didExitRegion region:CLRegion) {
        
        println("Exited Region " + region.identifier );
        if let alarm = alarmForRegionIdentifier(region.identifier) {
            launchAlarmViewController(alarm)
        }
        
    }

Note the use of `if-let`s and external parameter names to interact with Cocoa APIs



##MapViewController
Add the delegate declaration at the top

	protocol MapViewControllerDelegate {
    
    	func returnedRegion( region:CLCircularRegion )
    
	}

Add a property to the `MapViewController` class for the delegate
	
    var delegate : MapViewControllerDelegate? = nil

Add the following code to `viewDidLoad()` (there's no `CLSquareRegion` after all)

	targetView.layer.cornerRadius = 40.0

Finally, add the following code to `IBAction save`

	 	//save
        if ( delegate ) {
            
            let center = mapView.centerCoordinate
            
            let targetViewRegion = mapView.convertRect(targetView.bounds, toRegionFromView: targetView)
            
            //every degree of latitude delta corresponds to 110km
            let radius = targetViewRegion.span.latitudeDelta  * 110 * 1000
            
            //create a unique UUID
            let uuid = NSUUID().UUIDString
            
            let region = CLCircularRegion(center: center, radius: radius, identifier: uuid)
            self.delegate!.returnedRegion(region)
        }

    
 
##AlarmCreationViewController.swift

This `UITableViewController` uses static cells from the storyboard

Add the properties for an alarm mid creation
	
    var mediaItem:MPMediaItem?
    var region:CLCircularRegion?

make sure we are the delegate of the `MapViewController` if it is launched

	override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {

        if ( segue!.identifier == "map" ) {
            var mapVC = segue!.destinationViewController as MapViewController;
            mapVC.delegate = self;
        }
    }
    
Set up the save and cancel methods
 
 	@IBAction func cancel(sender : AnyObject) {
        
        navigationController.presentingViewController.dismissViewControllerAnimated(true, completion: {});
        
    }

    @IBAction func save(sender : AnyObject) {
        
        if ( region == nil || mediaItem == nil || titleLabel.text.isEmpty ) {
            //validation failed
            return
        }
        
        
        var alarm = Alarm(title: titleLabel.text, region: region!, media: mediaItem!)

        
        navigationController.presentingViewController.dismissViewControllerAnimated(true, completion: {
            
            let appDelegate : AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            
            appDelegate.addAlarm(alarm)
            
        });
    }
    
Finally, let's add some delegate methods
####Delegate methods
`UITableViewDelegate`
	
    /*
    #pragma mark - UITableViewDelegate
    */

    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
    
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if ( cell == mediaCell ) {
            
            let mediaPicker = MPMediaPickerController(mediaTypes: .Music)
            mediaPicker.delegate = self
            mediaPicker.prompt = "Select any song!"
            mediaPicker.allowsPickingMultipleItems = false
            presentViewController(mediaPicker, animated: true, completion: {})
            
        }
        
    }
    
Constant names are way less verbose as they've been switched to Swift Enumerations!  For example `MPMediaItemTypeMusic` is now just `.Music`

`MapViewControllerDelegate`

	/*
    MapViewControllerDelegate
    */
    func returnedRegion(region: CLCircularRegion) {
        
        
        self.region = region
        mapCellLabel.text = "Region Selected"
        self.navigationController.popViewControllerAnimated(true)
    }

The use of self is not necessary for accessing properties anymore, but it can be very useful to differentiate between a instance property and method parameter.

`MPMediaPickerControllerDelegate`

	/*
    MPMediaPickerControllerDelegate
    */
    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems  mediaItems:MPMediaItemCollection) -> Void
    {
        var aMediaItem = mediaItems.items[0] as MPMediaItem
        if ( aMediaItem.artwork ) {
            mediaImageView.image = aMediaItem.artwork.imageWithSize(mediaCell.contentView.bounds.size);
            mediaImageView.hidden = false;
        }
      
        self.mediaItem = aMediaItem;
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController) {
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
Anyone who messed around with the MediaPlayer framework before might have noticed that all the properties of MPMediaItem accessible via `valueForProperty:` are now direct properties on the MPMediaItem object a la `.artwork`


##Final View Controller! AlarmViewController.swift
The full class is pretty self-explanatory, just make it look like this

	import UIKit
	import MediaPlayer

	class AlarmViewController: UIViewController {

    var musicPlayer = MPMusicPlayerController.applicationMusicPlayer()
    var alarm:Alarm!
    
    
    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = alarm.title
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        playMedia(alarm.media)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func playMedia(media:MPMediaItem!) {
        
        let array = [media]
        let collection = MPMediaItemCollection(items: array)
        
        musicPlayer.setQueueWithItemCollection(collection)
        musicPlayer.play();
        
        
    }

    @IBAction func shutup(sender : AnyObject) {
        
        musicPlayer.stop()
        navigationController.presentingViewController.dismissModalViewControllerAnimated(true)
        
    }

	}


#It's alive!

Test it using the included .gpx files.  Setup a new alarm on top of your current location, then fake your location to London or Denver.  Voila! It's making noise!

##The end is only the beginning

There remains so much to be done.  There's no backgrounding or persistence, you can't edit or remove alarms and the UI looks like worse than the drawings of an unartistic 2nd grader.  We will continue to improve this iteratively in later posts, but for now just enjoy your first Swift app!


