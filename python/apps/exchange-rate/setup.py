"""A setuptools based setup module.

Created based on https://github.com/pypa/sampleproject
and dependencies ensured via pipenv-setup sync tooling.
"""
import sys
# Always prefer setuptools over distutils
from setuptools import setup, find_packages
from os import path
import site

# workaround for https://github.com/pypa/pip/issues/7953
site.ENABLE_USER_SITE = "--user" in sys.argv[1:]
here = path.abspath(path.dirname(__file__))
sys.path.append(path.join(here, 'src'))

from exchange_rate.helpers.version import git_version  # noqa: E402

# Get the long description from the README file
with open(path.join(here, "README.md"), encoding="utf-8") as f:
    long_description = f.read()


setup(
    name="exchange-rate",  # Required
    version=git_version(),  # Required
    description="A sample Python project showing exchange rate between two currencies",  # Optional
    long_description=long_description,  # Optional
    long_description_content_type="text/markdown",  # Optional (see note above)
    url="https://github.com/matihost/learning",  # Optional
    author="matihost",  # Optional
    classifiers=[  # Optional
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "Topic :: Software Development :: Build Tools",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3.9",
    ],
    keywords="exchange rate nbp",  # Optional
    # When your source code is in a subdirectory under the project root, e.g.
    # `src/`, it is necessary to specify the `package_dir` argument.
    package_dir={"": "src"},  # Optional
    packages=find_packages(where="src"),  # Required
    python_requires=">=3.9, <4",
    install_requires=[
        "requests>=2.25.1, <3",
    ],  # Optional
    dependency_links=[],
    entry_points={
        "console_scripts": ["exchange-rate=exchange_rate.cli.exchange_rate:main", ],
    },
    project_urls={"Source": "https://github.com/matihost/learning/", },  # Optional
)
