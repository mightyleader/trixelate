# Trixelate
A Swift playground to pixelate images into triangles

## IMPORTANT
Ensure you have made a directory in `~/Documents` called `Shared Playground Data`. 
This is accessible by Playgrounds as a place in the filesystem to access files with read/write permissions.

Inside the shared folder create a new folder called `Trixelated` which will be where the trixelated images are written to.

Inside `Trixelated` create a folder called `Source` which is where you put the images you want to trixelate.

In summary, create a folder here: `~/Documents/Shared Playground Data/Trixelated/Source` and put in it any images you want to process.

In the Playground itself, change the number for the `ratio` parameter in the `trixelate(imageAtURL)` function on line 125 to determine the granularity of the trixelated image. 
For example, set it to `15` for abstract images and `50` for more details ones.
The trixels maintain the same aspect ratio as the original image, so this `ratio` parameter determines the amount of trixels to process as rows and columns.

## Original

![original](https://github.com/mightyleader/trixelate/blob/master/Examples/original.jpg)

Image is copyright Rob Stearn 2018

## Trixelated

![trixelated](https://github.com/mightyleader/trixelate/blob/master/Examples/trixelated.png)

## TODO
Handle error if a file access in `~/Documents/Shared Playground Data/Trixelated/Source` is not an image file.
Provide some better output indication when each image is complete and when all are complete.
