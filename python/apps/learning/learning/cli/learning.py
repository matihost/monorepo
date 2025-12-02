"""Learning snippets.

Various snippets.
"""

import importlib
import sys

from learning.common.common import (
    Counter,
    MyError,
    fast_fib,
    fib_seq,
    get_single_argument,
    get_single_number,
)


def main():
    func, arguments = parse_cli_arguments()
    func(arguments)


def parse_cli_arguments():
    if len(sys.argv) < 2:
        raise MyError("Must contain more than 1 argument")

    func_name = sys.argv[1]

    mod = importlib.import_module("learning.cli.learning")
    try:
        func = getattr(mod, func_name)
    except AttributeError:
        print(f"Function {func_name} not found, fallback to printall", file=sys.stderr)
        func = mod.printall
        # or
        # func = getattr(mod, "printall")
    return func, sys.argv[2 : len(sys.argv)]


def printall(arguments: list[str]):
    for i in arguments:
        print(i)


def sum(arguments: list[str]):
    sum = 0
    for i in arguments:
        try:
            sum += float(i)
        except Exception:
            pass
    print(f"Sum of arguments: {sum}")


def fib(arguments: list[str]):
    number = get_single_number(arguments)
    print(fast_fib(number))


def fiball(arguments: list[str]):
    number = get_single_number(arguments)
    for i in fib_seq(number):
        print(i)


def read(arguments: list[str]):
    filename = get_single_argument(arguments)
    with open(filename) as f:
        while True:
            line = f.readline()
            if not line:
                break
            print(line, end="")


def count(arguments: list[str]):
    number = get_single_number(arguments)
    for i in Counter(number):
        print(i)


if __name__ == "__main__":
    try:
        main()
    except MyError as e:
        print(e.get_my_description())
