import sys
from Search import *


def main():
    if len(sys.argv) != 4:
        print("invalid arguments count")
        return
    if not sys.argv[3].endswith(".txt"):
        print("invalid file extension")
        return

    try:

        if sys.argv[1] == "FA":
            search = FiniteAutomation(sys.argv[2], sys.argv[3])
        elif sys.argv[1] == "KMP":
            search = KnuthMorrisPratt(sys.argv[2], sys.argv[3])
        else:
            print("invalid search type")
            return

        search.execute()
    except FileNotFoundError:
        print("File doesn't exist")


if __name__ == "__main__":
    main()
