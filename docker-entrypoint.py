#!/usr/bin/env python3
import os, sys
import subprocess

vj4_global_args = [
    'db-host',
    'db-name',
]
args = sys.argv[1:]
cmd = args[0] if len(args) > 0 else 'vj4.server'
arg_list = args[1:]
payload = []

if cmd.startswith('vj4.'):
    payload = [ sys.executable, '-m', cmd ]
    for k, v in os.environ.items(): # using environments start with `VJ_` as arguments
        if k.startswith('VJ_'):
            param_name = k[3:].lower().replace('_','-')
            if k == 'VJ_CMDLINE_FLAGS': # for bool flags like `--debug` or `--no-pretty`
                payload.extend(v.split())
            elif (param_name in vj4_global_args) or (cmd == 'vj4.server'):
                payload.append('--' + param_name)
                payload.append(v)
    payload.extend(arg_list)
else:
    payload = args

subprocess.call(payload)
