#!/bin/python3
import argparse
import csv
import json
import os
import pathlib
import re
import signal
import sys
import threading
import time
import xml
from datetime import datetime
from os import mkdir
from os.path import isdir
from xml.dom import minidom

import requests as requests
import unidecode as unidecode


class StoppableThread(threading.Thread):
    """Thread class with a stop() method. The thread itself has to check
    regularly for the stopped() condition."""

    def __init__(self, *args, **kwargs):
        super(StoppableThread, self).__init__(*args, **kwargs)
        self._stop_event = threading.Event()

    def stop(self):
        self._stop_event.set()

    def stopped(self):
        return self._stop_event.is_set()


def get_xml_dir(platform):
    return 'xml/' + platform


def get_base_url_from_site(site):
    platforms = get_all_platforms()
    return platforms.get(site, None)


def create_directory_structure(platform):
    xml_dir = get_xml_dir(platform)
    if not isdir(xml_dir):
        mkdir(xml_dir)
    if not isdir(xml_dir + '/vides'):
        mkdir(xml_dir + '/vides')
    if not isdir(xml_dir + '/html'):
        mkdir(xml_dir + '/html')


def download_files(platform, years=None, force=False, delay=0.2):
    xml_dir = get_xml_dir(platform)
    base_url = get_base_url_from_site(platform)
    buyers_file = 'acheteurs/' + platform + '.json'
    if years is None:
        current_year = datetime.now().year
        years = [index + 2018 for index in range(current_year - 2018 + 1)]
    buyers = json.loads(open(buyers_file, 'r').read())
    for buyer in buyers:
        current_thread = threading.current_thread()
        if isinstance(current_thread, StoppableThread) and current_thread.stopped():
            sys.exit('Thread requested to stop, exiting')
        buyer_name = re.sub("[ -./\\\\]+", ' ', unidecode.unidecode(buyer.get('name', None)).lower()).strip().replace(
            ' ', '_')
        buyer_id = buyer.get('id', None)
        if buyer_id is not None:
            time.sleep(delay)
            print('Platform: ' + platform + ' --- downloading buyer: ' + buyer_name)
            for year in years:
                url = base_url + '/app.php/api/v1/donnees-essentielles/contrat/xml-extraire-criteres/' + buyer_id + '/0/1/' + str(
                    year) + '/false/false/false/false/false/false/false/false/false'
                file_path = xml_dir + '/html/' + '_'.join([buyer_id, buyer_name, str(year)]) + '.xml'
                if not os.path.exists(file_path) or force:
                    pathlib.Path(file_path).touch()
                    with requests.get(url) as response, open(file_path, 'wb') as out_file:
                        out_file.write(response.content)


def merge_files(platform, output_file=None):
    stat_file = open('disponibilite-donnees.csv', 'a')
    writer_stats = csv.writer(stat_file, delimiter=',')
    date_as_str = datetime.strftime(datetime.now(), '%Y-%m-%dT%H:%M:%S')
    if output_file is None:
        output_file = open('xml/' + platform + '.xml', 'w')
        output_file.write('<?xml version="1.0" encoding="UTF-8"?>\n')
    html_dir = get_xml_dir(platform) + '/html'
    for root, dirs, files in os.walk(html_dir):
        for file in files:
            if file.split('.')[-1] == 'xml':
                name_components = '.'.join(file.split('.')[:-1]).split('_')
                buyer_id = name_components[0]
                buyer_name = '_'.join(name_components[1:-1])
                year_as_str = name_components[-1]
                row = [platform, buyer_name, year_as_str, 0, date_as_str]
                try:
                    dom = minidom.parse(os.path.join(root, file))
                    markets = dom.getElementsByTagName('marches')
                    nb_of_markets = 0
                    for market_group in markets:
                        nb_of_markets_in_current_group = len(market_group.getElementsByTagName('marche'))
                        if nb_of_markets_in_current_group > 0:
                            nb_of_markets += nb_of_markets_in_current_group
                            output_file.writelines(market_group.toxml() + '\n')
                    row[3] = nb_of_markets
                except xml.parsers.expat.ExpatError:
                    row[3] = 'error'
                finally:
                    writer_stats.writerow(tuple(row))


def get_all_platforms():
    platform_file = open('plateformes.csv', 'r')
    platform_lines = platform_file.read().split('\n')
    platform_reader = csv.reader(platform_lines, delimiter=',')
    platforms = {}
    for it_line in platform_reader:
        line_as_list = list(it_line)
        if len(line_as_list) > 1:
            platforms[line_as_list[0]] = line_as_list[1]
    return platforms


def merge_all_files(platforms=None):
    if platforms is None:
        platforms = list(get_all_platforms().keys())
    output_file = open('xml/multiple_platforms.xml', 'w')
    output_file.close()
    output_file = open('xml/multiple_platforms.xml', 'a')
    output_file.write('<?xml version="1.0" encoding="UTF-8"?>\n')
    for platform in platforms:
        merge_files(platform, output_file)


def main(argv):
    force, platforms, years, thread_number, delay = parse_and_build_arguments(argv)
    collects_multiple_platforms_data(platforms, years, force, thread_number, delay)


def collects_multiple_platforms_data(platforms, years, force=False, thread_number=1, delay=0.2):
    thread_active_count = threading.active_count() - 1
    available_threads = max(0, thread_number - thread_active_count)
    for platform in platforms:
        while available_threads < 1:
            time.sleep(1)
            thread_active_count = threading.active_count() - 1
            available_threads = max(0, thread_number - thread_active_count)
        new_thread = StoppableThread(target=collect_platform_data, args=[platform, years, force, delay])
        new_thread.start()
        available_threads -= 1
    merge_all_files(platforms)


def collect_platform_data(platform, years, force=False, delay=0.2):
    print('Starting data capture for platform :' + platform)
    base_url = get_base_url_from_site(platform)
    if base_url is not None:
        print('Base URL found in config: ' + base_url)
        xml_dir = get_xml_dir(platform)
        create_directory_structure(platform)
        download_files(platform, years, force, delay)
    merge_files(platform)


def parse_and_build_arguments(argv):
    possible_sites = list(get_all_platforms().keys())
    parser = argparse.ArgumentParser(
        description='Download DECP files from chosen ATEXO powered tender websites',
        epilog="Download with politeness (late schedule and low speed), those sites are public services. You download at your own risks and responsibility.")
    parser.add_argument('program', help='Default program argument in case files is called from Python executable')
    parser.add_argument('-s', '--site', nargs='+', required=True, help='Specify the site you wish to download DECP from',
                        choices=possible_sites + ['all'])
    parser.add_argument('-y', '--year', required=False, type=int,
                        help='Specify the year you wish to download the DECP for. Should be an int >=2018')
    parser.add_argument('-f', '--force_download', action='store_true',
                        help='Specify that you want to download the files even if you have them already to get fresh content, default is to no re-download')
    parser.add_argument('-d', '--delay', type=int, default=0.2,
                        help='Specify that you want to set some delay between calls, default to 0.2s')
    parser.add_argument('-t', '--thread_number', type=int, default=1,
                        help='Specify that you want to use a specific number of threads to speed up the process for multi-site capture, default is one thread')
    arguments = vars(parser.parse_args(argv))
    platforms = arguments.get('site', [])
    year_str = arguments.get('year', None)
    force = arguments.get('force_download')
    thread_number = arguments.get('thread_number', 1)
    delay = arguments.get('delay', 0.2)
    years = None
    if year_str is not None:
        year = int(year_str)
        try:
            assert year >= 2018
            years = [year]
        except AssertionError as e:
            exit('Stopping: Argument --year must be an integer year after or equal to 2018')
    base_url = None
    if platforms is not None:
        stat_file = open('disponibilite-donnees.csv', 'w')
        stat_file.close()
        if 'all' in platforms:
            platforms = possible_sites
    return force, platforms, years, thread_number, delay


def signal_handler(sig, frame):
    print('You pressed Ctrl+C, killing all threads')
    threads = threading.enumerate()
    for thread in threads:
        if isinstance(thread, StoppableThread):
            thread.stop()
    sys.exit(0)


if __name__ == '__main__':
    signal.signal(signal.SIGINT, signal_handler)
    main(sys.argv)
