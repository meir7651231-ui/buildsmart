#!/usr/bin/env python3
"""BuildSmart entry point for the catalog QA engine.

The engine moved to packages/catalog_qa/catalog_qa.py. This file runs it with
BuildSmart's settings (scripts/catalog_qa.buildsmart.json), so
`python3 scripts/catalog_qa.py <cmd>` and `import catalog_qa` keep working.
"""
import importlib.util
import os
import sys

_HERE = os.path.dirname(os.path.abspath(__file__))
_spec = importlib.util.spec_from_file_location(
    "catalog_qa_engine", os.path.join(_HERE, "..", "packages", "catalog_qa", "catalog_qa.py"))
_engine = importlib.util.module_from_spec(_spec)
sys.modules["catalog_qa_engine"] = _engine
_spec.loader.exec_module(_engine)
_engine.configure(_engine.load_config(os.path.join(_HERE, "catalog_qa.buildsmart.json")))

globals().update({k: v for k, v in vars(_engine).items() if not k.startswith("__")})

if __name__ == "__main__":
    _engine.main()
