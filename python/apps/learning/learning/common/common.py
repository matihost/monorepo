"""Learning common classes.

Various common classes.
"""


class MyError(Exception):
    """My Error."""

    def __init__(self, *args):
        """Init constructor."""
        super().__init__(*args)

    def get_my_description(self) -> str:
        """Get my description."""
        # return self.__str__()
        # return self
        return str(self)


def fibonacci(i: int = 0):
    if i < 2:
        return i
    else:
        return fibonacci(i - 1) + fibonacci(i - 2)


fib_cache: dict[int, int] = {}


def fast_fib(i: int = 0):
    if i in fib_cache:
        # or
        # if fib_cache.get(i) is not None:
        return fib_cache[i]
    if i < 2:
        fib_cache[i] = i
    else:
        fib_cache[i] = fast_fib(i - 1) + fast_fib(i - 2)
    return fib_cache[i]


def fib_seq(n):
    a, b = 0, 1
    for _ in range(n):
        yield b
        a, b = b, a + b


def generate_all_fibonacci(n):
    for i in range(0, n + 1):
        yield fast_fib(i)


def get_single_argument(arguments):
    if len(arguments) < 1 or len(arguments) > 2:
        raise MyError("Function must contain a single argument as input")
    return arguments[0]


def get_single_number(arguments):
    try:
        number = int(get_single_argument(arguments))
    except Exception as e:
        raise MyError("Function parameter must be an int") from e
    return number


class Counter:
    """My Counter."""

    def __init__(self, limit):
        """My Counter costructor."""
        self.limit = limit
        self.current = 0

    def __iter__(self):
        """My Counter costructor."""
        return self

    def __next__(self):
        """My Counter costructor."""
        if self.current < self.limit:
            val = self.current
            self.current += 1
            return val
        raise StopIteration
