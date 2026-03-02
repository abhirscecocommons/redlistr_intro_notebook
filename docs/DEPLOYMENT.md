# Deployment Artifacts

Generated on 2026-03-01.

## Files
- `docs/index.html` (published landing page)
- `docs/Intro_to_redlistRpackipynb.executed.html` (full rendered notebook)
- `docs/Intro_to_redlistRpackipynb.executed.ipynb` (executed notebook output)

## Rebuild steps
1. Execute notebook:
   `jupyter nbconvert --to notebook --execute Intro_to_redlistRpackipynb.ipynb --output /tmp/Intro_to_redlistRpackipynb.executed.ipynb --ExecutePreprocessor.timeout=180`
2. Render HTML:
   `jupyter nbconvert --to html /tmp/Intro_to_redlistRpackipynb.executed.ipynb --output Intro_to_redlistRpackipynb.executed.html --output-dir docs`
3. Publish index:
   `cp docs/Intro_to_redlistRpackipynb.executed.html docs/index.html`

Notes:
- Without `IUCN_REDLIST_KEY`, API cells are skipped with informative messages.
- Set `IUCN_REDLIST_KEY` to get fully populated live API outputs.
