#!/usr/bin/env python
from random import randint
import random
from datetime import datetime

import click

STR = 0
INT = 1
WIS = 2
DEX = 3
CON = 4
CHA = 5

STATS = ['STR', 'INT', 'WIS', 'DEX', 'CON', 'CHA']


def rollstat(opts):
    if opts['heroic']:
        rolls = [randint(1, 6) for x in range(4)]
        return sum(rolls) - min(rolls)
    else:
        return sum((randint(1, 6) for x in range(3)))


def rollstats(opts):
    return [rollstat(opts) for stat in range(6)]


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


def evalstats(stats, opts):
    classes = [
        {'section': 'Human Classes'},
        {'name': 'Fighter', 'primes': [STR], 'reqs': []},
        {'name': 'Mage', 'primes': [INT], 'reqs': []},
        {'name': 'Cleric', 'primes': [WIS], 'reqs': []},
        {'name': 'Thief', 'primes': [DEX], 'reqs': []},
        {'name': 'Assassin', 'primes': [STR, DEX], 'reqs': []},
        {'name': 'Bard', 'primes': [CHA, DEX], 'reqs': []},
        {'name': 'Bladedancer', 'primes': [WIS, DEX], 'reqs': []},
        {'name': 'Explorer', 'primes': [STR, DEX], 'reqs': []},
        {'name': 'Anti-paladin', 'primes': [STR, CHA], 'reqs': []},
        {'name': 'Barbarian', 'primes': [STR, CON], 'reqs': []},
        {'name': 'Mystic', 'primes': [WIS, DEX, CON, CHA], 'reqs': []},
        {'name': 'Paladin', 'primes': [STR, CHA], 'reqs': []},
        {'name': 'Pristess', 'primes': [WIS, CHA], 'reqs': []},
        {'name': 'Shaman', 'primes': [WIS], 'reqs': []},
        {'name': 'Venturer', 'primes': [CHA], 'reqs': []},
        {'name': 'Warlock', 'primes': [INT], 'reqs': []},
        {'name': 'Witch', 'primes': [WIS, CHA], 'reqs': []},
        {'section': 'Dwarven Classes'},
        {'name': 'Vaultguard', 'primes': [STR], 'reqs': [(CON, 9)]},
        {'name': 'Craftpriest', 'primes': [WIS], 'reqs': [(CON, 9)]},
        {'name': 'Delver', 'primes': [DEX], 'reqs': [(CON, 9)]},
        {'name': 'Fury', 'primes': [STR], 'reqs': [(CON, 9)]},
        {'name': 'Machinist', 'primes': [INT, DEX], 'reqs': [(CON, 9)]},
        {'section': 'Elven Classes'},
        {'name': 'Spellsword', 'primes': [STR, INT], 'reqs': []},
        {'name': 'Nightblade', 'primes': [DEX, INT], 'reqs': []},
        {'name': 'Courtier', 'primes': [INT, CHA], 'reqs': [(INT, 9)]},
        {'name': 'Enchanter', 'primes': [INT, CHA], 'reqs': [(INT, 9)]},
        {'name': 'Ranger', 'primes': [STR, DEX], 'reqs': [(INT, 9)]},
        {'section': 'Other demi-humans'},
        {'name': 'Gnomish Trickster', 'primes': [CON, CHA],
            'reqs': [(CON, 9), (INT, 9)]},
        {'name': 'Nobrian Wonderworker', 'primes': [INT, WIS],
            'reqs': [(i, 11) for i in range(6)]},
        {'name': 'Thrassian Gladiator', 'primes': [STR],
            'reqs': [(STR, 9), (DEX, 9), (CON, 9)]},
        {'name': 'Zaharan Ruinguard', 'primes': [STR, INT],
            'reqs': [(INT, 9), (WIS, 9), (CHA, 9)]},
        {'section': 'Heroic Classes'},
        {'name': 'Beastmaster', 'primes': [STR, DEX, CON, CHA], 'reqs': []},
        {'name': 'Berserker', 'primes': [STR, CON], 'reqs': []},
        {'name': 'Chosen', 'primes': [i for i in range(6)],
            'reqs': [(i, 9) for i in range(6)], 'special': 'chosen'},
        {'name': 'Ecclesiastic', 'primes': [WIS], 'reqs': []},
        {'name': 'Elven Spellsinger', 'primes': [INT, CHA], 'reqs': [(INT, 9)]},
        {'name': 'Freebooter Expeditionary', 'primes': [DEX, WIS], 'reqs': []},
        {'name': 'Freebooter Ruffian', 'primes': [DEX, STR], 'reqs': []},
        {'name': 'Freebooter Scoundrel', 'primes': [DEX, CHA], 'reqs': []},
        {'name': 'Freebooter Wayfarer', 'primes': [DEX, CON], 'reqs': []},
        {'name': 'Halfling Bounder', 'primes': [STR, DEX], 'reqs': [(DEX, 9)]},
        {'name': 'Halfling Burglar', 'primes': [DEX], 'reqs': [(DEX, 9)]},
        {'name': 'Loremaster', 'primes': [INT, WIS], 'reqs': []},
        {'name': 'Nobrian Champion', 'primes': [STR, CHA],
            'reqs': [(i, 11) for i in range(6)]},
        {'name': 'Nobrian Wizard', 'primes': [INT, WIS],
            'reqs': [(i, 11) for i in range(6)]},
        {'name': 'Occultist', 'primes': [INT, WIS], 'reqs': []},
        {'name': 'Rune Maker', 'primes': [STR, WIS], 'reqs': []},
        {'name': 'Thrassian Deathchanter', 'primes': [STR, INT, CHA],
            'reqs': [(STR, 9), (DEX, 9), (CON, 9)]},
        {'name': 'Venturer', 'primes': [CHA], 'reqs': []},
        {'name': 'Warmistress', 'primes': [DEX, CHA], 'reqs': [(STR, 9)]},
        {'name': 'Zaharan Darklord', 'primes': [INT, CHA],
            'reqs': [(INT, 9), (WIS, 9), (CHA, 9)]},
        {'name': 'Zaharan Sorcerer', 'primes': [INT],
            'reqs': [(INT, 9), (WIS, 9), (CHA, 9)]},
        ]
    section = ''
    for cls in classes:
        new_section = cls.get('section')
        if new_section:
            if opts['showall']:
                click.echo('\n' + new_section)
            else:
                section = new_section
            continue

        prime = min((stats[prime] for prime in cls['primes']))

        fitness = stat_level(prime)

        for req in cls['reqs']:
            if stats[req[0]] < req[1]:
                fitness = -1
                prime = 3
                break

        if cls.get('special') == 'chosen':
            if max(stats) < 18:
                fitness = -1
                prime = 3
                break

        if fitness < 0:
            if opts['showall']:
                click.echo(''.join([c+'\u0336' for c in cls['name']]) + '  ',
                           nl=False)
        else:
            if section:
                click.echo('\n    ' + section)
                section = None
            click.echo(click.style(cls['name'] + '  ',
                                   fg=stat_colors(prime, opts)),
                       nl=False)


def printstats(stats, opts):
    for i, stat in enumerate(stats):
        click.echo(click.style('{}:{:>3}  '.format(STATS[i], stat),
                               fg=stat_colors(stat, opts)),
                   nl=False)
    click.echo('Gold:{:>3}  '.format(rollstat(opts)*10))

    if opts['show_classes']:
        evalstats(stats, opts)
        click.echo('\n')


@click.command()
@click.option('-n', '--number', default=5, help='Number of characters (default 5).')
@click.option('--classes', is_flag=True, help="Display the list of classes qualified for.")
@click.option('--showall', is_flag=True, help='Show classes not allowed by stats.')
@click.option('--no-color', is_flag=True, help='Do not use color to print.')
@click.option('--no-sort', is_flag=True, help='Do not sort the characters by total stats.')
@click.option('--heroic', is_flag=True, help='Generate stats by 4d6 dropping the lowest.')
@click.option('--seed', default=None, help='Override the RNG seed.')
def generate(number, classes, showall, no_color, no_sort, heroic, seed):
    """Character generator for ACKS."""
    opts = {
        'number': number,
        'show_classes': classes,
        'showall': showall,
        'color': not no_color,
        'sort': not no_sort,
        'heroic': heroic,
        'seed': seed,
    }

    if seed is None:
        time = datetime.now()
        seed = time.hour*10000 + time.minute*100 + time.second
    random.seed(seed)

    statss = [rollstats(opts) for i in range(number)]
    if opts['sort']:
        statss = sorted(statss, key=lambda arr: -sum(arr))
    for stats in statss:
        printstats(stats, opts)
    click.echo('\nSeed: {}'.format(seed))


if __name__ == '__main__':
    generate()
