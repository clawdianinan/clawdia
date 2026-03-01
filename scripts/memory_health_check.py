#!/usr/bin/env python3
import json
import os
import time
from pathlib import Path

WORKSPACE = Path('/Users/clawdia/.openclaw/workspace')
INDEX_DIR = WORKSPACE / 'skills' / 'qmd' / 'index'
MEMORY_DIR = WORKSPACE / 'memory'


def latest_mtime(path: Path, pattern: str = '*'):
    files = list(path.glob(pattern)) if path.exists() else []
    if not files:
        return None
    return max(f.stat().st_mtime for f in files if f.is_file())


def age_minutes(ts):
    if ts is None:
        return None
    return round((time.time() - ts) / 60, 2)


def main():
    memory_files = list(MEMORY_DIR.glob('*.md')) if MEMORY_DIR.exists() else []
    idx_files = list(INDEX_DIR.glob('*')) if INDEX_DIR.exists() else []

    latest_memory = latest_mtime(MEMORY_DIR, '*.md')
    latest_index = latest_mtime(INDEX_DIR, '*')

    index_age = age_minutes(latest_index)
    memory_age = age_minutes(latest_memory)

    status = 'ok'
    retrieval_mode = 'hybrid'
    notes = []

    if not INDEX_DIR.exists() or len(idx_files) == 0:
        status = 'degraded'
        retrieval_mode = 'keyword-fallback'
        notes.append('index-missing')
    elif index_age is not None and index_age > 24 * 60:
        status = 'degraded'
        retrieval_mode = 'keyword-fallback'
        notes.append('index-stale')

    result = {
        'status': status,
        'retrieval_mode': retrieval_mode,
        'memory_file_count': len(memory_files),
        'index_file_count': len(idx_files),
        'latest_memory_age_minutes': memory_age,
        'latest_index_age_minutes': index_age,
        'notes': notes,
    }

    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
