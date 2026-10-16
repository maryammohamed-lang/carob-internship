# My merged scripts — reference examples and known problems

Checked 2026-10-16 against `carob-data/carob` main (`scripts/varieties_potato/`).
They were accepted, but merged does not mean perfect. Use them for structure (metadata, geo lookup, long table for LB readings), NOT as proof that every line is right.

## doi:10.21223/B7HWWH — LBHTC2 intermediate trials (genomic selection LB)
Good pattern: 3 site files bound, hard-coded geo + planting/harvest dates per site, LB1–LB8 reshaped into a long table with `DAP` and `date`, `write_files(..., long = d_long)`.
Problems still in main:
- `f5` is `"02_LBHTC2-HUANCAYO 2020-2021_data.xlsx"` but labelled `Huanuco` — check whether file 02 really is Huanuco (file name says Huancayo).
- `d$yield[d$yield == 574494.255] <- 5744.94255` — single-value typo fix; must have a comment explaining why (and leave it visible in `## ISSUES`).
- Description says 7 evaluations (35–85 DAP) but the script uses 8 columns (LB1–LB8). Verify the DAP times.
- Dead / leftover lines: `#  names(r) <- trimws(names(r))`, `# mine has a space before the extension`.
- `r$record_id <- ...` modifies `r`; could be set on `d` instead.
- Description says the analysis gives BLUPs — confirm the files hold plot observations, not predictions (cf. ASVUIG rejected).

## doi:10.21223/P3/9VMENB — B3C2 clones, Oxapampa
Good pattern: dates read from each `.xls` "Minimal" sheet; LB readings to long table with `disease = "potato late blight"`.
Problems still in main:
- **`yield_moisture = r$avdm` is wrong.** Data dictionary: AVDM = "Percent dry matter content of tubers" (values ~17–23). Must be `yield_moisture = 100 - r$avdm`.
- `names(x) <- tolower(names(x))` — column renaming (reviewer: "do not rename columns").
- `write_files(path, meta, d, d_long)` — pass as `long = d_long` explicitly.
- `texture_fries_` — check terminag for an existing texture term (cf. `fries_texture`, PR #1156).
- `N/P/K_fertilizer = NA` — check the data for management info before leaving NA.

## doi:10.21223/FF5CZT — French fries quality 2019–2020
Problems still in main (both flagged by reviewers, not changed):
- `rowMeans()` on categorical color/texture scores (Cedric, #1164).
- `on_farm = FALSE, # or NA?` — reviewer asked whether it should be NA (#1164). Leaving a question in code is not a decision.
- `r$Color1 <- as.numeric(...)` adds columns to `r`; do the coercion inside `data.frame()`.
- Same `na=` vector repeated 5 times — define once.
- `yield_part = "tubers"` with `yield = NA` — fine, but no lab samples' field yields are available.

## doi:10.21223/BW8LWJ — LB-resistant clones, stability (PR #1215)
After reviewer edit, `trial_type` was replaced by `treatment` + `fungicide_used`. Problems still in main:
- **`trial_id = paste0("BW8LWJ_", r$trial_label, "_", r$Site)` — `trial_label` no longer exists**, so `trial_id` no longer separates the with/without LB control trials at the same site.
- `fungicide_used` is the real treatment but is not in `treatment_vars` (should be `"variety;fungicide_used"`).
- `fungicide_used` is set on `r1/r2/r3` (changing `r`) instead of being derived in `d`.
- `planting_date = "2021"` / `harvest_date = "2022"` — the abstract says 2021–2022 campaign; check data for real dates.

## Lessons to apply next time
1. After a merge, diff your version against main to see exactly what the reviewer changed.
2. Read the data dictionary for every variable (`avdm` = dry matter → moisture = 100 − DM).
3. When the reviewer renames/removes a variable, check every line that used it (`trial_label`).
4. Put the actual treatment in `treatment_vars`, not just in `d`.
5. Don't leave questions like `# or NA?` in code — decide, or put it in `## ISSUES`.
