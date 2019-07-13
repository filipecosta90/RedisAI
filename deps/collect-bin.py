#!/usr/bin/env python3

import os
import sys
from pathlib import Path
import itertools
import argparse

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "readies"))
import paella

parser = argparse.ArgumentParser(description='Report platform characteristics.')
parser.add_argument('--into', action="store", help='Install into ')
args = parser.parse_args() 


paella.mkdir_p('install')
for f in itertools.chain(Path('tensorflow').glob('**/*.so*'), Path('libtorch').glob('**/*.so*')):
    link = Path('install')/os.path.basename(f)
    if link.exists():
        os.unlink(link)
    os.symlink(Path('..')/f, link)
