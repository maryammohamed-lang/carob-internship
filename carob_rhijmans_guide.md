# Carob Guide — Reference from rhijmans (and other reviewer) comments

Compiled from reviewer comments on Carob pull requests (Robert Hijmans, Cedric Ngakou Sotakoutsing, Oscar Bau).
Last updated: 2026-10-16. See also `AGENTS.md`, `REVIEWERS.md`, `CAROB_GUIDELINES.md`.

---

## Part 1: Style and code formatting

- Use one line of code when one line suffices. Write `d <- carobiner::bindr(r1, r2, r3, r4, r5)`, not one argument per line.
- Never use `suppressWarnings()`. Write `as.numeric(d$MTYA)`; if that warns, first fix the underlying values in `d$MTYA`.
- Reduce empty lines: only between sections, not between almost every line of code.
- Remove unnecessary coercions (`as.character()` on a variable that is already character, etc.).
- Pay attention to the first line of `meta <-`; keep it compact, no exaggerated indentation below it.
- Do not rename columns (e.g. `names(r1) <- c("Clone", "Repetition", ...)`). There is no need, and it can only lead to errors. Use the original column names directly.
- Every line must actually do something. Example of dead code removed by the reviewer:
  `d$fries_color[is.nan(d$fries_color)] <- NA`, `d$fries_texture[is.nan(d$fries_texture)] <- NA`, `d <- d[!is.na(d$variety), ]`.

## Part 2: Metadata and description

- Do not edit the description at the top of the script. It should be exactly what `carobiner::draft` creates. You may add to it, but do not reduce or summarize it.
- `notes` is for specific information or issues found while processing. Do not copy the dataset description into `notes`. If nothing specific, use `notes = NA`.
- `on_farm = FALSE` vs `NA`: if you are not sure, use `NA` (PR #1164).

## Part 3: Variables — what to keep and what to remove

- No "per plot" variables: they are not comparable between experiments. Express them per ha with terminag variables. Remove things like `tubers_planted_plot_`, `plants_emerged_plot_`, `marketable_tubers_plot_`, `marketable_tuber_weight_plot_`.
- "Per plant" variables are also suspect: express per ha (they can be derived back with plant density).
- Use terminag `seed_density` (tubers planted per ha) and `plant_density` (plants that survived per ha).
- Do not use names like `marketable_yield_raw_`, `total_yield_raw_`, `total_yield_adjusted_`, `dm_oven_`. Use `yield`, `yield_marketable`/`marketable_yield` (check terminag for the exact name), `yield_moisture`.
- Compute yield where it is missing (e.g. from plot weight and plot area).
- One variable per measurement: a single `flavor_baked` and a single `texture_baked`, not `flavor_baked_1_`, `_2_`, `_3_`. Existing terms for flavor and texture already exist in terminag — check terminag and the reviewer's edits to earlier scripts before inventing new ones (PR #1156).
- Replicate samples of the same trait (e.g. `Color sample1`, `Color sample2`) → one variable (`fries_color`, new `fries_texture`) (PR #1159). BUT be careful: if the values are categorical scores (e.g. 1–5 color classes), `rowMeans()` may not make sense (Cedric, PR #1164). Flag the question rather than silently averaging categories.
- Multiple evaluators: the reviewer aggregated over evaluators in PR #1161 — read his comments on aggregation before deciding; keep the information needed for the analysis.
- Dry matter: do not store `dry_matter` as such; use it to compute `yield_moisture <- 100 - r1$"DM_Oven_drying_ method"`. If there are hydrometer and oven methods, prefer oven.
- Glycoalkaloid content in tubers → `tubers_glycoalkaloid` (Cedric, PR #1181).
- New variables are allowed when no terminag term exists, but add a comment explaining the meaning and unit.
- Standardize directly when creating `d` — do not copy all raw variables into `d` and then run a big standardization section.

## Part 4: Values and treatments

- Never make values up. Do not use `x <- pmin(x, y)` to cap values: "Then you are just making things up." If values look out of range (e.g. AUDPC), the problem is probably units — investigate (PR #1215).
- Never divide all values to fix a few outliers. "You went from a few questionable numbers, to getting them all wrong." (PR #1165)
- Treatments must be recorded as interpretable variables. In BW8LWJ, `trial_type` (`phenotypic_stability`, `with_LB_control`, `without_LB_control`) was "obviously important, but not recorded", and then "trial_type is not a useful variable. Some treatments have LB control, others not, so you need to use a variable that expresses that such as `fungicide_used`" (PR #1215). Put such variables in `treatment_vars`.
- Variety lookups: check every line manually for unexpected `NA`. A lookup missed the three control varieties (PR #1181); another "was not entirely correct" (PR #1183).
- No need to add the same information to each data.frame (PR #1185) — set common values once (e.g. after binding).

## Part 5: Geography

- Always provide longitude and latitude. Fill them from the source data or the dataset description/publication.

## Part 6: Scope, rejection

- Model predictions are not field observations → `_rejected` (PR #1179, ASVUIG).
- QTL summary data → rejected (PR #1176, 5O3NT5).
- Out of scope: a nutrition bar / anemia survey is not an agronomy trial or survey. Limit work to relevant datasets (Oscar, PR #1177, OMOIO4).

## Part 7: PR process and workflow

- One dataset per pull request. If a PR has multiple files, none are accepted (PR #1103).
- Use a separate git branch per dataset to work on several PRs at once.
- Choose the right group: potato variety trials go in `varieties_potato`, not `agronomy`.
- When using AI, make sure the agent reads `AGENTS.md` first.
- "You are relying too much on AI. You need to check each row and improve it." Check every row of code and comments manually.
- "I keep making the same edits." Study the reviewer's commits on your merged PRs (computed yield, density variables, added variables, compact code, removed coercions) and apply them yourself next time.

## Part 8: Process for each PR

1. Read `AGENTS.md`.
2. Create a separate branch for the dataset.
3. Write the script (one dataset).
4. Check every row of code and comments manually.
5. Use terminag variables where possible.
6. Describe new variables (name, meaning, unit).
7. Convert per plot / per plant to per ha.
8. No `suppressWarnings()`; fix the data.
9. No unnecessary `as.character()`.
10. Keep the description exactly as `carobiner::draft` creates it.
11. `notes = NA` if no processing issues.
12. Provide latitude and longitude.
13. Standardize directly when creating `d`.
14. Submit one PR.
15. Study the reviewer's edits.
16. Apply those edits in future PRs.

## Part 9: Variable naming quick reference

Good: `yield`, `yield_marketable`, `yield_moisture`, `seed_density`, `plant_density`, `variety`, `fries_color`, `flavor_baked`, `texture_baked`, `tubers_glycoalkaloid`, `fungicide_used`.

Bad: `marketable_yield_raw_`, `total_yield_raw_`, `total_yield_adjusted_`, `dm_oven_`, `dm_hydrometer_`, `tubers_planted_plot_`, `plants_emerged_plot_`, `marketable_tubers_plot_`, `flavor_baked_1_`, `texture_baked_1_`, `trial_type`.

(Always confirm exact names against the current terminag cache.)

## Part 10: rhijmans quotes (verbatim)

- "Do not use multiple lines of code where one suffices."
- "Do not use suppressWarnings. If that gives a warning, first fix d$MTYA."
- "Reduce the number of empty lines, only use them between sections, not between almost every line of code."
- "We do not keep 'per plot' variables, as they are not comparable between experiments. They need to be expressed as 'per ha' and there are terminag variables for that."
- "'per plant' is also suspect in this case as it could also be expressed per ha."
- "terminag has seed_density for the number of tubers that were planted per ha and plant_density for the number of plants that survived."
- "We accept one dataset per pull request."
- "Note that you can make multiple simultaneous, independent PRs by using a separate git branch for each dataset."
- "There were three files in this PR. None of them were accepted. Please provide them again, one by one, in separate PRs. At least some of them should be under 'varieties_potato', not 'agronomy'."
- "Since you are using AI, make sure that your agent reads 'AGENTS.md' in the root of this repo before doing any work."
- "You are relying too much on AI. You need to check each row and improve it."
- "The below are not good variables. Use yield, marketable_yield, yield_moisture."
- "flavor_baked should be single computed variable, same for texture_baked."
- "Instead of dry_matter, use these values to compute yield_moisture. Presumably something like yield_moisture <- 100 - r1$'DM_Oven_drying_ method'."
- "Please note the first line of meta <- and do not add as.character and the like if there is no need for it."
- "Do not edit the description at the top of the script. It should be exactly what carobiner::draft creates. You can add more, but you should not reduce or summarize the description."
- "Thank you, but I keep making the same edits. Can you please carefully look at my edits to your scripts and make these yourself in future?"
- "Please carefully study the changes I made, including computed yield where missing, standardized to density variables, added additional variables, made the code more compact, removed unnecessary coercions."
- "You are adding variables of no interest like 'per plot'. You need to provide longitude and latitude. You need to describe what new variables represent and what their units are."
- "dm_hydrometer_ and dm_oven_ presumably are two ways to measure dry matter of what? And the oven method would be preferable."
- "Do not use x <- pmin(x, y). Then you are just making things up. In this case with AUPDC, I think, the problem is one of units." (PR #1215)
- "trial_type is not a useful variable. Some treatments have LB control, others not, so you need to use a variable that expresses that such as fungicide_used" (PR #1215)
- "That is fine, but no need to add the same information to each data.frame" (PR #1185)
- "varieties_lookup was not entirely correct" (PR #1183)
- "The variety lookup missed the three control varieties. You need to manually check each line to see if it produces missing values (NA) where that is not expected." (PR #1181)
- "Moved to '_rejected' as these are model predictions, not field observations." (PR #1179)
- "please fix the meta <- part formatting, and we already have variables for flavor and texture (introduced in one of your previous scripts --- check the edits to your scripts, and check terminag." (PR #1156)
- "Please have a look at my thoughts about aggregation. And please avoid the exaggerated indentation under the meta <- line." (PR #1161)
- "do not rename columns like this. There is no need for it, and can only lead to errors." (PR #1159)
- "please check every line of code to make sure it actually does something." (PR #1159)
- "Are you sure about on_farm = FALSE, Or should that be NA?" (PR #1164)
- "It also had a really bad mistake: dividing all yields by 10 because there were some high outliers. You went from a few questionable numbers, to getting them all wrong." (PR #1165)

Other reviewers:
- Cedric (PR #1164): "calculating the row mean may not make sense, because the values are categorical scores rather than continuous measurements."
- Cedric (PR #1181): capture glycoalkaloid content as `tubers_glycoalkaloid`.
- Oscar (PR #1177): "This is not an agronomy trial survey, or similar study. Please limit the scope of work to relevant datasets."

## Final notes

AGENTS.md first. One dataset = one PR = one branch. terminag names over custom names. Per ha, never per plot or per plant. Never make up or rescale values to hide problems. Check every row manually. Study the reviewer's edits and apply them next time.
