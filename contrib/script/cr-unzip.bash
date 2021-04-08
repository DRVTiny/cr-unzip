#!/bin/bash
LD_PRELOAD=/usr/local/lib/libz_ng/libz.so.1.2.11.zlib-ng \
CRYSTAL_WORKERS=$(nproc) \
	$0-real $@
