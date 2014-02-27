![UNTV](https://raw.github.com/untv/untv/master/src/assets/images/untv-logo.png)

UNTV is a cross platform DRM-free media platform for home theater computers. 
This project is still evolving, so right now your best bet is to check out the 
**[docs/ directory](https://github.com/gordonwritescode/untv/tree/master/docs)**.

## Getting Started

### End Users

Download the [latest bundled release](https://github.com/untv/untv/releases) for your platform and place in your Applications directory (or equivalent) and launch as usual. 

### Developers

Since UNTV aims to provide support for as many codecs as possible, it uses a custom build of [Node-Webkit](https://github.com/rogerwang/node-webkit) which I have compiled for linux64, darwin32, and win32. You may, however, use the upstream builds of Node-Webkit, but you will sacrifice playback support for just about everything except for `.ogg` and `.webm`. 

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
> https://file.ac/s4Lt3Vo6rls/
> Then, unzip and place contents in the `bin/nw-0.8.4-custom` directory.

#####  Run `cake start` from the project root.
