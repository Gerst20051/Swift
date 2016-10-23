#!/usr/bin/python

# sudo easy_install pip
# sudo pip install Pillow

import sys
from PIL import Image, ImageOps

images = {
    # "Default": [320, 480],  # iPhone 4 Portrait (not used)
    "Default-iOS56": [320, 480],  # iPhone 4 Portrait iOS 5,6
    "Default@2x": [640, 960],  # iPhone 4 Retina Portrait
    "Default-iOS56@2x": [640, 960],  # iPhone 4 Retina Portrait iOS 5,6
    "Default-568h@2x": [640, 1136],  # iPhone 5/5s Retina Portrait
    "Default-568h-iOS56@2x": [640, 1136],  # iPhone 5/5s Retina Portrait iOS 5,6
    "Default-667h@2x": [750, 1334],  # iPhone 6 Portrait
    "Default-736h@3x": [1242, 2208],  # iPhone 6 Plus Portrait
    "Default-Portrait": [768, 1024],  # iPad Portrait
    "Default-Portrait-iOS56": [768, 1024],  # iPad Portrait iOS 5,6
    "Default-Portrait@2x": [1536, 2048],  # iPad Air & Retina Portrait
    "Default-Portrait-iOS56@2x": [1536, 2048]  # iPad Air & Retina Portrait iOS 5,6
}

def createImages(image_path):
    for name, size in images.items():
        try:
            im = Image.open(image_path)
            im = ImageOps.fit(im, size, Image.ANTIALIAS)
            im.save("Stock Market Discovery/Assets.xcassets/LaunchImage.launchimage/" + name + ".png", "PNG")
        except IOError:
            print "cannot create image for '%s'" % image_path

if __name__ == '__main__':
    args = sys.argv[1:]
    if args:
        try:
            image_path = args[0]
            createImages(image_path)
        except Exception as e:
            print e
            sys.exit()
    else:
        print "Usage: python create_launch_images.py [path_to_image]"
        print "Example: python create_launch_images.py launch.png"
        sys.exit()
