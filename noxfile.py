"""Nox configuration file"""
from typing import Any, Callable

from nox import Session
from nox import session

# build docs
@session()
def doc(session: Session) -> None:
    """Build documentation."""
    session.install(
        "git+https://github.com/jean-loutre/py-lua-doc",
        "mkdocs-awesome-pages-plugin",
        "mkdocs-material",
        "mkdocs-section-index",
        "mkdocstrings[python]",
        "snakemd",
    )
    session.run("python3", "doc/api/gen-pages.py")
    session.run("mkdocs", "build")
