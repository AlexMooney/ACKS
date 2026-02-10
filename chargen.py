#!/usr/bin/env python
from random import randint
import random
from datetime import datetime

import click

STR = 0
INT = 1
WIL = 2
DEX = 3
CON = 4
CHA = 5

STATS = ['STR', 'INT', 'WIL', 'DEX', 'CON', 'CHA']


def rollstat(opts, stat):
    if stat.lower() in opts['primaries']:
        rolls = sorted([randint(1, 6) for x in range(5)])
        return max(sum(rolls[2:]), 13)
    elif stat.lower() in opts['boosts']:
        rolls = sorted([randint(1, 6) for x in range(4)])
        return max(sum(rolls[1:]), 9)
    elif opts['heroic']:
        rolls = sorted([randint(1, 6) for x in range(4)])
        return sum(rolls[1:])
    else:
        return sum((randint(1, 6) for x in range(3)))


def rollstats(opts):
    return [rollstat(opts, stat) for stat in STATS]


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


def stat_colors(stat, opts):
    if opts['color']:
        return {-3: 'magenta',
                -2: 'red',
                -1: 'yellow',
                0: 'white',
                1: 'green',
                2: 'blue',
                3: 'cyan'
                }[stat_level(stat)]
    return ''


def printstats(stats, opts):
    for i, stat in enumerate(stats):
        click.echo(click.style('{}:{:>3}  '.format(STATS[i], stat),
                               fg=stat_colors(stat, opts)),
                   nl=False)
    if opts['gold']:
        click.echo('Gold:{:>3}  '.format(rollstat(opts, "gold")*10))
    else:
        click.echo('')


@click.command()
@click.option('-n', '--number', default=5, help='Number of characters (default 5).')
@click.option('--no-color', is_flag=True, help='Do not use color to print.')
@click.option('--no-sort', is_flag=True, help='Do not sort the characters by total stats.')
@click.option('--no-gold', is_flag=True, help='Do not roll for gold.')
@click.option('--heroic', is_flag=True, help='Generate stats by 4d6 dropping the lowest.')
@click.option('-p', '--primaries', default=None, help='Primary attributes (comma delimited) via rolling 5d6 min 13.')
@click.option('-b', '--boosts', default=None, help='Boost attributes (comma delimited) via rolling 4d6 min 9.')
@click.option('--seed', default=None, help='Override the RNG seed.')
def generate(number, no_color, no_sort, no_gold, heroic, primaries, boosts, seed):
    """Character generator for ACKS."""
    opts = {
        'number': number,
        'color': not no_color,
        'sort': not no_sort,
        'gold': not no_gold,
        'heroic': heroic,
        'seed': seed,
        'primaries': [stat.lower() for stat in primaries.split(',')] if primaries else [],
        'boosts': [stat.lower() for stat in boosts.split(',')] if boosts else [],
    }
    if any([p for p in opts['primaries'] if p.upper() not in STATS]):
        raise click.BadParameter(f'Invalid primary attribute(s): {opts["primaries"]}')
    if any([b for b in opts['boosts'] if b.upper() not in STATS]):
        raise click.BadParameter(f'Invalid boost attribute(s): {opts["boosts"]}')

    if seed is None:
        time = datetime.now()
        seed = str(time.hour*10000 + time.minute*100 + time.second)
    random.seed(seed)

    statss = [rollstats(opts) for i in range(number)]
    if opts['sort']:
        statss = sorted(statss, key=lambda arr: -sum(arr))
    for stats in statss:
        printstats(stats, opts)
    click.echo('\nSeed: {}'.format(seed))


if __name__ == '__main__':
    generate()
