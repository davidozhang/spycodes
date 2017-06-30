#/usr/bin/python
from __future__ import print_function

# Output is directly copy-able to SCWordBank.swift
def print_sorted_deduped_list(collection):
    print('[', end='')
    s = sorted(list(set(collection)))
    l = len(s)
    for e, word in enumerate(s):
        print('"{}"'.format(word), end='')
        if e == l - 1:
            print(']', end='\n')
        else:
            print(', ', end='')

def main():
    l = []  # insert list here
    print_sorted_deduped_list(l)

if __name__ == '__main__':
    main()
