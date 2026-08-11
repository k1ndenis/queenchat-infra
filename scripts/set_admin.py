#!/usr/bin/env python3
"""Run the in-container, interactive first-admin bootstrap safely."""
import os
import sys

if len(sys.argv) != 2:
    print("Usage: python3 scripts/set_admin.py <exact-username>")
    raise SystemExit(2)

os.execvp("docker", ["docker", "compose", "exec", "api", "python", "/app/scripts/set_admin.py", sys.argv[1]])
