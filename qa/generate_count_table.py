#!/usr/bin/env python3
"""Check/reproduce the finite low-ten-bit cardinality lookup (no runtime dependency)."""
import argparse,pathlib
if __package__:
    from .checks import require
else:
    from checks import require
p=argparse.ArgumentParser();p.add_argument('--check',action='store_true');a=p.parse_args()
text='def count_index(index: U32) -> U32:\n  match index:\n'
text+=''.join(f'    case {i}:\n      {sum((i >> bit) & 1 for bit in range(10))}\n' for i in range(1024))
text+='    case _:\n      0\n'
if a.check:
 s=(pathlib.Path(__file__).resolve().parents[1]/'sudoku/candidates.bend').read_text()
 actual=s[s.index('def count_index('):s.index('\ndef mask_count(')].strip()+'\n'
 require(actual==text, 'Generated count table differs from independently computed ten-bit cardinalities')
 print('PASS all1024 generated lookup entries match independent ten-bit sums')
else:
 print(text,end='')
