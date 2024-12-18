#!/usr/bin/env python

# example usage:
"""
./scoreboard.py \
| awk -F@ '$3 ~ /Open/ && $4 ~ /Platinum/ { print $1, $2 " " $3 " " $4, $5, $6 " " $7 " " $8 }' OFS=$'\t' \
| awk '{ print NR " - " $0 }' \
| less
"""

import requests, sys
from typing import TextIO
from bs4 import BeautifulSoup

def write_scoreboard(
    soup: BeautifulSoup, file: TextIO, col_delim: str = "|", row_delim: str = "\n"
) -> None:
    scores_table = soup.find("table")
    file.write(
        col_delim.join(
            [
                "#team",
                "location",
                "division",
                "tier",
                "scored images",
                "play time",
                "codes",
                "score",
            ]
        )
    )
    
    if scores_table is None: return
    for table_row in scores_table.findAll("tr", class_="clickable"):
        _, *tr_text = map(lambda c: c.text, table_row.contents)
        file.write(row_delim + col_delim.join(tr_text))
    
    file.write("\n")

try:
    if len(sys.argv) == 1 or sys.argv[1] == "-":
        file = sys.stdout
    else:
        file = open(" ".join(sys.argv[1:]), "w")
    
    resp = requests.get("http://scoreboard.uscyberpatriot.org/")
    soup = BeautifulSoup(resp.text, "lxml")

    write_scoreboard(soup, file, col_delim = "@")
finally:
    if file: file.close()
