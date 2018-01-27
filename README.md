# Trixelate
A Swift playground to pixelate images into triangles

## IMPORTANT
Ensure you have made a directory in `~/Documents` called `Shared Playground Data`. 
This is accessible by Playgrounds as a place in the filesystem to access files with read/write permissions.

Inside the shared folder create a new folder called `Trixelated` which will be where the trixelated images are written to.

Inside `Trixelated` create a folder called `Source` which is where you put the images you want to trixelate.

## Original

![original](https://github.com/mightyleader/trixelate/blob/master/Examples/original.jpg)

Image is copyright Rob Stearn 2018

## Trixelated

![trixelated](https://github.com/mightyleader/trixelate/blob/master/Examples/trixelated.png)

## TODO
Handle error if a file access in `~/Documents/Shared Playground Data/Trixelated/Source` is not an image file.
Provide some better output indication when each image is complete and when all are complete.
