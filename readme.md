# scholar-rename

[![Gem Version](https://badge.fury.io/rb/scholar-rename.svg)](https://badge.fury.io/rb/scholar-rename)
[![CI](https://github.com/jeremywrnr/scholar-rename/actions/workflows/ci.yml/badge.svg)](https://github.com/jeremywrnr/scholar-rename/actions/workflows/ci.yml)
[![MIT](https://img.shields.io/npm/l/alt.svg?style=flat)](http://jeremywrnr.com/mit-license)

an interactive pdf-renamer tool.

## install

    [sudo] gem install scholar-rename

you'll also need: https://en.wikipedia.org/wiki/Pdftotext

for macOS, you can install w/ brew:

    brew install pkg-config poppler

for Ubuntu:

    sudo apt-get install poppler-utils

## about

renames a pdf file to author-title-year.pdf or other formats based on your
selection. academic people may find it useful for renaming pdfs that come in
arbitrarily named file formats. it helps when searching for a specific pdf
and when labeling pdfs.

## metadata lookup

by default, scholar-rename queries the [Semantic Scholar Graph
API](https://api.semanticscholar.org/) using the extracted pdf text to
suggest an authoritative title/author/year. you'll be asked to confirm the
match (auto-accepted when using `--auto`). if there's no internet
connection, the api times out, or no match is found, scholar-rename falls
back to its original manual line-picking flow -- nothing ever crashes or
hangs waiting on the network. use `--no-lookup` to skip the network step
entirely (useful when offline, batch-renaming many files, or avoiding the
api's rate limits).

