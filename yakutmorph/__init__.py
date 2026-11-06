"""
yakutmorph: tokenization, morphological analysis and disambiguation
for the Yakut (Sakha) language.

>>> from yakutmorph import YakutMorph
>>> parse = YakutMorph().parse('мин аатым Кэскил.')
"""
from importlib.metadata import PackageNotFoundError, version

from .main import YakutMorph

try:
    __version__ = version('yakutmorph')
except PackageNotFoundError:  # running from a source checkout that isn't installed
    __version__ = '0+unknown'

__all__ = ['YakutMorph', '__version__']
