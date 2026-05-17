"""Learning snippets.

Various snippets.
"""


def iterate(strs: list):
    for i in strs:
        print(i)


def iterateargs(*strs):  # positional args (like Java ... equivalent)
    for i in strs:
        print(i)


def iteratekwargs(**strs):  # keyword args, aka dictionary
    for key in strs.keys():
        print(f"{key}={strs.get(key)}")


def iterateold(strs):
    for i in range(len(strs)):
        print(strs[i])


def reverse(value: str):
    chars = list(value)
    for i in range(len(chars) // 2):  # floor with int result , / is result to float
        c = chars[i]
        chars[i] = chars[len(chars) - i - 1]
        chars[len(chars) - i - 1] = c
    return "".join(chars)  # python has no way to constuct string from char array


def two_sum(target: int, input_list: list[int]) -> list[int] | None:
    saw = {}  # number -> index
    for i in range(len(input_list)):
        search = target - input_list[i]
        search_index = saw.get(search)
        if search_index is not None:
            return [search_index, i]
        saw[input_list[i]] = i
    return None


def longest_unique_substring(input_str: str) -> str:
    input_chars = list(input_str)
    left = 0
    current_substring = ""
    current_position = {}  # char -> position
    for i in range(len(input_str)):
        if input_chars[i] in current_position:
            new_left = current_position[input_chars[i]] + 1
            for j in range(left, new_left):
                current_position.pop(input_chars[j], None)
            left = new_left
        current_position[input_chars[i]] = i
        sub = input_str[left : i + 1]
        if len(current_substring) < len(sub):
            current_substring = sub
    return current_substring


if __name__ == "__main__":
    given = "alamakota"
    print(f"{given} and its reversed: {reverse(given)}")

    given = "pwwkew"
    print(f"Longest unique substring of {given} is {longest_unique_substring(given)}")

    iterate(["ala", "ma", "kota"])
    iterateold(("ala", "ma", "kota"))  # using tuple
    iterateargs("ala", "has", "cat")

    iteratekwargs(ala="ma", kota="wielkiego")
    iteratekwargs(**{"ala": "ma", "kota": "wiekiego"})  # pass dict as kwargs agument
