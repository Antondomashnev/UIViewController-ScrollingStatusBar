UIViewController-ScrollingStatusBar
=============
-------------

Category for UIViewController with UIScrollView to scroll statusBar along any UIScrollView subclass.

<img src="https://dl.dropboxusercontent.com/u/25847340/UIViewController-ScrollingStatusBar/demo.gif" width="320" />

------------
Requirements
============

UIViewController-ScrollingStatusBar works on any iOS version only greater or equal than 7.0 and is compatible with only ARC projects. It depends on the following Apple frameworks:

* Foundation.framework
* UIKit.framework
* CoreGraphics.framework

You will need LLVM 3.0 or later in order to build UIViewController-ScrollingStatusBar. 

------------------------------------
Adding UIViewController-ScrollingStatusBar to your project
====================================

From CocoaPods
------------

Add `pod 'UIViewController-ScrollingStatusBar' '~> 1.0.0'` (i hope it will be merged soon =)) to your Podfile.

Source files
------------

There is an old school way to add the UIViewController-ScrollingStatusBar to your project is to directly add the source files from Source folder in project folder to your project.

-----
Usage
=====

You can create scrolling status bar with only a one line of code for 
```objective-c
/*
  import category
*/
#import "UIViewController+ScrollingStatusBar.h"

/*
  for example in viewDidLoad
*/
- (void)viewDidLoad
{
  ...
  [self enableStatusBarScrollingAlongScrollView: someScrollView];
} 

/*
  Don't forget to disable it in for example dealloc
*/
- (void)dealloc
{
  [self disableStatusBarScrollingAlongScrollView: someScrollView];
}

```

-------
License
=======

This code is distributed under the terms and conditions of the MIT license. 
