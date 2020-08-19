"""A setuptools based setup module.

Created based on https://github.com/pypa/sampleproject
and dependencies ensured via pipenv-setup sync tooling.
"""
import sys

# Always prefer setuptools over distutils
from setuptools import setup, find_packages
from os import path


here = path.abspath(path.dirname(__file__))
sys.path.append(path.join(here, "src"))

from tools.utils.version import git_version  # noqa: E402

# Get the long description from the README file
with open(path.join(here, "README.md"), encoding="utf-8") as f:
    long_description = f.read()


setup(
    name="tools",  # Required
    version=git_version(),  # Required
    description="Project with CLI tools: setup-opendns, automount-cifs",  # Optional
    long_description=long_description,  # Optional
    long_description_content_type="text/markdown",  # Optional (see note above)
    url="https://github.com/matihost/learning",  # Optional
    author="matihost",  # Optional
    classifiers=[  # Optional
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Developers",
        "Topic :: Software Development :: Build Tools",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
    ],
    keywords="exchange rate nbp",  # Optional

    # When your source code is in a subdirectory under the project root, e.g.
    # `src/`, it is necessary to specify the `package_dir` argument.
    package_dir={"": "src"},  # Optional
    packages=find_packages(where="src"),  # Required

    # Ensures that non .py files are included in package
    setup_requires=['setuptools_scm'],
    include_package_data=True,

    python_requires=">=3.7, <4",
    install_requires=[
        "Jinja2>=2.11.2, <3",
    ],
    dependency_links=[],
    entry_points={
        "console_scripts": [
            "automount-cifs=tools.cli.automount_cifs:main",
            "setup-opendns=tools.cli.setup_opendns:main",
        ],
    },
    project_urls={"Source": "https://github.com/matihost/learning/", },  # Optional
)
