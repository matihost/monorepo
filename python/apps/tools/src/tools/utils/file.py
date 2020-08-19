"""File utils."""

from os import path


def relative_path(start_location, *relative_paths):
    """Provide absolute path from start_location + relative paths."""
    here = path.abspath(path.dirname(start_location))
    return path.join(here, *relative_paths)


def read_file(file_path, ignore_error=False):
    """Safely read file and return empty str in case ignore_error fla is set."""
    try:
        with open(file_path, encoding="utf-8") as file:
            return file.read()
    except OSError as err:
        if ignore_error:
            return ''
        raise err


def write_file(file_path, content, mode='w'):
    """Store content to file."""
    with open(file_path, mode, encoding="utf-8") as file:
        return file.write(content)
