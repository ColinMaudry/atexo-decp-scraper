import argparse
import json
import os
import sys

import requests
import unidecode
from bs4 import BeautifulSoup

from . import site_utils

HTML_PAGE_PER_PLATFORM = {}
JSON_BUYER_LIST_PER_PLATFORM = {}


def get_html_file(platform):
    return site_utils.get_base_url_from_site(platform) + '/?page=entreprise.EntrepriseRechercherListeMarches'


def get_json_path(platform):
    return 'acheteurs/' + platform + '.json'


def extract_buyers(platform, should_rely_on_file):
    global HTML_PAGE_PER_PLATFORM
    if os.path.exists(get_html_path(platform)):
        html_file = open(get_html_path(platform), 'rb')
        html_text = html_file.read()
        HTML_PAGE_PER_PLATFORM[platform] = html_text
    else:
        html_text = HTML_PAGE_PER_PLATFORM[platform]
    soup = BeautifulSoup(html_text, 'html.parser')
    drop_down = soup.find_all('select', id='ctl0_CONTENU_PAGE_organismeAcronyme')
    options = drop_down[0].find_all('option')
    buyers = []
    for option in options[1:]:
        id = option.get('value')
        name = str(option.string).strip()
        buyers.append({'id': id, 'name': name})
    return buyers


def main(argv):
    arguments = parse_args(argv)
    extract_buyer_information_for_multiple_platform(arguments)


def extract_buyer_information_for_multiple_platform(arguments):
    platform = arguments.get('site', None)
    should_rely_on_file = arguments.get('with_files', True)
    base_url = None
    if platform is not None:
        if should_rely_on_file:
            if not os.path.exists('html'):
                os.mkdir('html')
            if not os.path.exists('acheteurs'):
                os.mkdir('acheteurs')
        if platform == 'all':
            platforms = list(site_utils.get_all_platforms().keys())
        else:
            platforms = [platform]
        for platform in platforms:
            extract_buyer_information(platform, should_rely_on_file)
    else:
        print("ID de plateforme $plateforme introuvable.")


def extract_buyer_information(platform, should_rely_on_file):
    global HTML_PAGE_PER_PLATFORM, JSON_BUYER_LIST_PER_PLATFORM
    if not os.path.exists(get_json_path(platform)):
        print('Starting buyer extraction :' + platform)
        base_url = site_utils.get_base_url_from_site(platform)
        if base_url is not None:
            print('Base URL found in config: ' + base_url)
            html_file_url = get_html_file(platform)
            file_path = get_html_path(platform)
            if not os.path.exists(file_path):
                print('Downloading HTML file')
                with requests.get(html_file_url) as response, open(file_path, 'wb') as out_file:
                    HTML_PAGE_PER_PLATFORM[platform] = response.content
                    if should_rely_on_file:
                        out_file.write(response.content)
            buyers = extract_buyers(platform, should_rely_on_file)
            JSON_BUYER_LIST_PER_PLATFORM[platform] = buyers
            if should_rely_on_file:
                with open(get_json_path(platform), 'w', encoding='utf-8') as json_file:
                    json.dump(buyers, json_file, ensure_ascii=False, indent=2)


def parse_args(argv):
    parser = argparse.ArgumentParser(
        description='Download buyers and corresponding code from chosen ATEXO powered tender websites',
        epilog="Now, let's have fun !")
    parser.add_argument('program', help='Default program argument in case files is called from Python executable')
    parser.add_argument('--site', required=True)
    arguments = vars(parser.parse_args(argv))
    return arguments


def get_html_path(platform):
    file_path = 'html/' + platform + '.html'
    return file_path


if __name__ == '__main__':
    main(sys.argv)
