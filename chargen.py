#!/usr/bin/env python
from random import randrange

import click


def rollstat():
    return sum((randrange(6)+1 for x in range(3)))


def rollstats():
    return [rollstat() for stat in range(6)]


def evalstats(stats):
    pass


def printstats(stats):
    click.echo('STR:{:>3} INT:{:>3} WIS:{:>3} DEX:{:>3} CON:{:>3} CHA:{:>3}'.format(*stats))
    evalstats(stats)
    click.echo('')


@click.command()
@click.option('-c', '--count', default=1, help='Number of characters.')
def generate(count):
    """Character roller for ACKS."""
    for x in range(count):
        stats = rollstats()
        printstats(stats)

if __name__ == '__main__':
    generate()
