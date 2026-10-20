#!/bin/bash
# Omarchy voxtype status indicator

if which voxtype >/dev/null 2>&1; then
    voxtype status --format json 2>/dev/null || echo '{"alt": "", "tooltip": ""}'
else
    echo '{"alt": "", "tooltip": ""}'
fi
