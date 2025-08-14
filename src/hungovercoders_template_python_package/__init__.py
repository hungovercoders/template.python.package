"""Hungover Coders Template Python Package.

A Python package template for demonstrative purposes that can be cloned
by others to quickly set up a development environment.
"""

__version__ = "0.1.1"
__author__ = "dataGriff"
__email__ = "info@hungovercoders.com"

from .greetings import goodbye, goodbye_cli, hello, hello_cli
from .organisation import main as validate_organisation

__all__ = [
    "hello",
    "hello_cli",
    "goodbye",
    "goodbye_cli",
    "validate_organisation",
    "__version__",
    "__author__",
    "__email__",
]
