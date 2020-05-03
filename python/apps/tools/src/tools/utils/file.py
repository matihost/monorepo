from os import path


def relative_path(start_location, *relative_paths):
    here = path.abspath(path.dirname(start_location))
    return path.join(here, *relative_paths)


def read_file(file_path, ignore_error=False):
    try:
        with open(file_path, encoding="utf-8") as file:
            return file.read()
    except OSError as err:
        if ignore_error:
            return ''
        raise err


def write_file(file_path, content):
    with open(file_path, 'w', encoding="utf-8") as file:
        return file.write(content)
