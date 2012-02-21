![Masked Icons](https://s3.amazonaws.com/peyton.github.com/GOODMaskedIconView/Why.png)

#Introduction
----------

GOODMaskedIconView is a UIView subclass that uses black-and-white masks to draw icons of different
styles at various sizes and resolutions. It uses the same technique as
UITabBar to generate disparate effects from a single icon file.

![Tab bar icons](https://s3.amazonaws.com/peyton.github.com/GOODMaskedIconView/Tab-bar.png)

GOODMaskedIconView displays common image formats and PDFs, the native vector file format of iOS and
OS X. PDFs are best—they're easy to maintain and resolution independent.

#Examples
---------

###Create a green icon from a PNG

    GOODMaskedIconView *iconView = [[GOODMaskedIconView alloc] initWithResourceNamed:@"icon.png"]
    iconView.color = [UIColor greenColor];
    [self.view addSubview:iconView];

###Resize a PDF icon and add a subtle gray gradient

    GOODMaskedIconView *iconView = [[GOODMaskedIconView alloc] initWithPDFNamed:@"icon.pdf" size:CGSizeMake(32.0f, 26.0f)];
    iconView.gradientStartColor = [UIColor colorWithWhite:0.7f alpha:1.0f];
    iconView.gradientEndColor = [UIColor colorWithWhite:0.5f alpha:1.0f];
    [self.view addSubview:iconView];
    
###Add an overlay to a red icon

    UIImage *overlay = [UIImage imageNamed:@"overlay.png"];
    GOODMaskedIconView *iconView = [[GOODMaskedIconView alloc] initWithImageNamed:@"icon.png"];
    iconView.color = [UIColor redColor];
    iconView.overlay = overlay;
    [self.view addSubview:iconView];

###Render a PDF icon into a UIButton

    GOODMaskedIconView *iconView = [[GOODMaskedIconView alloc] initWithResourceNamed:@"icon.pdf"];
    iconView.color = [UIColor magentaColor];
    iconView.highlightedColor = [UIColor orangeColor];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[iconView renderImage] forState:UIControlStateNormal]
    [button setImage:[iconView renderHighlightedImage] forState:UIControlStateHighlighted];
    [self.view addSubview:button];

For more examples, check the [Demo Project](https://github.com/peyton/GOODMaskedIconView/tree/master/Demo%20Project).

#How to use
-----------

###First: Clone into a submodule

In your project's folder, type:

    git submodule add git://github.com/peyton/GOODMaskedIconView.git

A submodule allows your repository to contain a clone of an external
project. If you don't want a submodule, use:

    git clone git://github.com/peyton/GOODMaskedIconView.git

###Next: Add classes

Drag `GOODMaskedIconView.h` and `GOODMaskedIconView.m` into your Xcode
project's file browser.

*Note:* An options dialog will pop up. If you're using GOODMaskedIconView as a submodule,
you should uncheck "Copy items into destination group's folder (if needed)."

###Then: Import the header

    #import "GOODMaskedIconView.h"

###Later: Update to the latest version

`cd` into the GOODMaskedIconView directory and run:

    git pull

#Creating image masks
---------

![Image mask process](https://s3.amazonaws.com/peyton.github.com/GOODMaskedIconView/Mask.png)

An image mask is a black-and-white image that clips when drawing. Quartz translates masks to images using three simple rules:

* Black pixels render opaquely.
* White pixels render transparently.
* Gray pixels render with an alpha value of 1 - *source pixel's gray value*.

Mask images may not use an alpha channel, so icons with transparency must be set on a white background. For more information about Quartz image masking, see
the [Quartz 2D Programming Guide](https://developer.apple.com/library/ios/#documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_images/dq_images.html%23//apple_ref/doc/uid/TP30001066-CH212-CJBHDDBE).

#Scalable icons with PDFs
---------

GOODMaskedIconView makes it easy to use PDFs as icons, eliminating "\*@2x.\*" files.
Many Apple applications on OS X use PDF icons for resolution independence.

Next to the network, the biggest source of latency on an iPhone is the disk. For small, simple icons the PDF format adds a few KB of overhead over PNG.
Because the iPhone loads data in chunks, in practice the difference in loading time is nothing. For larger icons a PDF of vectors can *save* space.

Some editors need a little massaging to export PDFs suitable for
iOS icons. Quick how-to instructions are [here](https://github.com/peyton/GOODMaskedIconView/wiki/Exporting-PDFs).

#Contributing
--------

Forks, patches, and other suggestions are always welcome. Here's a [quick guide](https://github.com/peyton/GOODMaskedIconView/wiki/Contributing) to the process.
