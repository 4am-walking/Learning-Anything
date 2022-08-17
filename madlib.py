#!/usr/bin/env python3

import click

@click.command()
@click.option('--noun', '-n', prompt='Enter a noun')
@click.option('--verb', '-v', prompt='Enter a verb')
@click.option('--adjective', '-a', prompt='Enter an adjective')

def madlib(noun,verb,adjective):
	click.echo(f'This madlib was brought to you by {noun}. It is the first time {noun} has {verb}. With the help of the {adjective} websites, {noun} is able to present a madlib!')

if __name__ == '__main__':
	madlib()
