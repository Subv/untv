UNTV - *Free Your Media*
=====================

UNTV is a cross platform DRM-free media platform for home theater computers. 
This project is very new, so right now your best bet is to check out the [ever 
evolving wiki](https://github.com/gordonwritescode/untv/wiki).

## Getting Started

Since UNTV is very much in infancy, I do not provide pre-built binaries (yet). 
UNTV also depends on a custom build of [Node-Webkit]() 
which I have only compiled for GNU/Linux systems so far.

1. Clone the repository:

  ~# git clone https://github.com/gordonwritescode/untv.git

2. Install dependencies using Node Package Manager:

  ~# cd untv && sudo npm install

3. Download the custom build of node-webkit here: https://www.dropbox.com/sh/3ne1qsdxtc848z6/Rx4dnzgu5S

4. Unzip and place contents in the `bin/nw-0.8.4-custom` directory.

5. Run `npm start` from the project root.
