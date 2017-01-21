#!/usr/bin/env python
from random import randrange

import click

STR = 0
INT = 1
WIS = 2
DEX = 3
CON = 4
CHA = 5

STATS = ['STR', 'INT', 'WIS', 'DEX', 'CON', 'CHA']


def rollstat():
    return sum((randrange(6)+1 for x in range(3)))


def rollstats():
    return [rollstat() for stat in range(6)]


def stat_level(stat):
    if stat > 17:
        return 3
    elif stat > 15:
        return 2
    elif stat > 12:
        return 1
    elif stat > 8:
        return 0
    elif stat > 5:
        return -1
    elif stat > 3:
        return -2
    return -3


def stat_colors(stat, color=True):
    if color:
        return {-3: 'magenta',
                -2: 'red',
                -1: 'yellow',
                0: 'white',
                1: 'green',
                2: 'blue',
                3: 'cyan'
                }[stat_level(stat)]
    return ''


def evalstats(stats, showall, color):
    classes = [
        {'name': 'Fighter', 'primes': [STR], 'reqs': []},
        {'name': 'Mage', 'primes': [INT], 'reqs': []},
        {'name': 'Cleric', 'primes': [WIS], 'reqs': []},
        {'name': 'Thief', 'primes': [DEX], 'reqs': []},
        {'name': 'Assassin', 'primes': [STR, DEX], 'reqs': []},
        {'name': 'Bard', 'primes': [CHA, DEX], 'reqs': []},
        {'name': 'Bladedancer', 'primes': [WIS, DEX], 'reqs': []},
        {'name': 'Explorer', 'primes': [STR, DEX], 'reqs': []},
        {'name': 'Vaultguard', 'primes': [STR], 'reqs': [(CON, 9)]},
        {'name': 'Craftpriest', 'primes': [WIS], 'reqs': [(CON, 9)]},
        {'name': 'Spellsword', 'primes': [STR, INT], 'reqs': []},
        {'name': 'Nightblade', 'primes': [DEX, INT], 'reqs': []},
        {},
        {'name': 'Anti-paladin', 'primes': [STR, CHA], 'reqs': []},
        {'name': 'Barbarian', 'primes': [STR, CON], 'reqs': []},
        {'name': 'Delver', 'primes': [DEX], 'reqs': [(CON, 9)]},
        {'name': 'Fury', 'primes': [STR], 'reqs': [(CON, 9)]},
        {'name': 'Machinist', 'primes': [INT, DEX], 'reqs': [(CON, 9)]},
        {'name': 'Courtier', 'primes': [INT, CHA], 'reqs': [(INT, 9)]},
        {'name': 'Enchanter', 'primes': [INT, CHA], 'reqs': [(INT, 9)]},
        {'name': 'Ranger', 'primes': [STR, DEX], 'reqs': [(INT, 9)]},
        {'name': 'Trickster', 'primes': [CON, CHA], 'reqs': [(CON, 9), (INT, 9)]},
        {'name': 'Mystic', 'primes': [WIS, DEX, CON, CHA], 'reqs': []},
        {'name': 'Wonderworker', 'primes': [INT, WIS], 'reqs': [(i, 11) for i in range(6)]},
        {'name': 'Paladin', 'primes': [STR, CHA], 'reqs': []},
        {'name': 'Pristess', 'primes': [WIS, CHA], 'reqs': []},
        {'name': 'Shaman', 'primes': [WIS], 'reqs': []},
        {'name': 'Gladiator', 'primes': [STR], 'reqs': [(STR, 9), (DEX, 9), (CON, 9)]},
        {'name': 'Venturer', 'primes': [CHA], 'reqs': []},
        {'name': 'Warlock', 'primes': [INT], 'reqs': []},
        {'name': 'Witch', 'primes': [WIS, CHA], 'reqs': []},
        {'name': 'Ruinguard', 'primes': [STR, INT], 'reqs': [(INT, 9), (WIS, 9), (CHA, 9)]},
        ]
    for cls in classes:
        if cls == {}:
            click.echo('')
            continue

        prime = min((stats[prime] for prime in cls['primes']))

        fitness = stat_level(prime)

        for req in cls['reqs']:
            if stats[req[0]] < req[1]:
                fitness = -1
                prime = 3
                break

        if fitness < 0:
            if showall:
                click.echo(''.join([c+'\u0336' for c in cls['name']]) + '  ', nl=False)
        else:
            click.echo(click.style(cls['name'] + '  ', fg=stat_colors(prime, color)), nl=False)


def printstats(stats, showall, color):
    for i, stat in enumerate(stats):
        click.echo(click.style('{}:{:>3}  '.format(STATS[i], stat), fg=stat_colors(stat, color)), nl=False)
    total_level = 2*sum(stat_level(s) for s in stats) + 10
    click.echo(click.style('  Total:{:>3}'.format(sum(stats)), fg=stat_colors(total_level, color)))

    evalstats(stats, showall, color)
    click.echo('\n')


@click.command()
@click.option('-n', '--number', default=5, help='Number of characters (default 5).')
@click.option('--showall/--no-showall', default=False, help='Show classes not allowed by stats.')
@click.option('--color/--no-color', default=True, help='Show class affinities in color.')
def generate(number, showall, color):
    """Character roller for ACKS."""
    statss = sorted([rollstats() for i in range(number)], key=lambda arr: -sum(arr))
    for stats in statss:
        printstats(stats, showall, color)


if __name__ == '__main__':
    generate()
