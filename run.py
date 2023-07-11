import click
import os
import subprocess
import pathlib

# @click.command()
# @click.option('--execution-mode', default='interpreted', help='choice of execution mode')
# @click.argument('benchmark_list')
# def run():
#     click.echo('Hello World!')

RunAOT = True
MeasureMem = False
MeasurePerf = False
BenchRoot = os.environ['PWD']


if __name__ == '__main__':
    run()