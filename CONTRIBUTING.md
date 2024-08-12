# How to Contribute

## TLDR

1. Any work you do should be done in a branch or fork. When you're ready to submit your work, open a pull request. The pull request should be reviewed by at least one other person before it is merged.
   1. Don't merge your own pull requests. This is done by the reviewer.
2. Be sure to download and USE `pre-commit` to ensure your code is formatted correctly.
3. Be sure to follow the [Conventional Commits](https://github.com/conventional-changelog/commitlint) standard for your commit messages.
4. Be sure to follow the [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) standard for your changelog entries.
5. Be sure to sign your commits and tags with cert recognized and verified by GitHub.
6. Don't create tags or releases. This is done automatically by the CI/CD pipeline.
7. Any work you do on this project is understood to be under the terms of the [AGPL](./LICENSE). You are free to use this project as you see fit, but you must contribute back any changes you make to this project.

## Getting Started

1. `make install` to download all the basic stuff
2. `npm i -D conventional-changelog-atom` to install commitlint dependencies
3. `pip install pre-commit` to install pre-commit
4. `pre-commit install --install-hooks` to install pre-commit hooks
