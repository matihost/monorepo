"""Emulate head command."""

import sys


def main():
    """Enter the program."""
    n, filename = parse_argv()
    head(filename, n)


def parse_argv():
    args = sys.argv[1:]
    n = 10
    if len(args) >= 1:
        filename = args[0]
    else:
        print("Filename not provided", file=sys.stderr)
        sys.exit(2)
    if len(args) >= 2:
        n = int(args[1])
    return n, filename


def head(filename: str, n=10):
    try:
        with open(filename) as f:
            i = 0
            while i < n:
                print(f.readline(), end="")
                i += 1
    except FileNotFoundError:
        print(f"Filename {filename} not found", file=sys.stderr)
        sys.exit(2)


if __name__ == "__main__":
    main()
