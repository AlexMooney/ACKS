### ACKS character generator

This is a simple command line tool to roll characters for the [ACKS](http://www.autarch.co/) RPG.
By default, it rolls 5 characters, sorts them by the sum of the ability scores, and displays the stats and the classes that are eligible.
Classes from the Player's Companion appear on a line below the classes from the core book.
The color code corresponds to ability score bonuses and class experience adjustments.

### Setup and Usage

1. Clone or download the repo.
2. Run `setup.sh` to build a virtual environment and install [Click](http://click.pocoo.org/6/).
3. Activate the virtual environment with `. ./venv/bin/activate` (if you are within the directory).
4. Run `chargen.py` to generate 5 characters, or run it with the `--help` flag to see the options.

After the initial setup, only steps 3 and 4 are required to run it again.

### Copyright information

ACKS is Copyright (c) 2011-2017 Autarch LLC.

