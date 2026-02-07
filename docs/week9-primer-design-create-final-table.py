#!/usr/bin/env python3
# File: create_final_table.py

import pandas as pd

print("creating TABLE 4.4")

##### load enhanced primer data
primer_file = "primer_pairs_with_copy_numbers.csv"
primers = pd.read_csv(primer_file)

##### create final table matching dissertation format
final_table = primers.head(5).copy()
final_table["rank"] = range(1, 6)
final_table["target_id"] = final_table["sequence_id"].str.replace(r"_len.*", "", regex=True)

##### reorder columns to match Table 4.4
table_4_4 = final_table[
    [
        "rank",
        "target_id",
        "repeat_family",
        "amplicon_length",
        "expected_copy_number",
        "forward_primer",
        "reverse_primer",
        "dimer_risk",
        "final_score",
        "sensitivity_rank",
    ]
].copy()

table_4_4.columns = [
    "Rank",
    "Target ID",
    "Repeat Family",
    "Amplicon (bp)",
    "Expected Copy Number",
    "Forward Primer",
    "Reverse Primer",
    "Dimer Risk",
    "Final Score",
    "Sensitivity Rank",
]

##### save final table
table_4_4.to_csv("../../week9_tables/table_4_4_final_primers.csv", index=False)

print("table 4.4 created")
print(table_4_4.to_string(index=False))
