import processing.video.*; // https://github.com/processing/processing-video

// Instructions:
// After running, look at the available cameras
// pick one and set CAMERA_WIDTH and CAMERA_HEIGHT to match the camera,
// and set the index in the initCamera function
// Optionally set the size to be the same values as the camera width and height

final int CAMERA_WIDTH = 640;
final int CAMERA_HEIGHT = 480;
final int CAMERA_SLICE_HEIGHT = 3;
int IMAGE_SLICE_HEIGHT;

Capture cam;
ArrayList<PImage> images;


void setup() {
  size(640, 480);
  //fullScreen(1);
  frameRate(30);
  IMAGE_SLICE_HEIGHT = height / (CAMERA_HEIGHT / CAMERA_SLICE_HEIGHT);

  initCamera();
  // init images
  images = new ArrayList<PImage>(); // each image represents SLICE_HEIGHT rows 
  for (int i = 0; i < CAMERA_HEIGHT / CAMERA_SLICE_HEIGHT; i++) {
    images.add(createImage(width, height, RGB));
  }
}

// Initialize camera
void initCamera() {
  String[] cameras = Capture.list();

  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(i + ":" + cameras[i]);
    }
    
    // The camera can be initialized directly using an 
    // element from the array returned by list():
    cam = new Capture(this, CAMERA_WIDTH, CAMERA_HEIGHT, cameras[3], 30);
    cam.start();     
  }
}

// Take what's showing on the camera and copy slices of the image onto the array of images.
// The slices that are higher in the camera image gets copied onto the images near the front of the array
// while the slices that are lower in the camera image gets copied onto the images later in the array.
// The front most image in the array is the one that gets displayed. After it's displayed, the PImage object
// gets reused as a buffer image for later frames to avoid needing to constantly instantiate new PImage objects.
// The result is a video where the lower rows show a delayed renering of the camera
void draw() {
  if (cam.available() == true) {
    cam.read();
  }
  
  PImage nextImage = images.get(0); 
  nextImage.copy(cam, 0, 0, width, CAMERA_SLICE_HEIGHT, 0, 0, width, IMAGE_SLICE_HEIGHT);
  for (int i = 1; i < images.size(); i++) {
    images.get(i).copy(cam, 0, i*CAMERA_SLICE_HEIGHT, width, CAMERA_SLICE_HEIGHT, 0, i*IMAGE_SLICE_HEIGHT, width, IMAGE_SLICE_HEIGHT);
  }
  
  pushMatrix();
  // flip image horizontally so it acts more like a mirror
  scale(-1, 1);
  image(nextImage, -nextImage.width, 0);
  popMatrix();
  
  // cycle image we just drew to the end of the list to be reused
  images.remove(0);
  images.add(nextImage);
}