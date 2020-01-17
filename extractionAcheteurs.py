import argparse
import json
import os
import sys

import requests
import unidecode
from bs4 import BeautifulSoup

import download


def get_html_file(platform):
    return download.get_base_url_from_site(platform) + '/?page=entreprise.EntrepriseRechercherListeMarches'


def get_json_path(platform):
    return 'acheteurs/' + platform + '.json'


def extract_buyers(platform):
    with open(get_html_path(platform), 'rb') as html_file:
        soup = BeautifulSoup(html_file.read(), 'html.parser')
        drop_down = soup.find_all('select', id='ctl0_CONTENU_PAGE_organismeAcronyme')
        options = drop_down[0].find_all('option')
        buyers = []
        for option in options[1:]:
            id = option.get('value')
            name = str(option.string).strip()
            buyers.append({'id': id, 'name': name})
        return buyers


def main(argv):
    parser = argparse.ArgumentParser(
        description='Download buyers and corresponding code from chosen ATEXO powered tender websites',
        epilog="Now, let's have fun !")
    parser.add_argument('program', help='Default program argument in case files is called from Python executable')
    parser.add_argument('--site', required=True)
    arguments = vars(parser.parse_args(argv))
    platform = arguments.get('site', None)
    base_url = None
    if platform is not None:
        if not os.path.exists('html'):
            os.mkdir('html')
        if platform == 'all':
            platforms = list(download.get_all_platforms().keys())
        else:
            platforms = [platform]
        for platform in platforms:
            print('Starting buyer extraction :' + platform)
            base_url = download.get_base_url_from_site(platform)
            if base_url is not None:
                print('Base URL found in config: ' + base_url)
                html_file_url = get_html_file(platform)
                file_path = get_html_path(platform)
                if not os.path.exists(file_path):
                    with requests.get(html_file_url) as response, open(file_path, 'wb') as out_file:
                        out_file.write(response.content)
                buyers = extract_buyers(platform)
                with open(get_json_path(platform), 'w', encoding='utf-8') as json_file:
                    json.dump(buyers, json_file, ensure_ascii=False, indent=2)
    else:
        print("ID de plateforme $plateforme introuvable.")


def get_html_path(platform):
    file_path = 'html/' + platform + '.html'
    return file_path


if __name__ == '__main__':
    main(sys.argv)
