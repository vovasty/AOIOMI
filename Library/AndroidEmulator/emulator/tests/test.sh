#!/usr/bin/env bash
set -e

$ROOT_DIR/app.sh delete || echo failed to delete
$ROOT_DIR/app.sh create
$ROOT_DIR/app.sh start &
$ROOT_DIR/app.sh wait_booted
$ROOT_DIR/app.sh set_proxy 10.0.2.2:8080
$ROOT_DIR/app.sh install_ca ~/Library/Application\ Support/Charles/ca/charles-proxy-ssl-proxying-certificate.pem
$ROOT_DIR/app.sh install_gapps
$ROOT_DIR/app.sh stop
echo SUCCESS