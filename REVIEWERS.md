# CAROB REVIEWERS KNOWLEDGE BASE

## Main Reviewer: Robert Hijmans (rhijmans)
## Secondary Reviewer: Cedric Ngakou Sotakoutsing (cedricngakou)
## Coordinator: Oscar Bau (oscarbau)

Last updated: 2026-10-16

---

## TOP 20 RECURRING MISTAKES

1. Relying too much on AI
   Quote: "You are relying too much on AI. You need to check each row."
   PRs: #1110, #1111, #1129
   Fix: Review every line manually.

2. Adding "per plot" variables
   Quote: "You are adding variables of no interest (per plot)."
   Fix: Stick to terminag variables only.

3. Renaming columns
   Quote: "Do not rename columns like this. Can only lead to errors."
   PR: #1159
   Fix: Use actual column names directly.

4. Averaging categorical scores
   Quote: "Calculating the row mean may not make sense (categorical)."
   Reviewer: Cedric
   PR: #1164
   Fix: No rowMeans() on categorical scores.

5. Dividing all values to fix outliers
   Quote: "You went from a few questionable numbers, to getting them all wrong."
   PR: #1165
   Fix: Fix only wrong values.

6. Variables not from terminag
   Quote: "Use yield, marketable_yield, yield_moisture..."
   PR: #1129
   Fix: Use exact terminag names.

7. Missing longitude/latitude
   Quote: "you need to provide longitude/latitude"
   Fix: Every site needs coordinates.

8. Undocumented variables
   Quote: "describe what new variables represent, what their units are"
   Fix: Document every new variable with unit.

9. Wrong variety lookup
   Quote: "varieties_lookup was not entirely correct" - PR #1183
   Quote: "variety lookup missed the three control varieties" - PR #1181
   Fix: Check every line manually.

10. Aggregation loses information
    Quote: "aggregate over evaluators" - PR #1161
    Fix: Use long format.

11. meta <- formatting
    Quote: "fix the meta <- part formatting" - PR #1156
    Quote: "avoid exaggerated indentation" - PR #1161

12. Multiple files in one PR
    Quote: "There were three files. None were accepted."
    PR: #1103
    Fix: One file = one PR.

13. Wrong group
    Quote: "should be under varieties_potato, not agronomy"
    PR: #1103
    Fix: Verify correct group.

14. Read AGENTS.md
    Quote: "your agent reads AGENTS.md before doing any work"
    PR: #1103

15. Redundant info
    Quote: "no need to add the same information to each data.frame"
    PR: #1185

16. Rejected scripts
    Quote: "model predictions, not field observations" - PR #1179
    Quote: "I am going to reject this one" - PR #1176

17. Out of scope
    Quote: "not an agronomy trial survey. Limit the scope."
    Reviewer: Oscar, PR #1177

18. Dead code
    Quote: "These did nothing: d$fries_color[is.nan(...)] <- NA"
    PR: #1159
    Fix: Every line must do something.

19. Repeating same mistakes
    Quote: "I keep making the same edits. Please look at my edits."
    PR: #1149

20. on_farm = FALSE vs NA
    Quote: "Are you sure about on_farm = FALSE? Or should that be NA?"
    PR: #1164
    Fix: Use NA if uncertain.

21. Making values up with pmin()/capping
    Quote: "Do not use x <- pmin(x, y). Then you are just making things up."
    PR: #1215 (BW8LWJ, AUDPC)
    Fix: Out-of-range values usually mean a units problem; investigate, never cap.

22. Treatment not recorded as a variable
    Quote: "trial_type is not a useful variable ... use a variable that expresses that such as fungicide_used"
    PR: #1215
    Fix: Express the actual treatment (fungicide_used TRUE/FALSE) and list it in treatment_vars.

23. Ignoring existing terms / earlier edits
    Quote: "we already have variables for flavor and texture ... check the edits to your scripts, and check terminag"
    PR: #1156
    Fix: Check terminag and reviewer's commits on earlier PRs first.

24. Wrong name for glycoalkaloid content
    Quote (Cedric): capture it as tubers_glycoalkaloid
    PR: #1181

25. Editing / summarizing the description
    Quote: "Do not edit the description at the top of the script. It should be exactly what carobiner::draft creates."
    Fix: Keep draft() description verbatim; notes = NA unless real processing issues.

26. Formatting bloat
    Quote: "Do not use multiple lines of code where one suffices." / "Reduce the number of empty lines"
    Fix: Compact code; no unnecessary as.character(); no suppressWarnings().

27. Dry matter and densities
    Quote: "use these values to compute yield_moisture" / "terminag has seed_density ... and plant_density"
    Fix: yield_moisture <- 100 - dry_matter (oven method preferred); per-plot counts -> seed_density / plant_density.

Full details and verbatim quotes: carob_rhijmans_guide.md

---

## GOLDEN RULES

1. CHECK EVERY LINE MANUALLY
2. ONE FILE = ONE PR
3. USE EXACT TERMINAG NAMES
4. NO "PER PLOT" VARIABLES
5. NO COLUMN RENAMING
6. NO rowMeans() ON CATEGORICAL
7. PROVIDE LONGITUDE/LATITUDE
8. DOCUMENT EVERY NEW VARIABLE
9. USE LONG FORMAT for repeated measures
10. READ AGENTS.md FIRST
11. CLEAN meta <- FORMATTING
12. DO NOT DIVIDE ALL VALUES
13. CONTROL = 0, NOT NA
14. CHECK VARIETY LOOKUP MANUALLY
15. EVERY LINE MUST DO SOMETHING
16. NEVER CAP / RESCALE VALUES (no pmin, no dividing all) — CHECK UNITS
17. EXPRESS EVERY TREATMENT AS ITS OWN VARIABLE (e.g. fungicide_used)
18. KEEP draft() DESCRIPTION VERBATIM; notes = NA IF NOTHING SPECIFIC
19. COMPACT CODE: one line where one suffices, few empty lines, no needless coercion
20. STUDY REVIEWER COMMITS ON MERGED PRs AND APPLY THEM NEXT TIME

---

## PRs HISTORY

| PR | DOI | Status | Issue |
|----|-----|--------|-------|
| #1215 | BW8LWJ | Merged | pmin made-up values; trial_type -> fungicide_used |
| #1185 | E1GOGT | Merged | Redundant info |
| #1183 | FO7KPO | Merged | Variety lookup |
| #1184 | 2D2NAV | Merged | Variety handling |
| #1179 | ASVUIG | Rejected | Model predictions |
| #1177 | OMOIO4 | Out of scope | Not agronomy |
| #1176 | 5O3NT5 | Rejected | - |
| #1175 | G3JK72 | Merged | - |
| #1173 | HDAREL | Merged | - |
| #1181 | 5TQSRM | Merged | Missing controls |
| #1156 | RKTBNX | Merged | meta formatting |
| #1161 | F6ZZJH | Merged | Aggregation |
| #1159 | ZTPO9T | Merged | Renaming, dead code |
| #1164 | FF5CZT | Merged | rowMeans on categories |
| #1165 | P3_RVCHKV | Merged | Dividing all yields |
| #1103 | FBZ6JS | Not accepted | Multiple files |
| #1111 | MXKUIK | - | Per-plot vars |
| #1110 | FBZ6JS | - | Per-plot vars |
| #1119 | MXKUIK | Closed | - |
| #1129 | MXKUIK | Merged | Wrong variables |
| #1149 | P3_RWIMFO | Merged | Repeating edits |

