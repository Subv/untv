UNTV - *Free Your Media*
=====================

UNTV is a cross platform DRM-free media platform for home theater computers. 
This project is very new, so right now your best bet is to check out the [ever 
evolving wiki](https://github.com/gordonwritescode/untv/wiki).

## Getting Started

Since UNTV is very much in infancy, I do not provide pre-built binaries (yet). 
UNTV also depends on a custom build of [Node-Webkit](https://github.com/rogerwang/node-webkit) 
which I have only compiled for GNU/Linux systems so far.

1. Clone the repository:

```
~# git clone https://github.com/gordonwritescode/untv.git
```

2. Install dependencies using Node Package Manager:

```
~# cd untv && sudo npm install
```

3. Make sure you have CoffeeScript installed globall (we use `cake` for tasks):

```
~# sudo npm install coffee-script -g
```

4. Run `cake setup` from the project root

> Alternatively download the custom build of node-webkit here: 
> https://www.dropbox.com/sh/3ne1qsdxtc848z6/Rx4dnzgu5S 
> Then, unzip and place contents in the `bin/nw-0.8.4-custom` directory.

5. Run `cake start` from the project root.
