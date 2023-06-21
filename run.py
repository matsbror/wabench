import click

@click.command()
@click.option('--execution-mode', default='interpreted', help='choice of execution mode')
@click.argument('benchmark_list')
def run():
    click.echo('Hello World!')

if __name__ == '__main__':
    run()