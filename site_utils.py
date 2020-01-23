import csv
import os


def get_all_platforms():
    platform_file = open(PLATEFORMES_CSV_PATH, 'r')
    platform_lines = platform_file.read().split('\n')
    platform_reader = csv.reader(platform_lines, delimiter=',')
    platforms = {}
    for it_line in platform_reader:
        line_as_list = list(it_line)
        if len(line_as_list) > 1:
            platforms[line_as_list[0]] = line_as_list[1]
    return platforms


def get_base_url_from_site(site):
    platforms = get_all_platforms()
    return platforms.get(site, None)


PLATEFORMES_CSV_PATH = os.path.join(os.path.dirname(__file__), 'plateformes.csv')
