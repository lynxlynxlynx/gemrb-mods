gemrb-mods
==========

Repository of my GemRB mods and tools not included with GemRB itself. Available under GPLv2, see COPYING for details.

Many come in form of shell scripts, but could easily be adapted to work elsewhere.

DISCLAIMER: early versions of mods. While they do work for me, they contain a lot of assumptions! The platform is not ready yet for better generalisation, as noted below in the TODO.

Prerequisites
=============
* Python
* WeiDU - http://weidu.org

Runtime:
* GemRB - http://gemrb.org
* Any of the Infinity Engine games


TODO
====
* figure out a better way to insert string references / enhance WeiDU
* port the scripted hacks to python
* make them runnable from anywhere, completely path agnostic&safe
* create a common format regardless of the payload
* figure out a better backup mechanism, prefferably just using WeiDU's existing one
* (external) fix GemRB's overriding priority to simplify mod installation, not pollute the engine files and enable their modding
* double check that WeiDU can work from anywhere
* docs, wiki crossover
