from setuptools import setup, find_packages
import codecs
import os

here = os.path.abspath(os.path.dirname(__file__))

with codecs.open(os.path.join(here, "README.md"), encoding="utf-8") as f:
    long_description = f.read()

setup(
    name="yakutmorph",
    version="0.0.5",
    author="Nicolas Cortegoso Vissio",
    author_email="nicolascortegoso@hotmail.com",
    description="A morphological analyzer for Yakut language",
    long_description_content_type="text/markdown",
    long_description=long_description,
    packages=find_packages(),
    include_package_data=True,
    package_data={
        'yakutmorph': ['data/*.yaml', 'data/*.pkl', 'data/*.pth'],
    },
    install_requires=[
        'sfst-transduce>=1.0.2',
        'torch>=1.10.0',
        'PyYAML>=6.0.1'
    ],
    keywords=['python', 'morphology', 'analyzer', 'Yakut', 'Sakha', 'NLP'],
    classifiers=[
        "Development Status :: 1 - Planning",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: GNU General Public License v3 (GPLv3)",
        "Programming Language :: Python :: 3",
        "Operating System :: Unix",
        "Operating System :: MacOS :: MacOS X",
        "Operating System :: Microsoft :: Windows",
    ]
)
