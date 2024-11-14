[![Linter](https://github.com/Sebastian2852/ManicMines/actions/workflows/Lint.yml/badge.svg?event=push)](https://github.com/Sebastian2852/ManicMines/actions/workflows/Lint.yml)

# Manic Mines
The source code for the Manic Mines Roblox game. This repo only holds code for versions after the recode update.

## Building
To use start using this repo you need to have [Git](https://git-scm.com/), [Aftman](https://github.com/LPGhatguy/aftman) and [Wally](https://wally.run/) installed.

To setup the coding environment start by cloning the repo using the command:  
```git clone https://github.com/Sebastian2852/ManicMines```  
This will automatically download the latest version of the game *(Note that this downloads the latest DEV version meaning it may contain code not actually in prod).*  

*Note: You can add `-b [BRANCH NAME]` to clone a branch. e.g. ``git clone -b Dev https://github.com/Sebastian2852/ManicMines```*  

Then install all the packages by running  
`wally install`  
in the project's **root directory**.  

## Branches
- The public game is on the `Game` branch. This branch is only updated when the game releases an update.
- The main development branch is the `Dev` branch. It contains the latest stable code being actively worked on.

Feature work, bug fixes, and improvements are created in separate branches and merged into `Dev` once completed. Here is the branch naming scheme:

- `Feature/`: New features
- `BugFix/`: Bug fixes
- `Improvement/`: Reworks or improvements to existing systems
- `Hotfix/`: Urgent fixes for critical issues
- `Chore/`: Refactoring, documentation, or minor updates
- `Experiment/`: Experimental features or ideas


---

> bob was here  
> \- bob
