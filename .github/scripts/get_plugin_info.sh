#!/bin/bash

# 获取插件名称和版本读取Makefile文件
MAKEFILE="./package/openclash-guard/Makefile"

PKG_NAME=$(grep -E '^PKG_NAME:=' $MAKEFILE | cut -d '=' -f 2 | tr -d ' ')
PKG_VERSION=$(grep -E '^PKG_VERSION:=' $MAKEFILE | cut -d '=' -f 2 | tr -d ' ')

echo "插件包名称：$PKG_NAME"
echo "插件版本：$PKG_VERSION"

echo "PLUGIN_NAME=$PKG_NAME" >> $GITHUB_ENV
echo "PLUGIN_VERSION=$PKG_VERSION" >> $GITHUB_ENV
