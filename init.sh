# shellcheck shell=sh

if test ! -f ~/.init; then
  curl -L bit.ly/asen23-init | bash
  touch ~/.init
fi
