UNTV - *Free Your Media*
=====================

UNTV is a cross platform DRM-free media platform for home theater computers. 
This project is very new, so right now your best bet is to check out the [ever 
evolving wiki](https://github.com/gordonwritescode/untv/wiki).

## Getting Started

### End Users

Download the latest bundled application for your platform:

> **UNTV bundled applications are not yet available.**

* GNU/Linux: [64bit](#) | [32bit](#)
* Mac OSX 10.7+: [32bit](#)
* Windows: [32bit](#)

Place in your Applications directory (or equivalent) and launch as usual. 

### Developers

Since UNTV is very much in infancy, I do not provide pre-built binaries (yet). 
UNTV also depends on a custom build of [Node-Webkit](https://github.com/rogerwang/node-webkit) 
which I have only compiled for GNU/Linux systems so far.

##### Clone the repository:

```
~# git clone https://github.com/gordonwritescode/untv.git
```

##### Install dependencies using Node Package Manager:

```
~# cd untv && sudo npm install
```

#####  Make sure you have CoffeeScript installed globally (we use `cake` for tasks):

```
~# sudo npm install coffee-script -g
```

##### Run `cake setup` from the project root

> Alternatively download the custom build of node-webkit here: 
> https://www.dropbox.com/sh/3ne1qsdxtc848z6/Rx4dnzgu5S 
> Then, unzip and place contents in the `bin/nw-0.8.4-custom` directory.

#####  Run `cake start` from the project root.

## Frequently Asked Questions

* Why does the project's commit history from December 23, 2013 to January 14, 
2014 contain a duplicate for every commit?

> The short answer is that I suck. The long answer is that I committed a large 
custom build of the node-webkit executable and decided that was silly. So I did 
a `filter-branch` to remove it on one machine and force pushed it here (I know, 
I will burn in Git hell), then I pulled from another machine and forced pushed 
again, which duplicated the history. Instead of rewriting history again, I 
decided to leave it alone even though it's ugly. Sorry.
