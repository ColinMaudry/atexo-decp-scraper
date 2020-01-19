#!/bin/python3
import argparse
import csv
import json
import os
import pathlib
import re
import sys
import xml
from datetime import datetime
from os import mkdir
from os.path import isdir
from xml.dom import minidom

import requests as requests
import unidecode as unidecode


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


def download_files(platform, years=None, force=False):
    xml_dir = get_xml_dir(platform)
    base_url = get_base_url_from_site(platform)
    buyers_file = 'acheteurs/' + platform + '.json'
    if years is None:
        current_year = datetime.now().year
        years = [index + 2018 for index in range(current_year - 2018 + 1)]
    buyers = json.loads(open(buyers_file, 'r').read())
    for buyer in buyers:
        print('Downloading files')
        buyer_name = re.sub("[ -./\\\\]+", ' ', unidecode.unidecode(buyer.get('name', None)).lower()).strip().replace(
            ' ', '_')
        buyer_id = buyer.get('id', None)
        if buyer_id is not None:
            print('Downloading buyer: ' + buyer_name)
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
    possible_sites = list(get_all_platforms().keys())
    parser = argparse.ArgumentParser(
        description='Download DECP files from chosen ATEXO powered tender websites',
        epilog="Download with politeness (late schedule and low speed), those sites are public services. You download at your own risks and responsibility.")
    parser.add_argument('program', help='Default program argument in case files is called from Python executable')
    parser.add_argument('-s', '--site', required=True, help='Specify the site you wish to download DECP from', choices=possible_sites)
    parser.add_argument('-y', '--year', required=False,
                        help='Specify the year you wish to download the DECP for. Should be an int >=2018')
    parser.add_argument('-f', '--force_download', action='store_true',
                        help='Specify that you want to download the files even if you have them already to get fresh content')
    arguments = vars(parser.parse_args(argv))
    platform = arguments.get('site', None)
    year_str = arguments.get('year', None)
    force = arguments.get('force_download')
    years = None
    if year_str is not None:
        try:
            year = int(year_str)
            assert year >= 2018
            years = [year]
        except (ValueError, AssertionError) as e:
            exit('Stopping: Argument --year must be an integer year after or equal to 2018')
    base_url = None
    if platform is not None:
        stat_file = open('disponibilite-donnees.csv', 'w')
        stat_file.close()
        if platform == 'all':
            platforms = possible_sites
        else:
            platforms = [platform]
        for platform in platforms:
            print('Starting data capture for platform :' + platform)
            base_url = get_base_url_from_site(platform)
            if base_url is not None:
                print('Base URL found in config: ' + base_url)
                xml_dir = get_xml_dir(platform)
                create_directory_structure(platform)
                download_files(platform, years, force)
            merge_files(platform)
        merge_all_files(platforms)
    else:
        print("ID de plateforme $plateforme introuvable.")


if __name__ == '__main__':
    main(sys.argv)
