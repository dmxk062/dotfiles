#!/usr/bin/env python

from datetime import datetime
import re
import xml.etree.ElementTree as ET
import zipfile
from gi.repository import GObject, Nautilus, Gio
from urllib.parse import unquote

META_NS={'dc': 'http://purl.org/dc/elements/1.1/'}

LANGUAGES={
    'en': 'English / English',
    'es': 'Spanish / Español',
    'fr': 'French / Français',
    'de': 'German / Deutsch',
    'zh-Hans': 'Chinese (Simplified) / 中文（简体）',
    'zh-Hant': 'Chinese (Traditional) / 中文（繁體）',
    'ja': 'Japanese / 日本語',
    'ko': 'Korean / 한국어',
    'ru': 'Russian / Русский',
    'ar': 'Arabic / العربية',
    'pt': 'Portuguese / Português',
    'it': 'Italian / Italiano',
    'nl': 'Dutch / Nederlands',
    'sv': 'Swedish / Svenska',
    'no': 'Norwegian / Norsk',
    'da': 'Danish / Dansk',
    'fi': 'Finnish / Suomi',
    'el': 'Greek / Ελληνικά',
    'he': 'Hebrew / עברית',
    'hi': 'Hindi / हिन्दी',
    'id': 'Indonesian / Bahasa Indonesia',
    'tr': 'Turkish / Türkçe',
    'th': 'Thai / ไทย',
    'vi': 'Vietnamese / Tiếng Việt',
    'pl': 'Polish / Polski',
    'cs': 'Czech / Čeština',
    'hu': 'Hungarian / Magyar',
    'ro': 'Romanian / Română',
    'bg': 'Bulgarian / Български',
    'ca': 'Catalan / Català',
    'hr': 'Croatian / Hrvatski',
    'sk': 'Slovak / Slovenčina',
    'sl': 'Slovenian / Slovenščina',
    'sr': 'Serbian / Српски',
    'mk': 'Macedonian / Македонски',
    'sq': 'Albanian / Shqip',
    'et': 'Estonian / Eesti',
    'lv': 'Latvian / Latviešu',
    'lt': 'Lithuanian / Lietuvių',
    'mt': 'Maltese / Malti',
    'gd': 'Gaelic / Gàidhlig',
    'cy': 'Welsh / Cymraeg',
    'ga': 'Irish / Gaeilge',
    'eu': 'Basque / Euskara',
    'eo': 'Esperanto / Esperanto',
    'la': 'Latin / Latina',
}


class EpubInformationPage(GObject.GObject, Nautilus.PropertiesModelProvider):
    def get_models(self,
                   files: list[Nautilus.FileInfo]
                   ) -> list[Nautilus.PropertiesModel]:
        if len(files) != 1:
            return []
        
        file = files[0]

        if file.is_directory():
            return []

        if file.get_mime_type() != "application/epub+zip":
            return []


        filepath = unquote(file.get_uri()[7:])
        metadata = self._get_meta_from_epub(filepath)

        section = Gio.ListStore.new(item_type=Nautilus.PropertiesItem)
        if metadata["title"][0]:
            title = metadata["title"][1]
            title = f"{title}"
        else:
            title = "EPUB Metadata"

        for val in metadata.values():
            if val[0]:
                section.append(
                        Nautilus.PropertiesItem(
                            name= val[2],
                            value= val[1]
                            )
                        )

        return [
                Nautilus.PropertiesModel(
                    title = title,
                    model = section
                    )
                ]

    @classmethod
    def _sanitize_html(cls, str: str) -> str:
        if str is None:
            return None
        headings = re.compile('<h[1-6][^>]*>(.*?)</h[1-6]>')
        paragraphs = re.compile('<(/?)p[^>]*>')
        str = re.sub(headings, '\n', str)
        str = re.sub(paragraphs, '', str)
        tags = re.compile("<.*?>")
        return re.sub(tags, '', str)


    @classmethod
    def _safely_get_prop(cls, meta, name: str, title) -> list:
        match = meta.find(name, namespaces=META_NS)
        if match is None:
            return (False, None, title)
        else:
            return (True, match.text, title)


    def _get_meta_from_epub(self, path: str) -> dict[str or list[str]]:
        with zipfile.ZipFile(path, "r") as file:
            with file.open('META-INF/container.xml') as meta_xml:
                metastr = meta_xml.read()
            
            metaroot = ET.fromstring(metastr)
            metapath = metaroot.find(
                    './/{urn:oasis:names:tc:opendocument:xmlns:container}rootfile'
                    ).get('full-path')
            with file.open(metapath) as metafile:
                content = metafile.read()

        metadata = ET.fromstring(content)
        isbn = None
        identifiers = metadata.findall('.//dc:identifier', namespaces=META_NS)
        for identifier in identifiers:
            scheme =  identifier.attrib.get("{http://www.idpf.org/2007/opf}scheme")
            if scheme and scheme == "ISBN":
                isbn = (True, identifier.text, "ISBN")
            else: 
                isbn = (False, None, None)

        description = self._safely_get_prop(metadata, './/dc:description', "Description")
        if description[0]:
            desc = (True, self._sanitize_html(description[1]), description[2])
        else:
            desc = description
        creator = self._safely_get_prop(metadata, './/dc:creator', None)
        if creator[0]:
            creator_arr = creator[1].strip().split(';')
            creator_str=', '.join(creator_arr)
            title = "Author" if len(creator_arr) == 1 else "Authors"
            creators = (True, creator_str, title)
        else: 
            creators = creator
        publisher = self._safely_get_prop(metadata, './/dc:publisher', "Publisher")
        language = self._safely_get_prop(metadata, './/dc:language', "Language")
        if language[0]:
            language = (True, LANGUAGES[language[1]], "Language")
        title = self._safely_get_prop(metadata, './/dc:title', "Title")
        date = self._safely_get_prop(metadata, './/dc:date', "Creation Date")
        if date[0]:
            date_time = (True, datetime.strftime(datetime.strptime(date[1], "%Y-%m-%dT%H:%M:%S%z"), "%Y/%m/%d"), "Creation Date")
        else:
            date_time = date
        genres = [subject.text for subject in metadata.findall('.//dc:subject', namespaces=META_NS)]
        genres = (True if len(genres) > 0 else False, ', '.join(genres), "Genres")


        return {
            'publisher': publisher,
            'description': desc,
            'language': language,
            'creators': creators,
            'title': title,
            'date': date_time,
            'genres': genres,
            'isbn': isbn
                }
